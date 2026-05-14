// backend/src/controllers/electricityPay.controller.js
const {
  vendElectricity,
} = require("../services/clubkonnectElectricity.service");

const { db } = require("../config/firebase");

// Load BASE_URL from environment
const BASE_URL = process.env.BASE_URL || "http://localhost:4000";

exports.payElectricityController = async (req, res) => {
  try {
    const {
      userId,
      disco,
      meterNumber,
      meterType,
      amount,
      phone,
      customerName,
    } = req.body;

    console.log("\n==============================");
    console.log("⚡ ELECTRICITY PURCHASE REQUEST RECEIVED");
    console.log("==============================");
    console.log(req.body);

    if (!userId || !disco || !meterNumber || !meterType || !amount) {
      return res.status(400).json({
        status: false,
        message: "Missing required fields",
      });
    }

    // ⭐ 1) Debit wallet FIRST
    const userRef = db.collection("wallets").doc(userId);
    const userSnap = await userRef.get();

    if (!userSnap.exists) {
      return res.status(404).json({
        status: false,
        message: "Wallet not found",
      });
    }

    const wallet = userSnap.data();
    const balance = wallet.balance || 0;

    if (balance < amount) {
      return res.status(400).json({
        status: false,
        message: "Insufficient wallet balance",
      });
    }

    // Deduct amount
    await userRef.update({
      balance: balance - amount,
      transactions: [
        ...(wallet.transactions || []),
        {
          id: `WL-${Date.now()}`,
          type: "debit",
          title: `Electricity Purchase (${meterNumber})`,
          amount,
          status: "pending",
          timestamp: Date.now(),
        },
      ],
    });

    console.log("💰 Wallet debited successfully");

    // ⭐ 2) Call CK vending endpoint (ONE TIME ONLY)
    const callbackUrl = `${BASE_URL}/api/electricity/callback`;

    const { requestId, response } = await vendElectricity({
      disco,
      meterNumber,
      meterType,
      amount,
      phone,
      callbackUrl,
    });

    const orderId =
      response?.orderid ||
      response?.OrderID ||
      response?.orderId ||
      "";

    console.log("\n📌 CK VEND RETURNED:");
    console.log({ requestId, orderId });

    // ⭐ 3) Save pending electricity transaction
    await userRef.update({
      transactions: [
        ...(wallet.transactions || []),
        {
          id: `ELEC-${Date.now()}`,
          type: "debit",
          title: `Electricity Purchase (${meterNumber})`,
          amount,
          status: "pending",
          requestId,
          orderId,
          meterNumber,
          customerName,
          timestamp: Date.now(),
        },
      ],
    });

    console.log("💾 Pending electricity transaction saved");

    // ⭐ 4) Return to Flutter (Flutter will poll /requery)
    return res.json({
      status: "pending",
      message: "Order received. Waiting for token...",
      requestId,
      orderId,
    });
  } catch (err) {
    console.error("❌ ELECTRICITY PAY ERROR:", err.message);

    return res.status(500).json({
      status: false,
      message: "Electricity vending failed",
    });
  }
};
