const admin = require("firebase-admin");
const { requery } = require("../services/monnifyBills.service.js");
const { sendNotification } = require("../../utils/notify");
const FeeEngine = require("../../core/fees/fee_engine");

const db = admin.firestore();

function providerBody(response) {
  return response?.responseBody ?? response?.data ?? response ?? {};
}

function normalizeStatus(value) {
  return String(value || "").trim().toUpperCase();
}

exports.requeryElectricityController = async (req, res) => {
  try {
    const userId = String(req.body?.userId || "").trim();
    const reference = String(req.body?.requestId || req.body?.reference || "").trim();

    if (!userId || !reference) {
      return res.status(400).json({
        status: false,
        message: "Missing requestId/reference or userId",
      });
    }

    const txRef = db.collection("users").doc(userId).collection("transactions").doc(reference);
    const txSnap = await txRef.get();

    if (!txSnap.exists) {
      return res.status(404).json({ status: false, message: "Electricity transaction not found" });
    }

    const txn = txSnap.data() || {};
    const response = await requery(reference);
    const body = providerBody(response);
    const vendStatus = normalizeStatus(body?.vendStatus);

    if (vendStatus === "SUCCESS") {
      const cashback = Number(txn.cashback || FeeEngine.cashback("electricity", Number(txn.amount) || 0) || 0);
      const walletRef = db.collection("wallets").doc(userId);
      const walletDoc = await walletRef.get();
      const walletData = walletDoc.data() || {};
      const txs = Array.isArray(walletData.transactions) ? walletData.transactions : [];
      const updatedTxs = txs.map((item) =>
        item?.id === reference ? { ...item, status: "success" } : item
      );

      const walletUpdates = { transactions: updatedTxs };
      if (txn.status !== "success" && cashback > 0) {
        walletUpdates.balance = admin.firestore.FieldValue.increment(cashback);
        walletUpdates.transactions = admin.firestore.FieldValue.arrayUnion({
          id: `${reference}_cashback`,
          type: "credit",
          title: `Cashback: Electricity Purchase (${txn.meterNumber})`,
          amount: cashback,
          timestamp: Date.now(),
          status: "success",
        });
      }
      await walletRef.set(walletUpdates, { merge: true });

      await txRef.set(
        {
          status: "success",
          vendStatus,
          transactionReference: body?.transactionReference || txn.transactionReference || null,
          providerReference: body?.vendReference || txn.providerReference || reference,
          cashback,
          raw: response,
          updatedAt: Date.now(),
        },
        { merge: true }
      );

      await sendNotification(
        userId,
        "Electricity purchase successful",
        `Electricity purchase for meter ${txn.meterNumber || ""} was completed.`,
        "electricity"
      );

      return res.json({
        status: true,
        pending: false,
        requestId: reference,
        vendStatus,
        transactionReference: body?.transactionReference || txn.transactionReference || null,
        raw: response,
      });
    }

    if (vendStatus === "FAILED") {
      if (txn.status !== "refunded") {
        const walletRef = db.collection("wallets").doc(userId);
        const walletDoc = await walletRef.get();
        const walletData = walletDoc.data() || {};
        const txs = Array.isArray(walletData.transactions) ? walletData.transactions : [];
        const refundAmount = Number(txn.totalDebited || txn.amount || 0);
        const alreadyRefunded = txs.some((item) => item?.id === `${reference}_refund`);
        const updatedTxs = txs.map((item) =>
          item?.id === reference ? { ...item, status: "refunded" } : item
        );

        const refundTx = {
          id: `${reference}_refund`,
          type: "credit",
          title: `Refund: Electricity Purchase Failed (${txn.meterNumber || ""})`,
          amount: refundAmount,
          timestamp: Date.now(),
          status: "refunded",
        };

        await walletRef.set(
          {
            balance: alreadyRefunded
              ? Number(walletData.balance || 0)
              : Number(walletData.balance || 0) + refundAmount,
            transactions: alreadyRefunded
              ? updatedTxs
              : [...updatedTxs, refundTx],
          },
          { merge: true }
        );
      }

      await txRef.set(
        {
          status: "refunded",
          vendStatus,
          raw: response,
          updatedAt: Date.now(),
        },
        { merge: true }
      );

      return res.json({
        status: false,
        pending: false,
        refunded: true,
        requestId: reference,
        vendStatus,
        message: body?.message || body?.responseMessage || "Transaction failed, refund issued.",
        raw: response,
      });
    }

    return res.json({
      status: false,
      pending: true,
      requestId: reference,
      vendStatus: vendStatus || "IN_PROGRESS",
      message: "Electricity transaction is still processing.",
      raw: response,
    });
  } catch (err) {
    console.error("Monnify electricity requery error:", err);
    return res.status(err.status || 500).json({
      status: false,
      message: err.message || "Server error during electricity requery",
      provider: err.provider,
    });
  }
};
