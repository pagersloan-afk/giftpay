const admin = require("firebase-admin");

const PrestmitSellService = require("./prestmit.sell.service");

const db = admin.firestore();

const COLLECTION = "prestmitSellTransactions";
const WALLETS_COLLECTION = "wallets";

/**
 * Normalize provider status.
 */
function normalizeStatus(status) {
  if (!status) {
    return "PENDING";
  }

  return String(status)
    .trim()
    .toUpperCase();
}

/**
 * Find the user's local SELL transaction by Prestmit reference.
 */
async function findSellTransactionByReference(reference) {
  if (!reference) {
    return null;
  }

  const snapshot = await db
    .collection(COLLECTION)
    .where("providerReference", "==", reference)
    .limit(1)
    .get();

  if (snapshot.empty) {
    return null;
  }

  return {
    ref: snapshot.docs[0].ref,
    data: snapshot.docs[0].data(),
  };
}

/**
 * Extract trade information from different possible Prestmit
 * response wrappers.
 */
function extractTrade(payload) {
  if (!payload) {
    return null;
  }

  if (payload.trade) {
    return payload.trade;
  }

  if (payload.data?.trade) {
    return payload.data.trade;
  }

  if (payload.data) {
    return payload.data;
  }

  return null;
}

/**
 * Extract a rejection reason.
 */
function extractRejectionReason(trade, payload) {
  return (
    trade?.rejectionReason ||
    trade?.rejectReason ||
    trade?.rejection_reason ||
    payload?.rejectionReason ||
    payload?.rejectReason ||
    payload?.data?.rejectionReason ||
    payload?.data?.rejectReason ||
    null
  );
}

/**
 * Determine the actual amount that Prestmit says the partner
 * receives for the completed trade.
 *
 * The SELL create response contains totalAmount.
 *
 * We intentionally prefer the provider's final amount over
 * calculating amount * rate ourselves.
 */
function extractProviderPayout(trade, payload) {
  const candidates = [
    trade?.totalAmount,
    trade?.total_amount,
    trade?.payoutAmount,
    trade?.payout_amount,
    payload?.totalAmount,
    payload?.payoutAmount,
    payload?.data?.totalAmount,
    payload?.data?.payoutAmount,
  ];

  for (const value of candidates) {
    if (
      value !== undefined &&
      value !== null &&
      value !== "" &&
      Number.isFinite(Number(value))
    ) {
      return Number(value);
    }
  }

  return null;
}

/**
 * Credit a GiftPay wallet atomically and idempotently.
 */
