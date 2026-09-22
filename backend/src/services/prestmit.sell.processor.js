const admin = require("firebase-admin");

const PrestmitSellService = require("./prestmit.sell.service");
const { sendNotification } = require("../../utils/notify");

const db = admin.firestore();

const COLLECTION = "prestmitSellTransactions";
const WALLETS_COLLECTION = "wallets";
const SETTLEMENTS_COLLECTION = "prestmitSellSettlements";

/**
 * ============================================================
 * NORMALIZE PRESTMIT STATUS
 * ============================================================
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
 * ============================================================
 * POSITIVE NUMBER
 * ============================================================
 */
function toPositiveNumber(value) {
  const number = Number(value);

  if (!Number.isFinite(number) || number <= 0) {
    return null;
  }

  return number;
}

/**
 * ============================================================
 * FIND LOCAL SELL TRANSACTION
 * ============================================================
 */
async function findSellTransactionByReference(reference) {
  if (!reference) {
    return null;
  }

  const snapshot = await db
    .collection(COLLECTION)
    .where(
      "providerReference",
      "==",
      String(reference)
    )
    .limit(1)
    .get();

  if (snapshot.empty) {
    return null;
  }

  const document = snapshot.docs[0];

  return {
    ref: document.ref,
    id: document.id,
    data: document.data(),
  };
}

/**
 * ============================================================
 * DOES OBJECT LOOK LIKE A PRESTMIT SELL TRADE?
 * ============================================================
 */
function looksLikeTrade(value) {
  if (!value || typeof value !== "object") {
    return false;
  }

  if (Array.isArray(value)) {
    return false;
  }

  return Boolean(
    value.reference ||
      value.transactionReference ||
      value.status ||
      value.giftcard ||
      value.category ||
      value.totalAmount
  );
}

/**
 * ============================================================
 * GET TRADE REFERENCE
 * ============================================================
 */
function getTradeReference(value) {
  if (!value || typeof value !== "object") {
    return null;
  }

  return (
    value.reference ||
    value.transactionReference ||
    value.transaction_reference ||
    value.id ||
    null
  );
}

/**
 * ============================================================
 * EXTRACT TRADE FROM PRESTMIT RESPONSE
 * ============================================================
 *
 * IMPORTANT:
 *
 * Prestmit SELL history can return:
 *
 * {
 *   success: true,
 *   data: [
 *     {
 *       reference: "...",
 *       status: "COMPLETED"
 *     }
 *   ]
 * }
 *
 * The previous implementation did NOT handle data[]
 * directly. That caused:
 *
 * "Prestmit SELL trade not found for SGC..."
 *
 * even though Prestmit had already completed the trade.
 *
 * We now:
 *
 * 1. Prefer an exact reference match.
 * 2. Support data[].
 * 3. Support transactions[] / trades[] / results[].
 * 4. Support nested data wrappers.
 * 5. Never blindly select an unrelated transaction.
 * ============================================================
 */
