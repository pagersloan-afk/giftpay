const dotenv = require("dotenv");
dotenv.config();

const express = require("express");
const cors = require("cors");
const axios = require("axios");
const admin = require("firebase-admin");
const fs = require("fs");

// Route modules
const electricityRoutes = require("./src/routes/electricity.routes.js");
const airtimeRoutes = require("./src/routes/airtime.routes.js");
const dataRoutes = require("./src/routes/data.routes.js");
const walletRoutes = require("./src/routes/wallet.routes.js");
const transactionRoutes = require("./src/routes/transaction.routes");
const transferRoutes = require("./src/routes/transfer.routes");
const dvaRoutes = require("./src/routes/dva.routes");
const cableRoutes = require("./src/routes/cable.routes");
const bettingRoutes = require("./src/routes/betting.routes.js");


const app = express();
const PORT = process.env.PORT || 4000;

// ENV
const PAYSTACK_SECRET = process.env.PAYSTACK_SECRET;
const VTPASS_API_KEY = process.env.VTPASS_API_KEY;
const VTPASS_SECRET_KEY = process.env.VTPASS_SECRET_KEY;
const FIREBASE_SERVICE_ACCOUNT_PATH = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;

// VTPASS base URL
const VTPASS_BASE_URL =
  process.env.VTPASS_ENV === "sandbox"
    ? "https://sandbox.vtpass.com/api"
    : "https://vtpass.com/api";

// Debug ENV (masked)
const mask = (str) =>
  str ? str.substring(0, 3) + "***" + str.substring(str.length - 3) : "undefined";

console.log("VTPASS_API_KEY:", mask(VTPASS_API_KEY));
console.log("VTPASS_SECRET_KEY:", mask(VTPASS_SECRET_KEY));
console.log("VTPASS_ENV:", process.env.VTPASS_ENV);

