const admin = require("firebase-admin");
const PrestmitService = require("./prestmit.service");
const { sendNotification } = require("../../utils/notify");
const FeeEngine = require("../../core/fees/fee_engine");

const db = admin.firestore();

function extractTransaction(historyResponse, reference) {
  const transactions =
    Array.isArray(historyResponse?.data)
      ? historyResponse.data
      : Array.isArray(historyResponse?.data?.data)
        ? historyResponse.data.data
        : Array.isArray(historyResponse)
          ? historyResponse
          : [];

  const safeReference = String(reference).trim();

  return (
    transactions.find(
      (item) =>
        String(item?.reference || "").trim() === safeReference
    ) || transactions[0] || null
  );
}

function normalizeCards(transaction) {
  if (!Array.isArray(transaction?.cards)) return [];

  return transaction.cards
    .filter((card) => card && typeof card === "object")
    .map((card) => ({
      cardNumber: card.cardNumber ?? null,
      pinCode: card.pinCode ?? null,
      claimUrl: card.claimUrl ?? null,
      expireDate: card.expireDate ?? null,
    }));
}

/**
 * Send the GiftPay gift-card completion notification exactly once.
 *
 * IMPORTANT:
 * - The notification is sent only after the purchase and wallet debit
 *   have been successfully committed.
 * - "giftcard" is intentionally passed as the notification category so
 *   notify.js can also send transaction email when the user has enabled
 *   emailAlerts and transactionUpdates.
 * - Sensitive gift-card information such as card number and PIN is NOT
 *   included in the notification.
 */
