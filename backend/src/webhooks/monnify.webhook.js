// backend/src/webhooks/monnify.webhook.js
//
// GiftPay Monnify webhook.
//
// Handles:
// 1. Reserved account collection notifications.
// 2. Single-transfer final-status callbacks.
//
// IMPORTANT:
// - server.js captures req.rawBody before express.json().
// - Collection accountReference is expected to be USER_<uid>.
// - Reserved-account SUCCESSFUL_TRANSACTION callbacks credit
//   the corresponding GiftPay wallet.
// - Duplicate collection callbacks are ignored atomically.
// - Deposit notification is sent only after a new deposit
//   has actually been credited.
// - Monnify deposits are also recorded in wallet.transactions
//   so existing history/recent-transaction systems can display them.

const crypto = require("crypto");
const admin = require("firebase-admin");

const { sendNotification } = require("../../utils/notify");

const db = admin.firestore();

// ============================================================
// SIGNATURE VALIDATION
// ============================================================

function validateMonnifySignature(req) {
  const signature = req.headers["monnify-signature"];

  if (!signature) {
    if (
      process.env.MONNIFY_BASE_URL ===
      "https://sandbox.monnify.com"
    ) {
      console.warn(
        "⚠️ Sandbox webhook received without signature."
      );

      return true;
    }

    console.warn(
      "⚠️ Monnify webhook received without signature."
    );

    return false;
  }

  const secretKey = process.env.MONNIFY_SECRET_KEY;

  if (!secretKey) {
    console.error(
      "❌ MONNIFY_SECRET_KEY is not configured."
    );

    return false;
  }

  if (!req.rawBody) {
    console.error(
      "❌ Monnify webhook raw body is missing."
    );

    return false;
  }

  const computed = crypto
    .createHmac("sha512", secretKey)
    .update(req.rawBody)
    .digest("hex");

  try {
    const computedBuffer = Buffer.from(
      computed,
      "utf8"
    );

    const signatureBuffer = Buffer.from(
      String(signature),
      "utf8"
    );

    if (
      computedBuffer.length !==
      signatureBuffer.length
    ) {
      return false;
    }

    return crypto.timingSafeEqual(
      computedBuffer,
      signatureBuffer
    );
  } catch (err) {
    console.error(
      "❌ Monnify signature comparison error:",
      err.message || err
    );

    return false;
  }
}

// ============================================================
// TRANSFER CALLBACK EXTRACTION
// ============================================================

function getTransferCallbackData(body) {
  const eventData =
    body?.eventData ||
    body?.data ||
    body?.responseBody ||
    body ||
    {};

  const reference =
    eventData?.reference ||
    body?.reference ||
    null;

  const status = String(
    eventData?.status ||
      body?.status ||
      ""
  )
    .trim()
    .toUpperCase();

  const documentedStatuses = new Set([
    "PENDING",
    "AWAITING_PROCESSING",
    "IN_PROGRESS",
    "PENDING_AUTHORIZATION",
    "OTP_EMAIL_DISPATCH_FAILED",
    "SUCCESS",
    "COMPLETED",
    "REVERSED",
    "FAILED",
    "EXPIRED",
  ]);

  return {
    reference,
    status: documentedStatuses.has(status)
      ? status
      : null,
    data: eventData,
  };
}

async function handleTransferStatusCallback(body) {
  const {
    reference,
    status,
    data,
  } = getTransferCallbackData(body);

  if (!reference || !status) {
    return {
      handled: false,
      reason: "NO_DOCUMENTED_TRANSFER_STATUS",
    };
  }

  const {
    reconcileMonnifyTransfer,
  } = require("../controllers/transfer.controller");

  const result =
    await reconcileMonnifyTransfer({
      reference,
      providerData: data,
      statusOverride: status,
    });

  return {
    handled: true,
    reference,
    status,
    result,
  };
}

// ============================================================
// COLLECTION ACCOUNT REFERENCE MAPPING
// ============================================================

function resolveUserId(accountReference) {
  if (typeof accountReference !== "string") {
    return null;
  }

  const prefix = "USER_";

  if (accountReference.startsWith(prefix)) {
    return accountReference.slice(
      prefix.length
    );
  }

  return accountReference;
}

// ============================================================
// COLLECTION WEBHOOK
// ============================================================