function extractTrade(
  payload,
  expectedReference = null
) {
  if (!payload) {
    return null;
  }

  const safeReference =
    expectedReference
      ? String(expectedReference).trim()
      : null;

  /**
   * ----------------------------------------------------------
   * Helper: determine whether this is the exact transaction.
   * ----------------------------------------------------------
   */
  function isExpectedTrade(value) {
    if (!looksLikeTrade(value)) {
      return false;
    }

    if (!safeReference) {
      return true;
    }

    const reference =
      getTradeReference(value);

    return (
      reference !== null &&
      String(reference).trim() ===
        safeReference
    );
  }

  /**
   * ----------------------------------------------------------
   * Helper: search an array.
   * ----------------------------------------------------------
   */
  function searchArray(array) {
    if (!Array.isArray(array)) {
      return null;
    }

    /**
     * First pass:
     * exact reference match.
     */
    if (safeReference) {
      for (const item of array) {
        if (isExpectedTrade(item)) {
          return item;
        }
      }
    }

    /**
     * Second pass:
     * if there is no reference constraint,
     * accept the first valid trade.
     */
    if (!safeReference) {
      for (const item of array) {
        if (looksLikeTrade(item)) {
          return item;
        }
      }
    }

    /**
     * Search nested objects inside array items.
     */
    for (const item of array) {
      const nested =
        searchObject(item);

      if (nested) {
        return nested;
      }
    }

    return null;
  }

  /**
   * ----------------------------------------------------------
   * Helper: search an object.
   * ----------------------------------------------------------
   */
  function searchObject(object) {
    if (
      !object ||
      typeof object !== "object" ||
      Array.isArray(object)
    ) {
      return null;
    }

    /**
     * Direct exact trade.
     */
    if (isExpectedTrade(object)) {
      return object;
    }

    /**
     * Direct trade wrappers.
     */
    const directCandidates = [
      object.trade,
      object.transaction,
      object.sellTransaction,
      object.sellTrade,
    ];

    for (const candidate of directCandidates) {
      if (isExpectedTrade(candidate)) {
        return candidate;
      }

      const nested =
        searchObject(candidate);

      if (nested) {
        return nested;
      }
    }

    /**
     * --------------------------------------------------------
     * IMPORTANT:
     * Prestmit history commonly uses:
     *
     * {
     *   success: true,
     *   data: [...]
     * }
     *
     * Therefore data itself must be searched as an array.
     * --------------------------------------------------------
     */
    const collectionCandidates = [
      object.data,
      object.transactions,
      object.trades,
      object.results,
      object.items,
    ];

    for (const candidate of collectionCandidates) {
      if (Array.isArray(candidate)) {
        const result =
          searchArray(candidate);

        if (result) {
          return result;
        }
      }
    }

    /**
     * data may itself contain another wrapper:
     *
     * {
     *   data: {
     *     data: [...]
     *   }
     * }
     */
    if (
      object.data &&
      typeof object.data === "object" &&
      !Array.isArray(object.data)
    ) {
      const nested =
        searchObject(
          object.data
        );

      if (nested) {
        return nested;
      }
    }

    /**
     * Search remaining nested objects.
     *
     * This is deliberately limited to objects so we don't
     * recursively walk primitive values.
     */
    for (const [key, value] of Object.entries(object)) {
      if (
        key === "trade" ||
        key === "transaction" ||
        key === "sellTransaction" ||
        key === "sellTrade" ||
        key === "data" ||
        key === "transactions" ||
        key === "trades" ||
        key === "results" ||
        key === "items"
      ) {
        continue;
      }

      if (
        value &&
        typeof value === "object"
      ) {
        const nested =
          Array.isArray(value)
            ? searchArray(value)
            : searchObject(value);

        if (nested) {
          return nested;
        }
      }
    }

    return null;
  }

  return searchObject(payload);
}

/**
 * ============================================================
 * EXTRACT REJECTION REASON
 * ============================================================
 */
function extractRejectionReason(
  trade,
  payload
) {
  const candidates = [
    trade?.rejectionReason,
    trade?.rejectReason,
    trade?.rejection_reason,

    payload?.rejectionReason,
    payload?.rejectReason,
    payload?.rejection_reason,

    payload?.data?.rejectionReason,
    payload?.data?.rejectReason,
    payload?.data?.rejection_reason,
  ];

  for (const value of candidates) {
    if (
      value !== undefined &&
      value !== null &&
      String(value).trim() !== ""
    ) {
      return String(value);
    }
  }

  return null;
}

/**
 * ============================================================
 * EXTRACT PROVIDER PAYOUT
 * ============================================================
 */
