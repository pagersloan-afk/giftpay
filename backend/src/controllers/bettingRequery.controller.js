// backend/src/controllers/bettingRequery.controller.js

const axios = require("axios");
const admin = require("firebase-admin");

exports.requeryBettingController = async (req, res) => {
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
      `https://www.nellobytesystems.com/APIQueryV1.asp?UserID=${encodeURIComponent(USER_ID)}` +
      `&APIKey=${encodeURIComponent(API_KEY)}` +
      `&RequestID=${encodeURIComponent(requestId)}`;

    console.log("[BETTING REQUERY][REQUEST]", {
      requestId,
      hasUserId: !!USER_ID,
      hasApiKey: !!API_KEY,
    });

    const axiosResponse = await axios.get(url, {
      timeout: 30000,
      validateStatus: () => true,
    });

    const raw = axiosResponse.data;

    console.log(
      "[BETTING REQUERY][HTTP STATUS]",
      axiosResponse.status
    );

    console.log(
      "[BETTING REQUERY][RESPONSE]",
      raw
    );

    const status = String(
      raw?.status ||
        raw?.statuscode ||
        raw?.orderstatus ||
        raw?.OrderStatus ||
        ""
    ).toUpperCase();

    const walletRef = admin
      .firestore()
      .collection("wallets")
      .doc(userId);

    const walletDoc = await walletRef.get();

    if (!walletDoc.exists) {
      return res.status(400).json({
        status: false,
        message: "Wallet not found",
      });
    }

    const wallet = walletDoc.data();
    const transactions = wallet.transactions || [];

    const txnIndex = transactions.findIndex(
      (t) => t.id === requestId || t.requestId === requestId
    );

    if (txnIndex === -1) {
      return res.status(400).json({
        status: false,
        message: "Transaction not found",
        requestId,
      });
    }

    const txn = transactions[txnIndex];

    // ============================================================
    // COMPLETED
    // ============================================================

    if (
      status === "ORDER_COMPLETED" ||
      status === "200"
    ) {
      txn.status = "success";
      transactions[txnIndex] = txn;

      await walletRef.update({
        transactions,
      });

      return res.json({
        status: true,
        pending: false,
        message: "Betting transaction completed",
        requestId,
        raw,
      });
    }

    // ============================================================
    // FAILED
    // ============================================================

    if (
      status === "ORDER_FAILED" ||
      status === "FAILED"
    ) {
      // Prevent accidental double refund.
      if (txn.status === "refunded" || txn.status === "failed") {
        return res.json({
          status: false,
          pending: false,
          message: "Betting transaction already processed",
          requestId,
          raw,
        });
      }

      const refundAmount = Number(
        txn.totalDebited || txn.amount || 0
      );

      txn.status = "failed";
      transactions[txnIndex] = txn;

      await walletRef.update({
        balance:
          admin.firestore.FieldValue.increment(refundAmount),

        transactions: [
          ...transactions,
          {
            id: `${requestId}_refund`,
            type: "credit",
            title: "Refund: Betting Wallet Funding Failed",
            amount: refundAmount,
            timestamp: Date.now(),
            status: "refunded",
          },
        ],
      });

      return res.json({
        status: false,
        pending: false,
        message:
          "Betting transaction failed. Your wallet has been refunded.",
        refunded: refundAmount,
        requestId,
        raw,
      });
    }

    // ============================================================
    // STILL PENDING
    // ============================================================

    return res.json({
      status: false,
      pending: true,
      message: "Pending",
      requestId,
      raw,
    });
  } catch (err) {
    console.error("[BETTING REQUERY][SERVER ERROR]", {
      message: err.message,
      code: err.code,
      status: err.response?.status,
      response: err.response?.data,
    });

    return res.status(500).json({
      status: false,
      message: "Server error during betting requery",
    });
  }
};