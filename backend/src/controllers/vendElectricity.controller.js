const axios = require("axios");
const admin = require("firebase-admin");

exports.vendElectricityController = async (req, res) => {
  try {
    let {
      meterNumber,
      discoCode,
      amount,
      phone,
      meterType,
      userId,
      requestId,
      customerName,
    } = req.body;

    meterNumber = String(meterNumber).trim();
    discoCode = String(discoCode).trim();
    amount = String(amount).trim();
    phone = String(phone).trim();
    meterType = String(meterType).trim();
    requestId = String(requestId).trim();
    userId = String(userId).trim();
    customerName = customerName ? String(customerName).trim() : "";

    if (!meterNumber || !discoCode || !amount || !phone || !meterType || !userId || !requestId) {
      return res.status(400).json({
        status: false,
        message: "Missing required fields",
      });
    }

    const numericAmount = Number(amount) || 0;

    if (numericAmount < 1000) {
      return res.json({
        status: false,
        message: "Minimum electricity vend amount is ₦1000.",
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

    const axiosResponse = await axios.get(url);
    const raw = axiosResponse.data;

    const token = raw.metertoken || raw.Token || raw.token || "";
    const ckCustomerName = raw.customer_name || "";
    const ckCustomerAddress = raw.customer_address || "";
    const productName = raw.productname || "";
    const meterNo = raw.meterno || meterNumber;
    const paymentOption = raw.paymentoption || "Wallet";

    const finalCustomerName = customerName || ckCustomerName || "";

    const txnRef = admin
      .firestore()
      .collection("users")
      .doc(userId)
      .collection("transactions")
      .doc(requestId);

    // ⭐ ALWAYS MERGE FULL ELECTRICITY FIELDS
    await txnRef.set(
      {
        type: "electricity",
        meterNumber: meterNo,
        meterType,
        discoCode,
        phone,
        customerName: finalCustomerName,
        customerAddress: ckCustomerAddress,
        productName,
        paymentOption,
        raw,
        token,
        status: token ? "success" : "pending",
      },
      { merge: true }
    );

    if (token) {
      return res.json({
        status: true,
        requestId,
        message: "Electricity vend successful.",
        raw,
      });
    }

    return res.json({
      status: true,
      pending: true,
      requestId,
      message: "Order received. Awaiting token.",
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
