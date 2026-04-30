// backend/src/controllers/vendElectricity.controller.js
const axios = require("axios");
const admin = require("firebase-admin");

/**
 * ⭐ STEP 2 — VEND ELECTRICITY USING SAME requestId
 * Wallet is NOT touched here.
 */
exports.vendElectricityController = async (req, res) => {
  try {
    let {
      meterNumber,
      discoCode,
      amount,
      phone,
      meterType,
      userId,
      requestId, // ⭐ MUST COME FROM WALLET DEBIT
    } = req.body;

    // ⭐ SANITIZE ALL INPUTS
    meterNumber = String(meterNumber).trim();
    discoCode = String(discoCode).trim();
    amount = String(amount).trim();
    phone = String(phone).trim();
    meterType = String(meterType).trim();
    requestId = String(requestId).trim();
    userId = String(userId).trim();

    if (!meterNumber || !discoCode || !amount || !phone || !meterType || !userId || !requestId) {
      return res.status(400).json({
        status: false,
        message: "Missing required fields",
      });
    }

    const USER_ID = process.env.CLUBKONNECT_USERID;
    const API_KEY = process.env.CLUBKONNECT_APIKEY;

    const url =
      `https://www.nellobytesystems.com/APIElectricityV1.asp` +
      `?UserID=${encodeURIComponent(USER_ID)}` +
      `&APIKey=${encodeURIComponent(API_KEY)}` +
      `&ElectricCompany=${encodeURIComponent(discoCode)}` +
      `&MeterType=${encodeURIComponent(meterType)}` +
      `&MeterNo=${encodeURIComponent(meterNumber)}` +
      `&Amount=${encodeURIComponent(amount)}` +
      `&PhoneNo=${encodeURIComponent(phone)}` +
      `&RequestID=${encodeURIComponent(requestId)}`;

    console.log("⚡ CLEAN VEND URL:", url);

    const axiosResponse = await axios.get(url);
    const raw = axiosResponse.data;

    console.log("📨 RAW VEND RESPONSE:", raw);

    // ⭐ PRIMARY + FALLBACK STATUS FIELDS
    let status =
      raw?.orderstatus ||
      raw?.OrderStatus ||
      raw?.transactionstatus ||
      raw?.TransactionStatus ||
      raw?.statuscode ||
      raw?.status;

    // ⭐ SPECIAL CASE: TXN_HISTORY WRAPPER
    if (raw?.status === "TXN_HISTORY" && raw?.transactionstatus) {
      status = raw.transactionstatus;
    }

    // ⭐ SUCCESSFUL VENDING (ORDER_RECEIVED or ORDER_COMPLETED)
    if (
      status === "ORDER_RECEIVED" ||
      status === "ORDER_COMPLETED" ||
      status === "100" ||
      status === "200"
    ) {
      // ⭐ Extract CK fields
      const token = raw.metertoken || "";
      const customerName = raw.customer_name || "";
      const customerAddress = raw.customer_address || "";
      const productName = raw.productname || "";
      const meterNo = raw.meterno || meterNumber;
      const paymentOption = raw.paymentoption || "Wallet";

      // ⭐ SAVE TO FIRESTORE — MERGE MODE
      const txnRef = admin
        .firestore()
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .doc(requestId);

      await txnRef.set(
        {
          // ⭐ REQUIRED BY YOUR FLUTTER RECEIPT SCREEN
          id: requestId,
          type: "electricity",
          title: `Electricity Purchase (${meterNo})`,
          amount: Number(amount),
          meterNumber: meterNo,
          discoCode,
          meterType,
          phone,

          // ⭐ NEW FIELDS FOR RECEIPT
          token,
          customerName,
          customerAddress,
          productName,
          paymentOption,

          // ⭐ STATUS + TIMESTAMP
          status: "success",
          timestamp: Date.now(),

          // ⭐ RAW RESPONSE (useful for debugging)
          raw,
        },
        { merge: true } // ⭐ DO NOT OVERWRITE EXISTING FIELDS
      );

      return res.json({
        status: true,
        requestId,
        message: "Order received at CK.",
        raw,
      });
    }

    // ⭐ FAILED
    if (status === "FAILED" || status === "ORDER_FAILED") {
      return res.json({
        status: false,
        requestId,
        message: "Electricity vending failed at provider.",
        raw,
      });
    }

    // ⭐ UNKNOWN RESPONSE
    return res.json({
      status: false,
      requestId,
      message: "Unknown response from CK",
      raw,
    });

  } catch (err) {
    console.error("❌ VEND ELECTRICITY ERROR:", err.message);
    return res.status(500).json({
      status: false,
      message: "Server error vending electricity",
    });
  }
};