async function creditWalletForCompletedSell({
  transactionRef,
  userId,
  amount,
  giftCardTitle,
  providerReference,
}) {
  if (!transactionRef) {
    throw new Error(
      "transactionRef is required for wallet credit"
    );
  }

  if (!userId) {
    throw new Error(
      `Cannot credit SELL ${transactionRef}: userId is missing`
    );
  }

  if (!Number.isFinite(Number(amount)) || Number(amount) <= 0) {
    throw new Error(
      `Cannot credit SELL ${transactionRef}: invalid payout amount`
    );
  }

  const walletRef = db
    .collection(WALLETS_COLLECTION)
    .doc(userId);

  const transactionId =
    `prestmit:sell:${providerReference || transactionRef}`;

  const payoutAmount = Number(amount);

  return db.runTransaction(async (transaction) => {
    const walletSnapshot =
      await transaction.get(walletRef);

    if (!walletSnapshot.exists) {
      throw new Error(
        `Wallet does not exist for user ${userId}`
      );
    }

    const walletData =
      walletSnapshot.data() || {};

    const currentBalance = Number(
      walletData.balance || 0
    );

    const existingTransactions =
      Array.isArray(walletData.transactions)
        ? walletData.transactions
        : [];

    const alreadyCredited =
      existingTransactions.some(
        (item) =>
          item?.id === transactionId ||
          item?.providerReference === providerReference
      );

    if (alreadyCredited) {
      return {
        credited: false,
        alreadyCredited: true,
        amount: payoutAmount,
        transactionId,
      };
    }

    const newBalance =
      currentBalance + payoutAmount;

    const walletTransaction = {
      id: transactionId,
      type: "credit",
      title:
        `Gift Card Sale - ${
          giftCardTitle || "Gift Card"
        }`,
      amount: payoutAmount.toString(),
      timestamp: Date.now(),
      status: "success",
      provider: "prestmit",
      providerReference:
        providerReference || transactionRef,
      source: "prestmit_sell",
    };

    transaction.update(walletRef, {
      balance: newBalance,
      transactions: admin.firestore.FieldValue.arrayUnion(
        walletTransaction
      ),
      updatedAt:
        admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      credited: true,
      alreadyCredited: false,
      amount: payoutAmount,
      transactionId,
      previousBalance: currentBalance,
      newBalance,
    };
  });
}

/**
 * Process a Prestmit SELL transaction.
 *
 * This function queries Prestmit history rather than trusting
 * the webhook amount. This prevents the webhook itself from
 * becoming the source of financial truth.
 */
async function processPrestmitSell(reference) {
  if (!reference) {
    throw new Error(
      "Prestmit SELL reference is required"
    );
  }

  const localTransaction =
    await findSellTransactionByReference(reference);

  if (!localTransaction) {
    console.warn(
      `[PRESTMIT SELL PROCESSOR] Local transaction not found for ${reference}`
    );

    return {
      reference,
      processed: false,
      status: "NOT_FOUND",
    };
  }

  const providerResponse =
    await PrestmitSellService.getSellTransaction(
      reference
    );

  const trade =
    extractTrade(providerResponse);

  if (!trade) {
    throw new Error(
      `Prestmit SELL trade not found for ${reference}`
    );
  }

  const providerStatus =
    normalizeStatus(trade.status);

  const rejectionReason =
    extractRejectionReason(
      trade,
      providerResponse
    );

  const providerPayout =
    extractProviderPayout(
      trade,
      providerResponse
    );

  const localRef =
    localTransaction.ref;

  const localData =
    localTransaction.data || {};

  /**
   * PENDING
   */
  if (providerStatus === "PENDING") {
    await localRef.update({
      status: "PENDING",
      providerStatus,
      providerTrade: trade,
      updatedAt:
        admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      reference,
      status: "PENDING",
      providerStatus,
      processed: true,
      walletCredited: false,
    };
  }

  /**
   * REJECTED
   */
  if (
    providerStatus === "REJECTED" ||
    providerStatus === "FAILED"
  ) {
    await localRef.update({
      status: "REJECTED",
      providerStatus,
      rejectionReason,
      providerTrade: trade,
      updatedAt:
        admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      reference,
      status: "REJECTED",
      providerStatus,
      rejectionReason,
      processed: true,
      walletCredited: false,
    };
  }

  /**
   * COMPLETED
   */
  if (providerStatus === "COMPLETED") {
    const payout =
      providerPayout ??
      Number(localData.expectedPayout || 0);

    if (
      !Number.isFinite(payout) ||
      payout <= 0
    ) {
      throw new Error(
        `Completed Prestmit SELL ${reference} has no valid payout amount`
      );
    }

    /**
     * Credit wallet only once.
     */
    const walletResult =
      await creditWalletForCompletedSell({
        transactionRef: reference,
        userId: localData.userId,
        amount: payout,
        giftCardTitle:
          localData.giftCardName ||
          localData.cardType ||
          localData.brand ||
          "Gift Card",
        providerReference: reference,
      });

    await localRef.update({
      status: "COMPLETED",
      providerStatus,
      providerTrade: trade,
      providerPayout: payout,
      walletCredited: true,
      walletCreditAmount: payout,
      walletCreditTransactionId:
        walletResult.transactionId,
      completedAt:
        admin.firestore.FieldValue.serverTimestamp(),
      updatedAt:
        admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      reference,
      status: "COMPLETED",
      providerStatus,
      processed: true,
      walletCredited:
        walletResult.credited,
      alreadyProcessed:
        walletResult.alreadyCredited,
      payout,
    };
  }

  /**
   * Unknown status.
   *
   * Do not credit the wallet.
   */
  await localRef.update({
    status: "PENDING",
    providerStatus,
    providerTrade: trade,
    updatedAt:
      admin.firestore.FieldValue.serverTimestamp(),
  });

  return {
    reference,
    status: "PENDING",
    providerStatus,
    processed: true,
    walletCredited: false,
  };
}

/**
 * Save the initial SELL transaction returned by Prestmit.
 */
async function createLocalSellTransaction({
  userId,
  providerTrade,
  giftcardId,
  giftCardName,
  brand,
  country,
  cardType,
  amount,
  rate,
  expectedPayout,
  payoutMethod,
  comments,
  uniqueIdentifier,
}) {
  if (!userId) {
    throw new Error("userId is required");
  }

  if (!providerTrade?.reference) {
    throw new Error(
      "Prestmit SELL reference is missing"
    );
  }

  const reference =
    providerTrade.reference;

  const transactionRef = db
    .collection(COLLECTION)
    .doc();

  const now =
    admin.firestore.FieldValue.serverTimestamp();

  const record = {
    userId,

    provider: "prestmit",
    providerReference: reference,
    providerStatus:
      providerTrade.status || "PENDING",

    status: "PENDING",

    giftcardId:
      giftcardId !== undefined
        ? Number(giftcardId)
        : null,

    giftCardName:
      giftCardName ||
      providerTrade.giftcard?.name ||
      null,

    brand:
      brand ||
      providerTrade.category?.name ||
      null,

    country:
      country || null,

    cardType:
      cardType ||
      providerTrade.giftcard?.form ||
      null,

    amount:
      Number(amount || providerTrade.units || 0),

    rate:
      Number(
        rate ||
          providerTrade.rate ||
          providerTrade.giftcard?.rate ||
          0
      ),

    expectedPayout:
      Number(
        expectedPayout ||
          providerTrade.totalAmount ||
          0
      ),

    payoutMethod:
      payoutMethod || null,

    comments:
      comments || null,

    uniqueIdentifier:
      uniqueIdentifier || null,

    rejectionReason:
      providerTrade.rejectionReason ||
      null,

    providerTrade,

    walletCredited: false,

    createdAt: now,
    updatedAt: now,
  };

  await transactionRef.set(record);

  return {
    id: transactionRef.id,
    ...record,
    providerReference: reference,
  };
}

module.exports = {
  COLLECTION,
  processPrestmitSell,
  createLocalSellTransaction,
  findSellTransactionByReference,
};