function extractProviderPayout(
  trade,
  payload
) {
  const candidates = [
    trade?.totalAmount,
    trade?.total_amount,
    trade?.payoutAmount,
    trade?.payout_amount,
    trade?.totalPayout,
    trade?.total_payout,
    trade?.payoutTotal,
    trade?.payout_total,

    payload?.totalAmount,
    payload?.total_amount,
    payload?.payoutAmount,
    payload?.payout_amount,
    payload?.payoutTotal,
    payload?.payout_total,

    payload?.data?.totalAmount,
    payload?.data?.total_amount,
    payload?.data?.payoutAmount,
    payload?.data?.payout_amount,
    payload?.data?.payoutTotal,
    payload?.data?.payout_total,
  ];

  for (const value of candidates) {
    const number =
      toPositiveNumber(value);

    if (number !== null) {
      return number;
    }
  }

  return null;
}

/**
 * ============================================================
 * ATOMIC SELL SETTLEMENT
 * ============================================================
 */
async function settleCompletedSell({
  localRef,
  transactionRef,
  userId,
  amount,
  giftCardTitle,
  providerReference,
  providerTrade,
}) {
  if (!localRef) {
    throw new Error(
      "localRef is required for SELL settlement"
    );
  }

  if (!transactionRef) {
    throw new Error(
      "transactionRef is required for SELL settlement"
    );
  }

  if (!userId) {
    throw new Error(
      `Cannot settle SELL ${transactionRef}: userId is missing`
    );
  }

  const payoutAmount =
    toPositiveNumber(amount);

  if (payoutAmount === null) {
    throw new Error(
      `Cannot settle SELL ${transactionRef}: invalid payout amount`
    );
  }

  const safeProviderReference =
    String(
      providerReference ||
        transactionRef
    ).trim();

  const walletRef =
    db
      .collection(
        WALLETS_COLLECTION
      )
      .doc(userId);

  const settlementRef =
    db
      .collection(
        SETTLEMENTS_COLLECTION
      )
      .doc(
        safeProviderReference
      );

  const walletTransactionId =
    `prestmit:sell:${safeProviderReference}`;

  return db.runTransaction(
    async (transaction) => {
      const [
        walletSnapshot,
        settlementSnapshot,
        localSnapshot,
      ] = await Promise.all([
        transaction.get(
          walletRef
        ),

        transaction.get(
          settlementRef
        ),

        transaction.get(
          localRef
        ),
      ]);

      /**
       * Already settled.
       */
      if (
        settlementSnapshot.exists
      ) {
        const settlementData =
          settlementSnapshot.data() ||
          {};

        return {
          credited: false,

          alreadyCredited: true,

          amount:
            Number(
              settlementData.amount
            ) ||
            payoutAmount,

          transactionId:
            settlementData.walletTransactionId ||
            walletTransactionId,

          newBalance:
            settlementData.newBalance ??
            null,
        };
      }

      if (!walletSnapshot.exists) {
        throw new Error(
          `Wallet does not exist for user ${userId}`
        );
      }

      if (!localSnapshot.exists) {
        throw new Error(
          `Local Prestmit SELL transaction ${transactionRef} no longer exists`
        );
      }

      const walletData =
        walletSnapshot.data() ||
        {};

      const currentBalance =
        Number(
          walletData.balance || 0
        );

      if (
        !Number.isFinite(
          currentBalance
        ) ||
        currentBalance < 0
      ) {
        throw new Error(
          `Wallet balance is invalid for user ${userId}`
        );
      }

      /**
       * Backward compatibility:
       * detect a previously completed wallet credit.
       */
      const existingTransactions =
        Array.isArray(
          walletData.transactions
        )
          ? walletData.transactions
          : [];

      const existingWalletTransaction =
        existingTransactions.find(
          (item) =>
            item?.id ===
              walletTransactionId ||
            item?.providerReference ===
              safeProviderReference
        );

      if (
        existingWalletTransaction
      ) {
        const now =
          admin.firestore.Timestamp.now();

        transaction.set(
          settlementRef,
          {
            provider:
              "prestmit",

            providerReference:
              safeProviderReference,

            userId,

            amount:
              payoutAmount,

            walletTransactionId,

            recoveredExistingCredit:
              true,

            createdAt:
              now,

            updatedAt:
              now,
          },
          {
            merge: true,
          }
        );

        transaction.update(
          localRef,
          {
            status:
              "COMPLETED",

            providerStatus:
              "COMPLETED",

            providerTrade:
              providerTrade ||
              null,

            providerPayout:
              payoutAmount,

            walletCredited:
              true,

            walletCreditAmount:
              payoutAmount,

            walletCreditTransactionId:
              walletTransactionId,

            completedAt:
              now,

            updatedAt:
              now,
          }
        );

        return {
          credited: false,

          alreadyCredited:
            true,

          recoveredExistingCredit:
            true,

          amount:
            payoutAmount,

          transactionId:
            walletTransactionId,

          newBalance:
            currentBalance,
        };
      }

      /**
       * Calculate new wallet balance.
       */
      const newBalance =
        currentBalance +
        payoutAmount;

      /**
       * Wallet transaction.
       */
      const walletTransaction = {
        id:
          walletTransactionId,

        type:
          "credit",

        title:
          `Gift Card Sale - ${
            giftCardTitle ||
            "Gift Card"
          }`,

        amount:
          payoutAmount.toString(),

        timestamp:
          Date.now(),

        status:
          "success",

        provider:
          "prestmit",

        providerReference:
          safeProviderReference,

        source:
          "prestmit_sell",
      };

      /**
       * Credit wallet.
       */
      transaction.update(
        walletRef,
        {
          balance:
            newBalance,

          transactions:
            admin.firestore.FieldValue.arrayUnion(
              walletTransaction
            ),

          updatedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        }
      );

      /**
       * Mark local SELL completed.
       */
      transaction.update(
        localRef,
        {
          status:
            "COMPLETED",

          providerStatus:
            "COMPLETED",

          providerTrade:
            providerTrade ||
            null,

          providerPayout:
            payoutAmount,

          walletCredited:
            true,

          walletCreditAmount:
            payoutAmount,

          walletCreditTransactionId:
            walletTransactionId,

          completedAt:
            admin.firestore.FieldValue.serverTimestamp(),

          updatedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        }
      );

      /**
       * Settlement idempotency marker.
       */
      transaction.create(
        settlementRef,
        {
          provider:
            "prestmit",

          providerReference:
            safeProviderReference,

          userId,

          localTransactionId:
            transactionRef,

          amount:
            payoutAmount,

          walletTransactionId,

          previousBalance:
            currentBalance,

          newBalance,

          createdAt:
            admin.firestore.FieldValue.serverTimestamp(),

          updatedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        }
      );

      return {
        credited:
          true,

        alreadyCredited:
          false,

        amount:
          payoutAmount,

        transactionId:
          walletTransactionId,

        previousBalance:
          currentBalance,

        newBalance,
      };
    }
  );
}

