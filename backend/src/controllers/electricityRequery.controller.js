// backend/src/controllers/electricityRequery.controller.js
const axios = require("axios");
const admin = require("firebase-admin");

/**
 * ⭐ STEP 3 — REQUERY CK UNTIL COMPLETED
 * Updates wallet transaction + refunds if needed.
 */
exports.requeryElectricityController = async (req, res) => {
  try {
    const { requestId, userId } = req.body;

    if (!requestId || !userId) {
      return res.status(400).json({
        status: false,
        message: "Missing requestId or userId",
      });
    }

    const USER_ID = process.env.CLUBKONNECT_USERID;
    const API_KEY = process.env.CLUBKONNECT_APIKEY;

    const url =
      `https://www.nellobytesystems.com/APIQueryV1.asp?UserID=${USER_ID}` +
      `&APIKey=${API_KEY}` +
      `&RequestID=${requestId}`;

    console.log("🔄 REQUERY URL:", url);

    const axiosResponse = await axios.get(url);
    const raw = axiosResponse.data;

    console.log("📨 RAW REQUERY RESPONSE:", raw);

    const status =
      raw?.status ||
      raw?.statuscode ||
      raw?.orderstatus ||
      raw?.OrderStatus;

    const walletRef = admin.firestore().collection("wallets").doc(userId);
    const walletDoc = await walletRef.get();

    if (!walletDoc.exists) {
      return res.status(400).json({
        status: false,
        message: "Wallet not found",
      });
    }

    const wallet = walletDoc.data();
    const transactions = wallet.transactions || [];

    const txnIndex = transactions.findIndex((t) => t.id === requestId);

    if (txnIndex === -1) {
      return res.status(400).json({
        status: false,
        message: "Transaction not found",
      });
    }

    const txn = transactions[txnIndex];

    // ⭐ SUCCESS
    if (status === "ORDER_COMPLETED" || status === "200") {
      txn.status = "success";
      transactions[txnIndex] = txn;

      await walletRef.update({ transactions });

      return res.json({
        status: true,
        requestId,
        message: "Transaction completed",
        raw,
      });
    }

    // ⭐ FAILED → REFUND FULL AMOUNT USER PAID (Fee Engine compatible)
    if (status === "ORDER_FAILED" || status === "FAILED") {
      txn.status = "failed";

      // ⭐ UPDATED: Refund totalDebited if available, else fallback to amount
      const refundAmount = Number(txn.totalDebited || txn.amount);

      const newBalance = wallet.balance + refundAmount;

      transactions[txnIndex] = txn;

      await walletRef.update({
        balance: newBalance,
        transactions,
      });

      return res.json({
        status: false,
        requestId,
        message: "Transaction failed. Refunded.",
        refunded: refundAmount,
        raw,
      });
    }

    // ⭐ STILL PENDING
    return res.json({
      status: false,
      requestId,
      message: "Pending",
      raw,
    });
  } catch (err) {
    console.error("❌ REQUERY ERROR:", err.message);
    return res.status(500).json({
      status: false,
      message: "Server error during requery",
    });
  }
};
