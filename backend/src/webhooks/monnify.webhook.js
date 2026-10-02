// backend/src/webhooks/monnify.webhook.js
//
// GiftPay Monnify webhook.
//
// This endpoint intentionally supports TWO separate concerns:
//
// 1. Existing Reserved Account collection notifications
//    - SUCCESSFUL_TRANSACTION remains unchanged.
//    - It credits the customer's GiftPay wallet.
//
// 2. Single-transfer final-status notifications
//    - We do NOT assume undocumented event names such as
//      SUCCESSFUL_DISBURSEMENT / FAILED_DISBURSEMENT.
//    - When a callback contains a documented transfer reference + status,
//      we reconcile it through the same idempotent logic used by the
//      transfer-status endpoint.
//
// Transaction Validation is NOT implemented here.
// Transaction Validation is a separate optional Monnify feature with its
// own X-Monnify-Signature / X-Monnify-Timestamp protocol and APPROVE/REJECT
// response. Keep that disabled until you explicitly enable it in Monnify.

const crypto = require("crypto");
const admin = require("firebase-admin");

const db = admin.firestore();

function validateMonnifySignature(req) {
  const signature = req.headers["monnify-signature"];

  // Preserve the existing GiftPay collection-webhook behavior in sandbox.
  // In production/live, Monnify signature validation is mandatory.
  if (!signature) {
    if (
      process.env.MONNIFY_BASE_URL ===
      "https://sandbox.monnify.com"
    ) {
      return true;
    }

    console.warn(
      "⚠️ Monnify webhook received without signature."
    );

    return false;
  }

  const secretKey =
    process.env.MONNIFY_SECRET_KEY;

  if (!secretKey) {
    console.error(
      "❌ MONNIFY_SECRET_KEY is not configured."
    );

    return false;
  }

  const rawBody =
    req.rawBody ||
    JSON.stringify(req.body);

  const computed = crypto
    .createHmac("sha512", secretKey)
    .update(rawBody)
    .digest("hex");

  try {
    const computedBuffer =
      Buffer.from(computed, "utf8");

    const signatureBuffer =
      Buffer.from(signature, "utf8");

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
      err.message
    );

    return false;
  }
}

// ------------------------------------------------------------
// Generic final-status extraction
// ------------------------------------------------------------
//
// The supplied Monnify documentation establishes the status values and
// states that async=true causes Monnify to send final status to the webhook.
// It does NOT establish event names such as SUCCESSFUL_DISBURSEMENT.
//
// Therefore we inspect the reference/status fields without depending on
// an assumed event name.
//
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

  // Import lazily so the webhook module keeps its normal Firebase behavior
  // and there is no controller/webhook initialization cycle.
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
// MAIN MONNIFY WEBHOOK
// ============================================================

exports.monnifyWebhook = async (
  req,
  res
) => {
  try {
    if (!validateMonnifySignature(req)) {
      console.warn(
        "⚠️ Invalid Monnify webhook signature."
      );

      return res
        .status(401)
        .send("Invalid signature");
    }

    const body =
      req.body || {};

    const event =
      body.eventType || null;

    const eventData =
      body.eventData || {};

    console.log(
      `📩 Monnify webhook received: ${event || "UNNAMED_EVENT"}`
    );

    // ========================================================
    // EXISTING RESERVED ACCOUNT COLLECTION FLOW
    // ========================================================
    //
    // This remains the same GiftPay wallet-credit flow.
    // It is intentionally checked before generic transfer status handling.
    // ========================================================

    if (
      event ===
      "SUCCESSFUL_TRANSACTION"
    ) {
      const {
        accountReference,
        amountPaid,
      } = eventData;

      if (
        !accountReference ||
        amountPaid ===
          undefined ||
        amountPaid === null
      ) {
        console.warn(
          "⚠️ SUCCESSFUL_TRANSACTION missing accountReference or amountPaid."
        );

        return res
          .status(400)
          .send("Invalid transaction payload");
      }

      const amount =
        Number(amountPaid);

      if (
        !Number.isFinite(amount) ||
        amount <= 0
      ) {
        console.warn(
          `⚠️ Invalid collection amount: ${amountPaid}`
        );

        return res
          .status(400)
          .send("Invalid amount");
      }

      // ======================================================
      // IDEMPOTENCY FOR COLLECTION
      // ======================================================
      //
      // Use Monnify's transactionReference where available.
      // This prevents a duplicated webhook from crediting
      // the customer's wallet twice.
      // ======================================================

      const monnifyTransactionReference =
        eventData.transactionReference ||
        eventData.paymentReference ||
        `${accountReference}_${amountPaid}`;

      const processedRef = db
        .collection(
          "monnify_processed_webhooks"
        )
        .doc(
          `collection_${monnifyTransactionReference}`
        );

      const processedDoc =
        await processedRef.get();

      if (processedDoc.exists) {
        console.log(
          `ℹ️ Duplicate collection webhook ignored: ${monnifyTransactionReference}`
        );

        return res.send("OK");
      }

      // ======================================================
      // CREDIT CUSTOMER WALLET
      // ======================================================

      const userRef = db
        .collection("users")
        .doc(accountReference);

      const walletRef = db
        .collection("wallets")
        .doc(accountReference);

      await db.runTransaction(
        async (transaction) => {
          const userDoc =
            await transaction.get(
              userRef
            );

          const walletDoc =
            await transaction.get(
              walletRef
            );

          /*
           * Preserve your existing users/{userId}
           * walletBalance architecture.
           */
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

          /*
           * If the separate wallets/{userId}
           * document exists, keep it synchronized too.
           *
           * This is important because the withdrawal
           * controller uses wallets/{userId}.balance.
           */
          if (walletDoc.exists) {
            transaction.update(
              walletRef,
              {
                balance:
                  admin.firestore.FieldValue.increment(
                    amount
                  ),

                updatedAt:
                  admin.firestore.Timestamp.now(),
              }
            );
          }

          transaction.create(
            processedRef,
            {
              type:
                "SUCCESSFUL_TRANSACTION",

              accountReference,

              amount,

              monnifyTransactionReference,

              processedAt:
                admin.firestore.Timestamp.now(),
            }
          );
        }
      );

      console.log(
        `✅ Customer wallet credited: ${accountReference} | ₦${amount}`
      );

      return res.send("OK");
    }



    // ========================================================
    // SINGLE-TRANSFER FINAL STATUS
    // ========================================================
    //
    // Do not check for assumed event names. If Monnify's async callback
    // contains a documented transfer status + reference, reconcile it.
    //
    // If the payload does not contain those fields, acknowledge it without
    // changing the wallet. The transfer-status API remains available for
    // deterministic reconciliation.
    // ========================================================

    const transferResult =
      await handleTransferStatusCallback(body);

    if (
      transferResult.handled
    ) {
      console.log(
        `✅ Monnify transfer reconciled: ${transferResult.reference} | ${transferResult.status}`
      );

      return res.send("OK");
    }

    console.log(
      `ℹ️ Monnify event received but no documented transfer status was found: ${event || "UNNAMED_EVENT"}`
    );

    return res.send("OK");
  } catch (err) {
    console.error(
      "❌ Monnify webhook processing error:",
      err.response?.data ||
        err.message
    );

    /*
     * Return 500 so Monnify can retry the webhook if processing failed.
     */
    return res
      .status(500)
      .send("Webhook processing failed");
  }
};
