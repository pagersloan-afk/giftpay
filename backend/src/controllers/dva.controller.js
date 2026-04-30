const axios = require("axios");
const admin = require("firebase-admin");

const PAYSTACK_SECRET = process.env.PAYSTACK_SECRET;
const PAYSTACK_BASE_URL = process.env.PAYSTACK_BASE_URL || "https://api.paystack.co";

const paystack = axios.create({
  baseURL: PAYSTACK_BASE_URL,
  headers: {
    Authorization: `Bearer ${PAYSTACK_SECRET}`,
    "Content-Type": "application/json",
  },
});

// ===============================================
// CREATE OR GET DEDICATED VIRTUAL ACCOUNT (DVA)
// ===============================================
exports.createOrGetDVA = async (req, res) => {
  try {
    const { userId, email, name } = req.body;

    if (!userId || !email || !name) {
      return res.status(400).json({
        status: false,
        message: "Missing userId, email or name",
      });
    }

    const db = admin.firestore();
    const userRef = db.collection("users").doc(userId);
    const userDoc = await userRef.get();

    // If user already has a virtual account, return it
    const existing = userDoc.data()?.virtualAccount;
    if (existing?.accountNumber && existing?.bankName) {
      return res.json({
        status: true,
        data: existing,
      });
    }

    // Create Paystack customer
    const customerResp = await paystack.post("/customer", {
      email,
      first_name: name,
      metadata: { userId },
    });

    const customer = customerResp.data?.data;
    if (!customer || !customer.customer_code) {
      return res.status(500).json({
        status: false,
        message: "Failed to create Paystack customer",
      });
    }

    // Create dedicated virtual account
    const dvaResp = await paystack.post("/dedicated_account", {
      customer: customer.customer_code,
      preferred_bank: "wema-bank", // You can remove this to let Paystack choose
      metadata: { userId },
    });

    const dva = dvaResp.data?.data;
    if (!dva || !dva.account_number) {
      return res.status(500).json({
        status: false,
        message: "Failed to create dedicated virtual account",
      });
    }

    const virtualAccount = {
      accountNumber: dva.account_number,
      bankName: dva.bank?.name || "Wema Bank",
      accountName: dva.account_name,
      provider: "paystack",
      customerCode: customer.customer_code,
      dedicatedAccountId: dva.id,
      createdAt: Date.now(),
    };

    await userRef.set({ virtualAccount }, { merge: true });

    return res.json({
      status: true,
      data: virtualAccount,
    });
  } catch (err) {
    console.error("❌ createOrGetDVA error:", err.response?.data || err.message);
    return res.status(500).json({
      status: false,
      message: "Failed to create virtual account",
    });
  }
};

// ===============================================
// WEBHOOK FOR VIRTUAL ACCOUNT CREDIT
// ===============================================
exports.dvaWebhook = async (req, res) => {
  try {
    const secret = process.env.PAYSTACK_WEBHOOK_SECRET;
    const signature = req.headers["x-paystack-signature"];

    // NOTE: You can add HMAC verification here for extra security

    const event = req.body;

    if (event.event !== "charge.success") {
      return res.status(200).send("ignored");
    }

    const metadata = event.data?.metadata || {};
    const userId = metadata.userId;

    if (!userId) {
      console.error("❌ Missing userId in metadata");
      return res.status(200).send("no user");
    }

    const amount = Number(event.data.amount || 0) / 100;
    if (amount <= 0) {
      return res.status(200).send("invalid amount");
    }

    const db = admin.firestore();
    const walletRef = db.collection("wallets").doc(userId);
    const walletDoc = await walletRef.get();

    const prevBalance = Number(walletDoc.data()?.balance || 0);
    const newBalance = prevBalance + amount;

    const txId = event.data.reference || `DVA-${Date.now()}`;

    const creditTx = {
      id: txId,
      type: "credit",
      title: "Virtual Account Funding",
      amount,
      timestamp: Date.now(),
      status: "success",
      provider: "paystack",
      channel: "virtual_account",
      raw: event.data,
    };

    await walletRef.set(
      {
        balance: newBalance,
        transactions: admin.firestore.FieldValue.arrayUnion(creditTx),
      },
      { merge: true }
    );

    return res.status(200).send("ok");
  } catch (err) {
    console.error("❌ dvaWebhook error:", err.response?.data || err.message);
    return res.status(200).send("error");
  }
};