// Firebase init
if (!admin.apps.length) {
  const serviceAccount = JSON.parse(
    fs.readFileSync(FIREBASE_SERVICE_ACCOUNT_PATH, "utf8")
  );

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

// Middleware
app.use(
  cors({
    origin: [
      "http://localhost:5000",
      "http://127.0.0.1:5000",
      "http://172.23.8.53:5000",
      "http://localhost",
      "http://127.0.0.1",
    ],
    methods: ["GET", "POST"],
    credentials: true,
  })
);

app.use(express.json());

// =========================
// Health check
// =========================
app.get("/", (req, res) => {
  res.json({ status: "ok", message: "UtilityHub backend running" });
});

// =========================
// Core routes
// =========================
app.use("/", transactionRoutes);
app.use("/", walletRoutes);

// ClubKonnect / VTPass feature routes
app.use("/api/electricity", electricityRoutes);
app.use("/api/airtime", airtimeRoutes);
app.use("/api/data", dataRoutes);
app.use("/api/cable", cableRoutes);
app.use("/api/betting", bettingRoutes);

// Transfers
app.use("/api/transfer", transferRoutes);

// Paystack Dedicated Virtual Account routes
app.use("/paystack", dvaRoutes);

// =========================
// Paystack: Initialize Transaction
// =========================
app.post("/paystack/initialize", async (req, res) => {
  try {
    const { email, amount, reference, userId } = req.body;

    if (!email || !amount || !userId) {
      return res.status(400).json({
        status: false,
        message: "Missing email, amount, or userId",
      });
    }

    const body = {
      email,
      amount, // already in kobo from frontend
      callback_url: `http://localhost:5000/payment-success.html?userId=${userId}`,
    };

    if (reference) {
      body.reference = reference;
    }

    const response = await axios.post(
      "https://api.paystack.co/transaction/initialize",
      body,
      {
        headers: {
          Authorization: `Bearer ${PAYSTACK_SECRET}`,
          "Content-Type": "application/json",
        },
      }
    );

    const data = response.data;

    if (!data?.status) {
      return res.status(400).json({
        status: false,
        message: data?.message || "Failed to initialize Paystack transaction",
        raw: data,
      });
    }

    return res.json({
      status: true,
      authorization_url: data.data.authorization_url,
      reference: data.data.reference,
    });
  } catch (err) {
    console.error("Paystack initialize error:", err.message || err);
    return res.status(500).json({
      status: false,
      message: "Server error initializing transaction",
    });
  }
});

// =========================
// Paystack: Verify Transaction (Future-Proof Funding)
// =========================
app.get("/verify/:ref", async (req, res) => {
  const ref = req.params.ref;
  const userId = req.query.userId;

  if (!ref) {
    return res.status(400).json({
      status: false,
      message: "Missing reference",
    });
  }

  try {
    const response = await axios.get(
      `https://api.paystack.co/transaction/verify/${ref}`,
      {
        headers: {
          Authorization: `Bearer ${PAYSTACK_SECRET}`,
          "Content-Type": "application/json",
        },
      }
    );

    const data = response.data;

    if (!data || !data.status || !data.data) {
      return res.status(400).json({
        status: false,
        message: data?.message || "Invalid Paystack response",
      });
    }

    const paystackStatus = data.data.status;
    const amountKobo = data.data.amount;
    const amountNaira = amountKobo / 100;

    // ⭐ AUTO-DETECT FUNDING METHOD
    const channel = data.data.channel || "card"; // fallback
    const method = channel === "bank" ? "bank" : "card";

    // ⭐ APPLY FEE ENGINE
    const FeeEngine = require("./core/fees/fee_engine");
    const feeResult = FeeEngine.walletFunding(method, amountNaira);

    const userPays = feeResult.userPays; // amount + fee
    const fee = feeResult.fee;

    // ⭐ CREDIT WALLET IF SUCCESSFUL
    if (paystackStatus === "success" && userId) {
      const walletRef = db.collection("wallets").doc(userId);
      const walletDoc = await walletRef.get();

      const prevBalance = Number(walletDoc.data()?.balance || 0);
      const newBalance = prevBalance + amountNaira; // user receives full amount

      const creditTx = {
        id: ref,
        type: "credit",
        title: "Wallet Funding (Paystack)",
        amount: amountNaira,
        fee,               // ⭐ store fee
        totalDebited: userPays, // ⭐ store total user paid
        timestamp: Date.now(),
        status: "success",
        provider: "paystack",
        channel: method,
      };

      await walletRef.set(
        {
          balance: newBalance,
          transactions: admin.firestore.FieldValue.arrayUnion(creditTx),
        },
        { merge: true }
      );
    }

    return res.json({
      status: true,
      data: {
        status: paystackStatus,
        amount: amountNaira,
        fee,
        totalDebited: userPays,
        method,
      },
    });
  } catch (err) {
    return res.status(500).json({
      status: false,
      message: "Server error verifying transaction",
    });
  }
});


// =========================
// Airtime Requery
// =========================
app.post("/api/airtime/requery", async (req, res) => {
  const { requestId } = req.body;

  const { requeryAirtime } = require("./src/services/clubkonnectAirtime.service.js");
  const data = await requeryAirtime({ requestId });

  const status =
    data?.orderstatus ||
    data?.status ||
    data?.statuscode ||
    data?.data?.orderstatus ||
    data?.data?.status ||
    data?.data?.statuscode;

  const remark =
    data?.remark ||
    data?.orderremark ||
    data?.data?.remark ||
    data?.data?.orderremark ||
    "Airtime purchase processed";

  const wallets = await db.collection("wallets").get();

  let userId = null;
  let walletRef = null;

  wallets.forEach((doc) => {
    const txns = doc.data().transactions || [];
    if (txns.some((t) => t.id === requestId)) {
      userId = doc.id;
      walletRef = db.collection("wallets").doc(userId);
    }
  });

  if (!walletRef) {
    return res.json(data);
  }

  const walletDoc = await walletRef.get();
  const walletData = walletDoc.data();
  const transactions = walletData.transactions || [];

  const txn = transactions.find((t) => t.id === requestId);
  if (!txn) return res.json(data);

  if (status === "ORDER_COMPLETED" || status === "200") {
    txn.status = "success";

    await walletRef.update({ transactions });

    return res.json({
      status: "ORDER_COMPLETED",
      remark,
    });
  }

  if (status === "ORDER_FAILED" || status === "FAILED") {
    txn.status = "failed";

    await walletRef.update({
      balance: walletData.balance + txn.amount,
      transactions: admin.firestore.FieldValue.arrayUnion({
        id: `${requestId}_refund`,
        type: "credit",
        title: `Refund: Airtime Purchase Failed (${txn.title})`,
        amount: txn.amount,
        timestamp: Date.now(),
        status: "refunded",
      }),
    });

    return res.json({
      status: "ORDER_FAILED",
      remark,
    });
  }

  return res.json(data);
});

// =========================
// Airtime Networks (ClubKonnect)
// =========================
app.get("/api/airtime/networks", async (req, res) => {
  try {
    const USER_ID = process.env.CLUBKONNECT_USERID;
    const url = `https://www.nellobytesystems.com/APIAirtimeDiscountV2.asp?UserID=${USER_ID}`;

    const response = await axios.get(url);
    const raw = response.data;

    if (!raw?.MOBILE_NETWORK) {
      return res.status(400).json({
        status: false,
        message: "Invalid response from ClubKonnect",
        raw,
      });
    }

    const networks = {};
    const mobileNetworks = raw.MOBILE_NETWORK;

    for (const key in mobileNetworks) {
      const arr = mobileNetworks[key];
      if (!Array.isArray(arr) || arr.length === 0) continue;

      const item = arr[0];

      const name =
        item.PRODUCT_NAME ||
        item.network ||
        key.replace("m_", "").replace("_", "").trim();

      const code = item.ID;

      if (name && code) {
        networks[name] = code;
      }
    }

    return res.json({
      status: true,
      networks,
    });
  } catch (err) {
    return res.status(500).json({
      status: false,
      message: "Failed to fetch networks",
    });
  }
});

// =========================
// Data Requery
// =========================
app.get("/api/data/requery/:requestId", async (req, res) => {
  try {
    const requestId = req.params.requestId;

    const USER_ID = process.env.CLUBKONNECT_USERID;
    const API_KEY = process.env.CLUBKONNECT_APIKEY;

    const url = `https://www.nellobytesystems.com/APIQueryV1.asp?UserID=${USER_ID}&APIKey=${API_KEY}&RequestID=${requestId}`;

    const response = await axios.get(url);
    const raw = response.data;

    return res.json({
      status: true,
      data: raw,
    });
  } catch (err) {
    return res.json({ status: false, message: "Requery failed" });
  }
});

// =========================
// Save FCM Token
// =========================
app.post("/save-fcm-token", async (req, res) => {
  const { userId, token } = req.body;

  if (!userId || !token) {
    return res
      .status(400)
      .json({ status: false, message: "Missing userId or token" });
  }

  await db.collection("users").doc(userId).update({
    fcmToken: token,
  });

  return res.json({ status: true, message: "Token saved" });
});

// =========================
// Start server
// =========================
app.listen(PORT, "0.0.0.0", () => {
  console.log(`UtilityHub backend running on http://0.0.0.0:${PORT}`);
});
