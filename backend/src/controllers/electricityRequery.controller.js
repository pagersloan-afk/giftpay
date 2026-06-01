// backend/src/controllers/electricityRequery.controller.js
const axios = require("axios");
const admin = require("firebase-admin");

exports.requeryElectricityController = async (req, res) => {
  try {
    let { requestId, userId } = req.body;

    requestId = String(requestId || "").trim();
    userId = String(userId || "").trim();

    if (!requestId || !userId) {
      return res.status(400).json({
        status: false,
        message: "Missing requestId or userId",
      });
    }

    const USER_ID = process.env.CLUBKONNECT_USERID;
    const API_KEY = process.env.CLUBKONNECT_APIKEY;

    const url =
      `https://www.nellobytesystems.com/APIQueryV1.asp` +
      `?UserID=${encodeURIComponent(USER_ID)}` +
      `&APIKey=${encodeURIComponent(API_KEY)}` +
      `&RequestID=${encodeURIComponent(requestId)}`;

    console.log("🔄 REQUERY URL:", url);

    const axiosResponse = await axios.get(url);
    const raw = axiosResponse.data;

    console.log("📨 RAW REQUERY RESPONSE:", raw);

    const token = raw.metertoken || raw.Token || raw.token || "";
    const status = (raw.status || raw.statuscode || "").toString().toUpperCase();

    const db = admin.firestore();
    const txnRef = db
      .collection("users")
      .doc(userId)
      .collection("transactions")
      .doc(requestId);

    const txnDoc = await txnRef.get();
    const txnData = txnDoc.exists ? txnDoc.data() : {};

    const walletRef = db.collection("wallets").doc(userId);
    const walletDoc = await walletRef.get();
    const walletData = walletDoc.exists ? walletDoc.data() : {};

    // ✅ Case 1: Token finally available
    if (token && token.trim() !== "") {
      await txnRef.update({
        status: "success",
        token,
        raw,
      });

      return res.json({
        status: true,
        requestId,
        message: "Token available and saved.",
        token,
        raw,
      });
    }

    // ✅ Case 2: Explicit failure
    if (status.includes("FAILED") || status.includes("ERROR")) {
      const refundAmount = txnData?.totalDebited || txnData?.amount || 0;

      await walletRef.update({
        balance: (walletData.balance || 0) + refundAmount,
        transactions: admin.firestore.FieldValue.arrayUnion({
          id: `${requestId}_refund`,
          type: "credit",
          title: `Refund: Electricity Purchase Failed (${txnData.meterNumber})`,
          amount: refundAmount,
          timestamp: Date.now(),
          status: "refunded",
        }),
      });

      await txnRef.update({
        status: "refunded",
        raw,
      });

      return res.json({
        status: false,
        requestId,
        message: "Transaction failed, refund issued.",
        raw,
      });
    }

    // ✅ Case 3: Still pending
    return res.json({
      status: false,
      requestId,
      message: "Pending, no token yet.",
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
