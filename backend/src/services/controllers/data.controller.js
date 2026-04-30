import admin from "firebase-admin";
import axios from "axios";
import { sendNotification } from "../../../utils/notify.js";

const USER_ID = process.env.CLUBKONNECT_USERID;
const API_KEY = process.env.CLUBKONNECT_APIKEY;

// ======================================================
// BUY DATA BUNDLE (DIRECT, NOT WALLET)
// ======================================================
export const buyDataController = async (req, res) => {
  try {
    const { networkCode, planId, phone, userId } = req.query;

    if (!networkCode || !planId || !phone || !userId) {
      return res.status(400).json({
        status: false,
        message: "Missing required fields",
      });
    }

    const requestId = `DB-${Date.now()}`;

    const url =
      `https://www.nellobytesystems.com/APIDatabundleV1.asp?UserID=${USER_ID}` +
      `&APIKey=${API_KEY}&MobileNetwork=${networkCode}` +
      `&DataPlan=${planId}&MobileNumber=${phone}&RequestID=${requestId}`;

    const response = await axios.get(url);
    const data = response.data;

    await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .collection("transactions")
      .doc(requestId)
      .set({
        type: "data",
        phone,
        planId,
        networkCode,
        requestId,
        orderId: data.orderid || null,
        status: data.status || "PENDING",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        raw: data,
      });

    await sendNotification(
      userId,
      "Data Purchase Successful",
      `Data plan ${planId} purchased for ${phone}.`
    );

    return res.json({
      status: true,
      requestId,
      orderId: data.orderid,
      raw: data,
    });
  } catch (err) {
    console.error("Data bundle error:", err);
    return res.status(500).json({
      status: false,
      message: "Server error processing data bundle",
    });
  }
};

// ======================================================
// FETCH DATA PLANS (LOGGED VERSION, USING AXIOS)
// ======================================================
export const fetchDataPlansController = async (req, res) => {
  try {
    const network = req.params.network;

    console.log("\n\n================= FETCH DATA PLANS =================");
    console.log("📡 Requested Network:", network);

    const url = `https://www.nellobytesystems.com/APIDatabundlePlansV2.asp?UserID=${USER_ID}`;
    console.log("📡 ClubKonnect URL:", url);

    const response = await axios.get(url);
    const raw = response.data;

    console.log("\n📨 RAW RESPONSE FROM CLUBKONNECT (PLANS):");
    console.log(JSON.stringify(raw, null, 2));

    const networks = raw["MOBILE_NETWORK"];

    if (!networks) {
      return res.json({
        status: false,
        message: "Invalid response from provider",
      });
    }

    const normalized = {};
    for (const key in networks) {
      normalized[key.toLowerCase()] = networks[key];
    }

    const lookupKey = Object.keys(normalized).find(
      (k) => k.toLowerCase() === network.toLowerCase()
    );

    if (!lookupKey) {
      return res.json({
        status: false,
        message: `No plans found for network: ${network}`,
        availableKeys: Object.keys(normalized),
      });
    }

    const networkArray = normalized[lookupKey];
    const products = networkArray[0]?.PRODUCT || [];

    console.log("✅ Plans found:", products.length);

    return res.json({
      status: true,
      plans: products,
    });
  } catch (err) {
    console.error("❌ FETCH DATA PLANS ERROR:", err);
    return res.status(500).json({
      status: false,
      message: "Error fetching data plans",
    });
  }
};

// ======================================================
// QUERY DATA TRANSACTION
// ======================================================
export const queryDataController = async (req, res) => {
  try {
    const { requestId, orderId } = req.query;

    if (!requestId && !orderId) {
      return res.status(400).json({
        status: false,
        message: "Provide requestId or orderId",
      });
    }

    const url =
      `https://www.nellobytesystems.com/APIQueryV1.asp?UserID=${USER_ID}` +
      `&APIKey=${API_KEY}&${requestId ? `RequestID=${requestId}` : `OrderID=${orderId}`}`;

    const response = await axios.get(url);
    const data = response.data;

    return res.json({ status: true, raw: data });
  } catch (err) {
    return res.status(500).json({
      status: false,
      message: "Query error",
    });
  }
};

// ======================================================
// CANCEL DATA TRANSACTION
// ======================================================
export const cancelDataController = async (req, res) => {
  try {
    const { orderId } = req.query;

    if (!orderId) {
      return res.status(400).json({
        status: false,
        message: "Missing orderId",
      });
    }

    const url =
      `https://www.nellobytesystems.com/APICancelV1.asp?UserID=${USER_ID}` +
      `&APIKey=${API_KEY}&OrderID=${orderId}`;

    const response = await axios.get(url);
    const data = response.data;

    return res.json({ status: true, raw: data });
  } catch (err) {
    return res.status(500).json({
      status: false,
      message: "Cancel error",
    });
  }
};
