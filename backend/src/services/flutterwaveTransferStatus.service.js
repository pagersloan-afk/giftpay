const admin = require("firebase-admin");
const db = admin.firestore();

function normalizeFlutterwaveStatus(value) {
  const status = String(value || "")
    .trim()
    .toUpperCase()
    .replace(/^TRANSFER[._\s-]+/, "")
    .replace(/[.\s-]+/g, "_");
  if (["SUCCESS", "SUCCESSFUL", "COMPLETED"].includes(status)) return "SUCCESS";
  if (["FAILED", "REVERSED", "CANCELLED", "CANCELED", "EXPIRED"].includes(status)) return "FAILED";
  return "PENDING";
}

/**
 * Atomically records a Flutterwave transfer status and, for a first confirmed
 * failure, refunds the wallet exactly once. Final states cannot be overwritten
 * by delayed contradictory notifications. A failed transfer with a pending
 * refund can be retried safely when another failure notification arrives.
 */
async function applyFlutterwaveTransferStatus({ reference, providerData = {}, event = null }) {
  const transferReference = String(reference || "").trim();
  if (!transferReference) return { found: false, status: "PENDING" };

  const incomingStatus = normalizeFlutterwaveStatus(providerData.status || event);
  const transferRef = db.collection("flutterwave_transfers").doc(transferReference);
  let result = { found: false, status: incomingStatus, refunded: false, refundPending: false };

  await db.runTransaction(async (tx) => {
    const transferSnap = await tx.get(transferRef);
    if (!transferSnap.exists) return;

    const transfer = transferSnap.data() || {};
    const userId = String(transfer.userId || "").trim();
    if (!userId) {
      result = { found: true, status: transfer.status || incomingStatus, error: "TRANSFER_USER_MISSING" };
      return;
    }

    const walletRef = db.collection("wallets").doc(userId);
    const ledgerRef = db.collection("wallet_ledger").doc(`${transferReference}_refund`);
    const userTxRef = db.collection("users").doc(userId).collection("transactions").doc(transferReference);
    const [walletSnap, ledgerSnap] = await Promise.all([
      tx.get(walletRef),
      tx.get(ledgerRef),
    ]);

    const currentStatus = normalizeFlutterwaveStatus(transfer.status);
    // Never turn a confirmed success into a failure, or a confirmed failure
    // into a success based only on a later webhook/status response. A conflict
    // requires provider-side/manual reconciliation.
    if (currentStatus === "SUCCESS" && incomingStatus !== "SUCCESS") {
      result = { found: true, status: "SUCCESS", refunded: Boolean(transfer.refunded), conflict: incomingStatus };
      return;
    }
    if (currentStatus === "FAILED" && incomingStatus !== "FAILED") {
      result = { found: true, status: "FAILED", refunded: Boolean(transfer.refunded), conflict: incomingStatus };
      return;
    }

    let refunded = Boolean(transfer.refunded) || ledgerSnap.exists;
    let refundPending = false;
    const patch = {
      providerStatus: providerData.status || event || transfer.providerStatus || null,
      providerData: providerData || null,
      providerTransferId: providerData.id || transfer.providerTransferId || null,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (incomingStatus === "FAILED") {
      const amount = Number(transfer.totalDebited || 0);
      if (!refunded) {
        if (walletSnap.exists && Number.isFinite(amount) && amount > 0) {
          const balance = Number(walletSnap.data().balance || 0);
          tx.update(walletRef, {
            balance: Number((balance + amount).toFixed(2)),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          tx.create(ledgerRef, {
            userId,
            reference: transferReference,
            type: "bank_transfer_refund",
            amount,
            reason: providerData.complete_message || providerData.message || "Flutterwave transfer failed",
            status: "completed",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          refunded = true;
        } else {
          refundPending = true;
        }
      }
      patch.status = "FAILED";
      patch.refunded = refunded;
      patch.refundPending = refundPending;
      patch.failureReason = providerData.complete_message || providerData.message || transfer.failureReason || "Flutterwave transfer failed";
    } else {
      patch.status = incomingStatus;
      if (incomingStatus === "SUCCESS") {
        patch.refundPending = false;
      }
    }

    tx.set(transferRef, patch, { merge: true });
    tx.set(userTxRef, {
      status: patch.status,
      providerStatus: patch.providerStatus,
      ...(incomingStatus === "FAILED" ? { refunded, refundPending, failureReason: patch.failureReason } : {}),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    result = { found: true, status: patch.status, refunded, refundPending };
  });

  return result;
}

module.exports = { normalizeFlutterwaveStatus, applyFlutterwaveTransferStatus };