/**
 * ============================================================
 * SELL COMPLETION NOTIFICATION
 * ============================================================
 *
 * Sends the in-app notification and transaction email only once.
 * The notification flag is committed before the external send so
 * concurrent Prestmit webhooks cannot create duplicate notifications.
 * If the notification helper itself fails, the flag is reset so a
 * later webhook/requery can retry it.
 * ============================================================
 */
async function notifySellCompletion({
  localRef,
  userId,
  giftCardTitle,
  payout,
  reference,
}) {
  if (!localRef || !userId) {
    return;
  }

  let shouldSend = false;

  try {
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(localRef);

      if (!snapshot.exists) {
        return;
      }

      const data = snapshot.data() || {};

      if (
        String(data.status || "").toUpperCase() !==
        "COMPLETED"
      ) {
        return;
      }

      if (data.completionNotificationSent === true) {
        return;
      }

      transaction.update(localRef, {
        completionNotificationSent: true,
        completionNotificationSentAt:
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
    const amount = Number(payout || 0);
    const formattedAmount = amount.toLocaleString("en-NG", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    });

    await sendNotification(
      userId,
      "Gift Card Sale Completed",
      `Your ${title} sale was completed successfully. ₦${formattedAmount} has been credited to your GiftPay wallet.`,
      "giftcard"
    );

    console.log(
      `[PRESTMIT SELL] Completion notification sent for ${reference}`
    );
  } catch (error) {
    console.error(
      `[PRESTMIT SELL] Completion notification failed for ${reference}:`,
      error.message
    );

    try {
      await localRef.set(
        {
          completionNotificationSent: false,
          notificationError:
            error.message || "Completion notification failed",
          notificationRetryAt:
            admin.firestore.FieldValue.serverTimestamp(),
          updatedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    } catch (resetError) {
      console.error(
        `[PRESTMIT SELL] Could not reset completion notification flag for ${reference}:`,
        resetError.message
      );
    }
  }
}

/**
 * ============================================================
 * SELL REJECTION NOTIFICATION
 * ============================================================
 */
async function notifySellRejection({
  localRef,
  userId,
  giftCardTitle,
  rejectionReason,
  reference,
}) {
  if (!localRef || !userId) {
    return;
  }

  let shouldSend = false;

  try {
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(localRef);

      if (!snapshot.exists) {
        return;
      }

      const data = snapshot.data() || {};

      if (
        String(data.status || "").toUpperCase() !==
        "REJECTED"
      ) {
        return;
      }

      if (data.rejectionNotificationSent === true) {
        return;
      }

      transaction.update(localRef, {
        rejectionNotificationSent: true,
        rejectionNotificationSentAt:
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
    const reason =
      String(rejectionReason || "No rejection reason was provided.").trim();

    await sendNotification(
      userId,
      "Gift Card Sale Rejected",
      `Your ${title} sale was rejected. Reason: ${reason}`,
      "giftcard"
    );

    console.log(
      `[PRESTMIT SELL] Rejection notification sent for ${reference}`
    );
  } catch (error) {
    console.error(
      `[PRESTMIT SELL] Rejection notification failed for ${reference}:`,
      error.message
    );

    try {
      await localRef.set(
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
        `[PRESTMIT SELL] Could not reset rejection notification flag for ${reference}:`,
        resetError.message
      );
    }
  }
}

/**
 * ============================================================
 * PROCESS PRESTMIT SELL
 * ============================================================
 */
async function processPrestmitSell(
  reference
) {
  if (
    reference ===
      undefined ||
    reference === null ||
    String(reference).trim() === ""
  ) {
    throw new Error(
      "Prestmit SELL reference is required"
    );
  }

  const safeReference =
    String(reference).trim();

  /**
   * ----------------------------------------------------------
   * STEP 1
   * Find local GiftPay transaction.
   * ----------------------------------------------------------
   */
  const localTransaction =
    await findSellTransactionByReference(
      safeReference
    );

  if (!localTransaction) {
    console.warn(
      `[PRESTMIT SELL PROCESSOR] Local transaction not found for ${safeReference}`
    );

    return {
      reference:
        safeReference,

      processed:
        false,

      status:
        "NOT_FOUND",

      walletCredited:
        false,
    };
  }

  /**
   * ----------------------------------------------------------
   * STEP 2
   * Query Prestmit.
   * ----------------------------------------------------------
   */
  const providerResponse =
    await PrestmitSellService.getSellTransaction(
      safeReference
    );

  /**
   * ----------------------------------------------------------
   * DEBUG:
   * Show only structural information about the response.
   *
   * The service already sanitizes sensitive provider data.
   * ----------------------------------------------------------
   */
  console.log(
    "[PRESTMIT SELL PROCESSOR] Provider response structure:",
    JSON.stringify(
      {
        responseType:
          Array.isArray(
            providerResponse
          )
            ? "array"
            : typeof providerResponse,

        success:
          providerResponse?.success ??
          null,

        dataType:
          Array.isArray(
            providerResponse?.data
          )
            ? "array"
            : typeof providerResponse?.data,

        dataLength:
          Array.isArray(
            providerResponse?.data
          )
            ? providerResponse.data.length
            : null,

        reference:
          safeReference,
      },
      null,
      2
    )
  );

  /**
   * ----------------------------------------------------------
   * STEP 3
   * Extract exact trade.
   * ----------------------------------------------------------
   */
  const trade =
    extractTrade(
      providerResponse,
      safeReference
    );

  if (!trade) {
    throw new Error(
      `Prestmit SELL trade not found for ${safeReference}`
    );
  }

  /**
   * ----------------------------------------------------------
   * STEP 4
   * Normalize provider status.
   * ----------------------------------------------------------
   */
  const providerStatus =
    normalizeStatus(
      trade.status
    );

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
    localTransaction.data ||
    {};

  /**
   * ----------------------------------------------------------
   * PENDING
   * ----------------------------------------------------------
   */
  if (
    providerStatus ===
    "PENDING"
  ) {
    await localRef.update({
      status:
        "PENDING",

      providerStatus,

      providerTrade:
        trade,

      rejectionReason:
        null,

      updatedAt:
        admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      reference:
        safeReference,

      status:
        "PENDING",

      providerStatus,

      processed:
        true,

      walletCredited:
        false,
    };
  }

  /**
   * ----------------------------------------------------------
   * REJECTED / FAILED
   * ----------------------------------------------------------
   */
  if (
    providerStatus ===
      "REJECTED" ||
    providerStatus ===
      "FAILED"
  ) {
    await localRef.update({
      status:
        "REJECTED",

      providerStatus,

      rejectionReason,

      providerTrade:
        trade,

      walletCredited:
        false,

      updatedAt:
        admin.firestore.FieldValue.serverTimestamp(),
    });

    await notifySellRejection({
      localRef,
      userId: localData.userId,
      giftCardTitle:
        localData.giftCardName ||
        localData.cardType ||
        localData.brand ||
        "Gift Card",
      rejectionReason,
      reference: safeReference,
    });

    return {
      reference:
        safeReference,

      status:
        "REJECTED",

      providerStatus,

      rejectionReason,

      processed:
        true,

      walletCredited:
        false,
    };
  }

  /**
   * ----------------------------------------------------------
   * COMPLETED
   * ----------------------------------------------------------
   */
  if (
    providerStatus ===
    "COMPLETED"
  ) {
    /**
     * Prestmit's final payout is preferred.
     *
     * Screenshot/API result from the sandbox showed:
     *
     * totalAmount = 15030
     * payoutTotal = 15030
     *
     * Therefore the wallet should receive the provider
     * settlement amount, not amount × rate calculated locally.
     */
    const payout =
      providerPayout ??
      toPositiveNumber(
        localData.expectedPayout
      );

    if (
      payout === null
    ) {
      throw new Error(
        `Completed Prestmit SELL ${safeReference} has no valid payout amount`
      );
    }

    /**
     * Atomic wallet settlement.
     */
    const walletResult =
      await settleCompletedSell({
        localRef,

        transactionRef:
          localTransaction.id,

        userId:
          localData.userId,

        amount:
          payout,

        giftCardTitle:
          localData.giftCardName ||
          localData.cardType ||
          localData.brand ||
          "Gift Card",

        providerReference:
          safeReference,

        providerTrade:
          trade,
      });

    // This runs for both the first settlement and a later requery.
    // The Firestore notification flag prevents duplicate delivery and
    // allows an already-completed transaction to receive its missing
    // notification after this code is deployed.
    await notifySellCompletion({
      localRef,
      userId: localData.userId,
      giftCardTitle:
        localData.giftCardName ||
        localData.cardType ||
        localData.brand ||
        "Gift Card",
      payout,
      reference: safeReference,
    });

    return {
      reference:
        safeReference,

      status:
        "COMPLETED",

      providerStatus,

      processed:
        true,

      walletCredited:
        walletResult.credited,

      alreadyProcessed:
        walletResult.alreadyCredited,

      recoveredExistingCredit:
        walletResult.recoveredExistingCredit ||
        false,

      payout,

      walletTransactionId:
        walletResult.transactionId,

      newBalance:
        walletResult.newBalance,
    };
  }

  /**
   * ----------------------------------------------------------
   * UNKNOWN STATUS
   * ----------------------------------------------------------
   */
  await localRef.update({
    status:
      "PENDING",

    providerStatus,

    providerTrade:
      trade,

    updatedAt:
      admin.firestore.FieldValue.serverTimestamp(),
  });

  return {
    reference:
      safeReference,

    status:
      "PENDING",

    providerStatus,

    processed:
      true,

    walletCredited:
      false,
  };
}

/**
 * ============================================================
 * CREATE LOCAL SELL TRANSACTION
 * ============================================================
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
    throw new Error(
      "userId is required"
    );
  }

  if (!providerTrade?.reference) {
    throw new Error(
      "Prestmit SELL reference is missing"
    );
  }

  const reference =
    String(
      providerTrade.reference
    );

  const transactionRef =
    db
      .collection(
        COLLECTION
      )
      .doc();

  const now =
    admin.firestore.Timestamp.now();

  const normalizedGiftcardId =
    giftcardId !== undefined &&
    giftcardId !== null &&
    giftcardId !== ""
      ? Number(giftcardId)
      : null;

  const normalizedAmount =
    Number(
      amount ??
        providerTrade.units ??
        0
    );

  const normalizedRate =
    Number(
      rate ??
        providerTrade.rate ??
        providerTrade.giftcard?.rate ??
        0
    );

  const normalizedExpectedPayout =
    Number(
      expectedPayout ??
        providerTrade.totalAmount ??
        providerTrade.payoutTotal ??
        0
    );

  const normalizedProviderStatus =
    normalizeStatus(
      providerTrade.status
    );

  const record = {
    userId,

    provider:
      "prestmit",

    providerReference:
      reference,

    providerStatus:
      normalizedProviderStatus,

    status:
      "PENDING",

    giftcardId:
      Number.isInteger(
        normalizedGiftcardId
      )
        ? normalizedGiftcardId
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
      country ||
      null,

    cardType:
      cardType ||
      providerTrade.giftcard?.form ||
      null,

    amount:
      Number.isFinite(
        normalizedAmount
      )
        ? normalizedAmount
        : 0,

    rate:
      Number.isFinite(
        normalizedRate
      )
        ? normalizedRate
        : 0,

    expectedPayout:
      Number.isFinite(
        normalizedExpectedPayout
      )
        ? normalizedExpectedPayout
        : 0,

    payoutMethod:
      payoutMethod ||
      null,

    comments:
      comments ||
      null,

    uniqueIdentifier:
      uniqueIdentifier ||
      null,

    rejectionReason:
      providerTrade.rejectionReason ||
      null,

    providerTrade,

    walletCredited:
      false,

    completionNotificationSent:
      false,

    rejectionNotificationSent:
      false,

    walletCreditAmount:
      null,

    walletCreditTransactionId:
      null,

    providerPayout:
      null,

    createdAt:
      now,

    updatedAt:
      now,
  };

  await transactionRef.set(
    record
  );

  return {
    id:
      transactionRef.id,

    ...record,

    providerReference:
      reference,
  };
}

/**
 * ============================================================
 * EXPORTS
 * ============================================================
 */
module.exports = {
  COLLECTION,

  SETTLEMENTS_COLLECTION,

  processPrestmitSell,

  createLocalSellTransaction,

  findSellTransactionByReference,
};
