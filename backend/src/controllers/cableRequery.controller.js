// backend/src/controllers/cableRequery.controller.js
const axios = require("axios");
const admin = require("firebase-admin");

exports.requeryCableController = async (req, res) => {
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

    const axiosResponse = await axios.get(url);
    const raw = axiosResponse.data;

    // Log raw requery response
    console.log("===== CLUBKONNECT RAW CABLE REQUERY =====");
    console.log(JSON.stringify(raw, null, 2));
    console.log("=========================================");

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

    const isSuccess =
      status === "ORDER_COMPLETED" ||
      status === "200" ||
      status === "SUCCESS";

    const isFailed =
      status === "ORDER_FAILED" ||
      status === "FAILED";

    if (isSuccess) {
      txn.status = "success";
      transactions[txnIndex] = txn;

      await walletRef.update({ transactions });

      return res.json({
        status: true,
        message: "Cable transaction completed",
        raw,
      });
    }

    if (isFailed) {
      txn.status = "failed";

      const refundAmount = Number(
        txn.totalDebited ||
          (txn.amount + (txn.fee || 0))
      );

      const newBalance = Number(wallet.balance || 0) + refundAmount;

      transactions[txnIndex] = txn;

      await walletRef.update({
        balance: newBalance,
        transactions,
      });

      return res.json({
        status: false,
        message: "Cable transaction failed. Refunded.",
        refunded: refundAmount,
        raw,
      });
    }

    return res.json({
      status: false,
      message: "Pending",
      raw,
    });
  } catch (err) {
    console.error("Cable requery error:", err);
    return res.status(500).json({
      status: false,
      message: "Server error during cable requery",
    });
  }
};