async function notifyGiftCardCompletion({
  purchaseRef,
  userId,
  giftCardTitle,
}) {
  if (!purchaseRef || !userId) {
    return;
  }

  let shouldSend = false;

  try {
    await db.runTransaction(async (transaction) => {
      const purchaseSnap = await transaction.get(purchaseRef);

      if (!purchaseSnap.exists) {
        return;
      }

      const purchase = purchaseSnap.data() || {};

      const purchaseStatus = String(
        purchase.status || ""
      ).toUpperCase();

      if (purchaseStatus !== "COMPLETED") {
        return;
      }

      if (purchase.notificationSent === true) {
        return;
      }

      transaction.update(purchaseRef, {
        notificationSent: true,
        notificationSentAt:
          admin.firestore.FieldValue.serverTimestamp(),
        updatedAt:
          admin.firestore.FieldValue.serverTimestamp(),
      });

      shouldSend = true;
    });

    if (!shouldSend) {
      return;
    }

    const title = giftCardTitle || "Gift Card";

    await sendNotification(
      userId,
      "Gift Card Delivered",
      `${title} has been delivered successfully. Your gift card details are now available in your GiftPay receipt.`,
      "giftcard"
    );

    console.log(
      `🔔 Gift-card notification sent for Prestmit purchase ${purchaseRef.id}`
    );
  } catch (error) {
    console.error(
      `⚠️ Gift-card notification failed for ${purchaseRef.id}:`,
      error.message
    );

    /*
     * The purchase itself is already completed. If notification sending
     * failed, reset notificationSent so the next requery can retry it.
     */
    try {
      await purchaseRef.set(
        {
          notificationSent: false,
          notificationError: error.message || "Notification failed",
          notificationRetryAt:
            admin.firestore.FieldValue.serverTimestamp(),
          updatedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    } catch (resetError) {
      console.error(
        `⚠️ Could not reset gift-card notification flag for ${purchaseRef.id}:`,
        resetError.message
      );
    }
  }
}

/**
 * Send a BUY rejection notification exactly once.
 */
async function notifyGiftCardRejection({
  purchaseRef,
  userId,
  giftCardTitle,
  reason,
}) {
  if (!purchaseRef || !userId) return;

  let shouldSend = false;

  try {
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(purchaseRef);

      if (!snapshot.exists) return;

      const purchase = snapshot.data() || {};

      if (
        String(purchase.status || "").toUpperCase() !==
        "REJECTED"
      ) {
        return;
      }

      if (purchase.rejectionNotificationSent === true) {
        return;
      }

      transaction.update(purchaseRef, {
        rejectionNotificationSent: true,
        rejectionNotificationSentAt:
          admin.firestore.FieldValue.serverTimestamp(),
        updatedAt:
          admin.firestore.FieldValue.serverTimestamp(),
      });

      shouldSend = true;
    });

    if (!shouldSend) return;

    await sendNotification(
      userId,
      "Gift Card Purchase Rejected",
      `${giftCardTitle || "Gift Card"} purchase was rejected. Reason: ${reason || "No rejection reason was provided."}`,
      "giftcard"
    );

    console.log(
      `🔔 Gift-card rejection notification sent for Prestmit purchase ${purchaseRef.id}`
    );
  } catch (error) {
    console.error(
      `⚠️ Gift-card rejection notification failed for ${purchaseRef.id}:`,
      error.message
    );

    try {
      await purchaseRef.set(
        {
          rejectionNotificationSent: false,
          notificationError:
            error.message || "Rejection notification failed",
          notificationRetryAt:
            admin.firestore.FieldValue.serverTimestamp(),
          updatedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    } catch (resetError) {
      console.error(
        `⚠️ Could not reset gift-card rejection notification flag for ${purchaseRef.id}:`,
        resetError.message
      );
    }
  }
}

/**
 * Read Prestmit history and, when COMPLETED cards are available,
 * atomically debit the GiftPay wallet and complete the local purchase.
 *
 * IMPORTANT:
 * - The Prestmit /create response can be PENDING.
 * - We only debit after Prestmit history says COMPLETED AND cards exist.
 * - Firestore transaction makes the wallet operation idempotent.
 * - Completion notification is sent only after the financial transaction
 *   has successfully committed.
 */
async function processPrestmitPurchase(reference) {
  const safeReference = String(reference || "").trim();

  if (!safeReference) {
    throw new Error("Prestmit transaction reference is required");
  }

  const purchaseRef = db
    .collection("prestmitPurchases")
    .doc(safeReference);

  // Provider truth is checked before the financial Firestore transaction.
  const history = await PrestmitService.getBuyHistory({
    page: 1,
    perPage: 10,
    referenceOrID: safeReference,
  });

  const providerTransaction = extractTransaction(
    history,
    safeReference
  );

  if (!providerTransaction) {
    return {
      processed: false,
      status: "NOT_FOUND",
      reference: safeReference,
      message: "Prestmit transaction was not found.",
    };
  }

  const providerStatus = String(
    providerTransaction.status || "PENDING"
  ).toUpperCase();

  const cards = normalizeCards(providerTransaction);

  // Do not touch the wallet for a transaction that is still pending.
  if (
    providerStatus === "PENDING" ||
    providerStatus === "PROCESSING"
  ) {
    await purchaseRef.set(
      {
        providerStatus,
        status: "PENDING",
        updatedAt:
          admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return {
      processed: false,
      status: providerStatus,
      reference: safeReference,
      message: "Prestmit transaction is still processing.",
    };
  }

  // Rejected/failed transactions never debit the wallet.
  if (
    providerStatus === "REJECTED" ||
    providerStatus === "FAILED" ||
    providerStatus === "REFUNDED"
  ) {
    await purchaseRef.set(
      {
        providerStatus,
        status: providerStatus,
        walletDebited: false,
        failureReason:
          providerTransaction.message ||
          providerTransaction.remark ||
          `Prestmit transaction ${providerStatus.toLowerCase()}.`,
        rejectionNotificationSent:
          false,
        updatedAt:
          admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    const existingPurchase = await purchaseRef.get();
    const existingPurchaseData = existingPurchase.data() || {};

    await notifyGiftCardRejection({
      purchaseRef,
      userId: existingPurchaseData.userId,
      giftCardTitle:
        existingPurchaseData.giftCardTitle ||
        providerTransaction.giftCard?.title ||
        "Gift Card",
      reason:
        providerTransaction.message ||
        providerTransaction.remark ||
        `Prestmit transaction ${providerStatus.toLowerCase()}.`,
    });

    return {
      processed: false,
      status: providerStatus,
      reference: safeReference,
      message: "Prestmit transaction was not completed.",
    };
  }

  if (providerStatus !== "COMPLETED") {
    return {
      processed: false,
      status: providerStatus,
      reference: safeReference,
      message: `Prestmit returned status ${providerStatus}.`,
    };
  }

  // Prestmit can report COMPLETED before the card details become
  // available. Do not debit the wallet until cards are available.
  if (cards.length === 0) {
    await purchaseRef.set(
      {
        providerStatus: "COMPLETED",
        status: "PROCESSING",
        updatedAt:
          admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return {
      processed: false,
      status: "PROCESSING",
      reference: safeReference,
      message:
        "Prestmit is completed, but no gift-card details are available yet.",
    };
  }

  const result = await db.runTransaction(async (transaction) => {
    const purchaseSnap = await transaction.get(purchaseRef);

    if (!purchaseSnap.exists) {
      throw new Error(
        `GiftPay purchase record not found for Prestmit reference ${safeReference}`
      );
    }

    const purchase = purchaseSnap.data() || {};
    const userId = purchase.userId;

    if (!userId) {
      throw new Error(
        `GiftPay purchase ${safeReference} has no userId`
      );
    }

    // Idempotency guard.
    if (
      purchase.walletDebited === true &&
      String(purchase.status || "").toUpperCase() === "COMPLETED"
    ) {
      return {
        alreadyProcessed: true,
        userId,
        amount: Number(
          purchase.customerDebitAmount ??
            purchase.walletDebitAmount ??
            0
        ),
        cards: purchase.cards || cards,
        giftCardTitle:
          purchase.giftCardTitle ||
          providerTransaction.giftCard?.title ||
          "Gift Card",
      };
    }

    const walletRef = db.collection("wallets").doc(userId);
    const walletSnap = await transaction.get(walletRef);

    if (!walletSnap.exists) {
      throw new Error(`Wallet not found for user ${userId}`);
    }

    const wallet = walletSnap.data() || {};
    const currentBalance = Number(wallet.balance || 0);

    const providerAmount = Number(
      providerTransaction.totalPaymentAmount ??
        purchase.providerAmount ??
        purchase.totalPaymentAmount ??
        0
    );

    if (!Number.isFinite(providerAmount) || providerAmount <= 0) {
      throw new Error(
        `Invalid Prestmit payment amount for ${safeReference}`
      );
    }

    const pricing = FeeEngine.giftCardBuy(providerAmount);
    const amount = pricing.customerDebitAmount;

    if (currentBalance < amount) {
      throw new Error(
        `Insufficient wallet balance. Required ${amount}, available ${currentBalance}.`
      );
    }

    const debitTransactionId = `prestmit:${safeReference}`;

    const existingTransactions = Array.isArray(wallet.transactions)
      ? wallet.transactions
      : [];

    const alreadyInWallet = existingTransactions.some(
      (item) => item?.id === debitTransactionId
    );

    const giftCardTitle =
      purchase.giftCardTitle ||
      providerTransaction.giftCard?.title ||
      "Gift Card";

    const debitTx = {
      id: debitTransactionId,
      type: "debit",
      title: `Gift Card Purchase - ${giftCardTitle}`,
      amount,
      timestamp: Date.now(),
      status: "success",
      provider: "prestmit",
      reference: safeReference,
      sku:
        purchase.giftCardSKU ??
        providerTransaction.giftCard?.sku ??
        null,
      quantity:
        purchase.quantity ??
        providerTransaction.quantity ??
        1,
    };

    const updates = {
      balance: alreadyInWallet
        ? currentBalance
        : currentBalance - amount,
    };

    if (!alreadyInWallet) {
      updates.transactions =
        admin.firestore.FieldValue.arrayUnion(debitTx);
    }

    transaction.update(walletRef, updates);

    transaction.set(
      purchaseRef,
      {
        providerStatus: "COMPLETED",
        status: "COMPLETED",
        walletDebited: true,
        providerAmount: pricing.providerAmount,
        giftPayMarkup: pricing.giftPayMarkup,
        customerDebitAmount: pricing.customerDebitAmount,
        walletDebitAmount: pricing.customerDebitAmount,
        cards,
        providerTransaction: {
          reference:
            providerTransaction.reference ??
            safeReference,
          status:
            providerTransaction.status ??
            null,
          totalPaymentAmount:
            providerTransaction.totalPaymentAmount ??
            null,
          paymentMethod:
            providerTransaction.paymentMethod ??
            null,
          price:
            providerTransaction.price ??
            null,
          quantity:
            providerTransaction.quantity ??
            null,
          giftCard:
            providerTransaction.giftCard ??
            null,
        },
        completedAt:
          admin.firestore.FieldValue.serverTimestamp(),
        updatedAt:
          admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return {
      alreadyProcessed: false,
      userId,
      amount,
      cards,
      giftCardTitle,
    };
  });

  /*
   * IMPORTANT:
   *
   * The Firestore transaction above has now committed successfully.
   * Only now do we send the notification/email.
   *
   * This means the user cannot receive a "Gift Card Delivered"
   * notification for a purchase whose wallet debit failed.
   */
  await notifyGiftCardCompletion({
    purchaseRef,
    userId: result.userId,
    giftCardTitle:
      result.giftCardTitle ||
      "Gift Card",
  });

  return {
    processed: true,
    alreadyProcessed: result.alreadyProcessed,
    status: "COMPLETED",
    reference: safeReference,
    userId: result.userId,
    amount: result.amount,
    cards: result.cards,
  };
}

/**
 * Create/adopt a local GiftPay purchase record for a known Prestmit
 * transaction. This is primarily for the one-time sandbox test of an
 * already-completed transaction that was created before local purchase
 * records were implemented.
 */
async function adoptExistingPrestmitPurchase(reference, userId) {
  const safeReference = String(reference || "").trim();

  if (!safeReference || !userId) {
    throw new Error("reference and userId are required");
  }

  const purchaseRef = db
    .collection("prestmitPurchases")
    .doc(safeReference);

  const existing = await purchaseRef.get();

  if (existing.exists) {
    const data = existing.data() || {};

    if (data.userId && data.userId !== userId) {
      throw new Error(
        "This Prestmit transaction already belongs to another GiftPay user."
      );
    }

    return {
      created: false,
      reference: safeReference,
      purchase: data,
    };
  }

  const history = await PrestmitService.getBuyHistory({
    page: 1,
    perPage: 10,
    referenceOrID: safeReference,
  });

  const providerTransaction = extractTransaction(
    history,
    safeReference
  );

  if (!providerTransaction) {
    throw new Error("Prestmit transaction was not found.");
  }

  const giftCard = providerTransaction.giftCard || {};

  const purchase = {
    userId,
    reference: safeReference,
    giftCardSKU: giftCard.sku ?? null,
    giftCardTitle: giftCard.title ?? "Gift Card",
    price: Number(providerTransaction.price || 0),
    quantity: Number(providerTransaction.quantity || 1),
    paymentMethod:
      providerTransaction.paymentMethod || "NAIRA",
    uniqueIdentifier:
      providerTransaction.partnersApiIdentifier || null,
    totalPaymentAmount: Number(
      providerTransaction.totalPaymentAmount || 0
    ),
    providerAmount: Number(
      providerTransaction.totalPaymentAmount || 0
    ),
    giftPayMarkup: FeeEngine.giftCardBuy(
      Number(providerTransaction.totalPaymentAmount || 0)
    ).giftPayMarkup,
    customerDebitAmount: FeeEngine.giftCardBuy(
      Number(providerTransaction.totalPaymentAmount || 0)
    ).customerDebitAmount,
    walletDebitAmount: FeeEngine.giftCardBuy(
      Number(providerTransaction.totalPaymentAmount || 0)
    ).customerDebitAmount,
    providerStatus:
      providerTransaction.status || "PENDING",
    status: "PENDING",
    walletDebited: false,
    notificationSent: false,
    rejectionNotificationSent: false,
    createdAt:
      admin.firestore.FieldValue.serverTimestamp(),
    updatedAt:
      admin.firestore.FieldValue.serverTimestamp(),
  };

  await purchaseRef.set(purchase);

  return {
    created: true,
    reference: safeReference,
    purchase,
  };
}

module.exports = {
  processPrestmitPurchase,
  adoptExistingPrestmitPurchase,
};