async function handleSuccessfulCollection(eventData) {
  // Monnify reserved-account SUCCESSFUL_TRANSACTION
  // payloads place the reserved account reference inside:
  //
  // eventData.product.reference
  //
  // Keep eventData.accountReference as a fallback in case
  // another Monnify collection payload supplies it there.

  const accountReference =
    eventData?.accountReference ||
    eventData?.product?.reference ||
    null;

  const amountPaid = eventData?.amountPaid;

  console.log(
    "🔎 MONNIFY COLLECTION DETAILS:",
    {
      accountReference,
      amountPaid,
      transactionReference:
        eventData.transactionReference || null,
      paymentReference:
        eventData.paymentReference || null,
      paymentDescription:
        eventData.paymentDescription || null,
    }
  );

  // ==========================================================
  // BASIC PAYLOAD VALIDATION
  // ==========================================================

  if (
    !accountReference ||
    amountPaid === undefined ||
    amountPaid === null
  ) {
    console.warn(
      "⚠️ SUCCESSFUL_TRANSACTION missing accountReference or amountPaid."
    );

    return {
      status: 400,
      message: "Invalid transaction payload",
    };
  }

  const amount = Number(amountPaid);

  if (
    !Number.isFinite(amount) ||
    amount <= 0
  ) {
    console.warn(
      "⚠️ Invalid collection amount:",
      amountPaid
    );

    return {
      status: 400,
      message: "Invalid amount",
    };
  }

  // ==========================================================
  // RESOLVE USER
  // ==========================================================

  const userId =
    resolveUserId(accountReference);

  if (!userId) {
    console.error(
      "❌ Could not resolve user ID from accountReference:",
      accountReference
    );

    return {
      status: 400,
      message: "Invalid account reference",
    };
  }

  // ==========================================================
  // MONNIFY TRANSACTION REFERENCE
  // ==========================================================

  const monnifyTransactionReference =
    eventData.transactionReference ||
    eventData.paymentReference;

  if (!monnifyTransactionReference) {
    console.error(
      "❌ Collection callback has no transaction reference."
    );

    return {
      status: 400,
      message: "Missing transaction reference",
    };
  }

  // ==========================================================
  // FIRESTORE REFERENCES
  // ==========================================================

  const processedRef = db
    .collection("monnify_processed_webhooks")
    .doc(
      `collection_${monnifyTransactionReference}`
    );

  const userRef = db
    .collection("users")
    .doc(userId);

  const walletRef = db
    .collection("wallets")
    .doc(userId);

  // ==========================================================
  // TRANSACTION HISTORY RECORD
  // ==========================================================
  //
  // This is the important addition.
  //
  // Existing Transaction History and Recent Transactions
  // both read wallet.transactions.
  //
  // The previous webhook updated the wallet balance but did
  // not create this transaction record.
  //
  // We create it inside the SAME Firestore transaction as
  // the balance update so the balance and history cannot get
  // out of sync.
  // ==========================================================

  const transactionTimestamp = Date.now();

  const walletTransaction = {
    id: monnifyTransactionReference,
    type: "credit",
    title: "Wallet Funding (Monnify)",
    amount,
    timestamp: transactionTimestamp,
    date: transactionTimestamp,
    status: "success",
    provider: "monnify",
    channel: "account_transfer",
    reference: monnifyTransactionReference,
    paymentReference:
      eventData.paymentReference ||
      monnifyTransactionReference,
    accountReference,
    currency: "NGN",
    paymentMethod:
      eventData.paymentMethod ||
      "ACCOUNT_TRANSFER",
  };

  // ==========================================================
  // ATOMIC WALLET CREDIT + HISTORY
  // ==========================================================
  //
  // Returns:
  //
  // { credited: false }
  //
  // when the webhook was already processed.
  //
  // This prevents both duplicate wallet credits and
  // duplicate history entries.
  // ==========================================================

  const creditResult =
    await db.runTransaction(
      async (transaction) => {
        const processedDoc =
          await transaction.get(
            processedRef
          );

        // ----------------------------------------------------
        // DUPLICATE WEBHOOK
        // ----------------------------------------------------

        if (processedDoc.exists) {
          console.log(
            "ℹ️ Duplicate collection webhook ignored:",
            monnifyTransactionReference
          );

          return {
            credited: false,
            reason: "already_processed",
          };
        }

        // ----------------------------------------------------
        // READ USER + WALLET
        // ----------------------------------------------------

        const userDoc =
          await transaction.get(
            userRef
          );

        const walletDoc =
          await transaction.get(
            walletRef
          );

        if (
          !userDoc.exists &&
          !walletDoc.exists
        ) {
          throw new Error(
            `No user or wallet document found for resolved userId: ${userId}`
          );
        }

        // ----------------------------------------------------
        // CREDIT USER DOCUMENT
        // ----------------------------------------------------

        if (userDoc.exists) {
          transaction.update(
            userRef,
            {
              walletBalance:
                admin.firestore.FieldValue.increment(
                  amount
                ),
            }
          );
        }

        // ----------------------------------------------------
        // CREDIT WALLET DOCUMENT
        // ----------------------------------------------------

        if (walletDoc.exists) {
          transaction.update(
            walletRef,
            {
              balance:
                admin.firestore.FieldValue.increment(
                  amount
                ),

              // IMPORTANT:
              // Add the Monnify deposit to the existing
              // wallet transaction history used by:
              //
              // - Transaction History screen
              // - Recent Transactions section
              // - /transaction-history backend endpoint
              //
              // arrayUnion prevents the exact same transaction
              // object from being inserted twice.
              transactions:
                admin.firestore.FieldValue.arrayUnion(
                  walletTransaction
                ),

              updatedAt:
                admin.firestore.Timestamp.now(),
            }
          );
        }

        // ----------------------------------------------------
        // RECORD PROCESSED WEBHOOK
        // ----------------------------------------------------

        transaction.create(
          processedRef,
          {
            type:
              "SUCCESSFUL_TRANSACTION",

            accountReference,

            resolvedUserId:
              userId,

            amount,

            monnifyTransactionReference,

            processedAt:
              admin.firestore.Timestamp.now(),
          }
        );

        return {
          credited: true,
        };
      }
    );

  // ==========================================================
  // DUPLICATE CALLBACK
  // ==========================================================

  if (!creditResult.credited) {
    return {
      status: 200,
      message: "OK",
    };
  }

  // ==========================================================
  // WALLET CREDIT CONFIRMED
  // ==========================================================

  console.log(
    `✅ Collection callback processed: ${userId} | ₦${amount} | ${monnifyTransactionReference}`
  );

  console.log(
    `🧾 Wallet transaction history recorded: ${monnifyTransactionReference}`
  );

  // ==========================================================
  // DEPOSIT NOTIFICATION
  // ==========================================================
  //
  // Existing GiftPay notification system handles:
  //
  // 1. In-app notification
  // 2. FCM push notification
  // 3. Transaction email when enabled by the user
  //
  // "wallet" is already treated by notify.js as a
  // transaction-notification category.
  //
  // Notification is deliberately AFTER the Firestore
  // transaction so the user is only notified after the
  // wallet credit and transaction history have committed.
  // ==========================================================

  try {
    await sendNotification(
      userId,
      "Wallet funded",
      `₦${amount.toLocaleString(
        "en-NG"
      )} has been added to your wallet`,
      "wallet"
    );

    console.log(
      `🔔 Deposit notification sent for ${userId} | ₦${amount}`
    );
  } catch (notificationError) {
    // Notification failure must NOT cause the Monnify
    // webhook to return an error after the wallet has
    // already been successfully credited.

    console.error(
      `⚠️ Monnify deposit notification failed for ${userId}:`,
      notificationError.message ||
        notificationError
    );
  }

  return {
    status: 200,
    message: "OK",
  };
}

