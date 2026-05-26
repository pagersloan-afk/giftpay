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

    const txnRef = admin
      .firestore()
      .collection("users")
      .doc(userId)
      .collection("transactions")
      .doc(requestId);

    if (token && token.trim() !== "") {
      await txnRef.update({
        status: "success",
        token,
        raw,
      });

      return res.json({
        status: true,
        requestId,
        message: "Token available.",
        raw,
      });
    }

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