// ============================================================
// MAIN MONNIFY WEBHOOK
// ============================================================

exports.monnifyWebhook = async (
  req,
  res
) => {
  console.log(
    "========================================"
  );

  console.log(
    "📩 MONNIFY WEBHOOK REQUEST"
  );

  console.log(
    "Received at:",
    new Date().toISOString()
  );

  console.log(
    "Method:",
    req.method
  );

  console.log(
    "URL:",
    req.originalUrl
  );

  console.log(
    "Content-Type:",
    req.headers["content-type"] ||
      "unknown"
  );

  console.log(
    "Signature present:",
    Boolean(
      req.headers["monnify-signature"]
    )
  );

  console.log(
    "Raw body captured:",
    Boolean(req.rawBody)
  );

  console.log(
    "Parsed body:",
    JSON.stringify(
      req.body || {},
      null,
      2
    )
  );

  console.log(
    "========================================"
  );

  try {
    // ========================================================
    // SIGNATURE VALIDATION
    // ========================================================

    const signatureValid =
      validateMonnifySignature(req);

    console.log(
      "Monnify signature validation:",
      signatureValid
        ? "PASSED"
        : "FAILED"
    );

    if (!signatureValid) {
      console.warn(
        "⚠️ Invalid Monnify webhook signature."
      );

      return res
        .status(401)
        .send(
          "Invalid signature"
        );
    }

    // ========================================================
    // PAYLOAD
    // ========================================================

    const body =
      req.body || {};

    const event =
      body.eventType || null;

    const eventData =
      body.eventData || {};

    console.log(
      `📩 Monnify event received: ${
        event || "UNNAMED_EVENT"
      }`
    );

    console.log(
      "Monnify event data:",
      JSON.stringify(
        eventData,
        null,
        2
      )
    );

    // ========================================================
    // RESERVED ACCOUNT COLLECTION
    // ========================================================

    if (
      event ===
      "SUCCESSFUL_TRANSACTION"
    ) {
      const result =
        await handleSuccessfulCollection(
          eventData
        );

      if (
        result.status !== 200
      ) {
        return res
          .status(result.status)
          .send(
            result.message
          );
      }

      return res.send(
        "OK"
      );
    }

    // ========================================================
    // SINGLE-TRANSFER FINAL STATUS
    // ========================================================

    const transferResult =
      await handleTransferStatusCallback(
        body
      );

    if (
      transferResult.handled
    ) {
      console.log(
        `✅ Monnify transfer reconciled: ${
          transferResult.reference
        } | ${
          transferResult.status
        }`
      );

      return res.send(
        "OK"
      );
    }

    // ========================================================
    // OTHER MONNIFY EVENTS
    // ========================================================

    console.log(
      `ℹ️ Monnify event received, but no documented transfer status was found: ${
        event || "UNNAMED_EVENT"
      }`
    );

    return res.send(
      "OK"
    );
  } catch (err) {
    console.error(
      "❌ Monnify webhook processing error:",
      err.response?.data ||
        err.message ||
        err
    );

    return res
      .status(500)
      .send(
        "Webhook processing failed"
      );
  }
};