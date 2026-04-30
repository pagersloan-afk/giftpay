// backend/src/controllers/transfer.controller.js
const axios = require("axios");
const admin = require("firebase-admin");
const FeeEngine = require("../../core/fees/fee_engine"); // ⭐ FEE ENGINE

// ===============================
// PAYSTACK CONFIG
// ===============================
const PAYSTACK_SECRET = process.env.PAYSTACK_SECRET;
const PAYSTACK_BASE_URL = process.env.PAYSTACK_BASE_URL || "https://api.paystack.co";

if (!PAYSTACK_SECRET) {
  console.warn("⚠️ PAYSTACK_SECRET is not set in environment variables.");
}

const paystack = axios.create({
  baseURL: PAYSTACK_BASE_URL,
  headers: {
    Authorization: `Bearer ${PAYSTACK_SECRET}`,
    "Content-Type": "application/json",
  },
});

// ===============================
// GET BANK LIST
// ===============================
exports.getBanks = async (req, res) => {
  try {
    const { country = "nigeria" } = req.query;

    const response = await paystack.get(`/bank?country=${country}`);
    const banks = response.data?.data || [];

    return res.json({
      status: true,
      data: banks.map((b) => ({
        name: b.name,
        code: b.code,
        slug: b.slug,
      })),
    });
  } catch (err) {
    console.error("❌ Paystack getBanks error:", err.response?.data || err.message);
    return res.status(500).json({
      status: false,
      message: "Failed to load banks",
    });
  }
};

// ===============================
// RESOLVE ACCOUNT NAME
// ===============================
exports.resolveAccount = async (req, res) => {
  try {
    const { bankCode, accountNumber } = req.body;

    if (!bankCode || !accountNumber) {
      return res.status(400).json({
        status: false,
        message: "Missing bankCode or accountNumber",
      });
    }

    const response = await paystack.get(
      `/bank/resolve?account_number=${encodeURIComponent(
        accountNumber
      )}&bank_code=${encodeURIComponent(bankCode)}`
    );

    const data = response.data?.data;

    if (!data) {
      return res.status(400).json({
        status: false,
        message: "Unable to resolve account",
      });
    }

    return res.json({
      status: true,
      data: {
        accountName: data.account_name,
        accountNumber: data.account_number,
        bankCode,
      },
    });
  } catch (err) {
    console.error("❌ Paystack resolveAccount error:", err.response?.data || err.message);
    return res.status(500).json({
      status: false,
      message: "Failed to resolve account",
    });
  }
};

// ===============================
// CREATE OR GET TRANSFER RECIPIENT
// ===============================
async function getOrCreateRecipient({ userId, bankCode, accountNumber, accountName }) {
  const db = admin.firestore();

  const ref = db
    .collection("users")
    .doc(userId)
    .collection("transferRecipients")
    .doc(`${bankCode}_${accountNumber}`);

  const doc = await ref.get();
  if (doc.exists && doc.data()?.recipientCode) {
    return doc.data().recipientCode;
  }

  const payload = {
    type: "nuban",
    name: accountName,
    account_number: accountNumber,
    bank_code: bankCode,
    currency: "NGN",
  };

  const response = await paystack.post("/transferrecipient", payload);
  const data = response.data?.data;

  if (!data || !data.recipient_code) {
    throw new Error("Failed to create transfer recipient");
  }

  await ref.set(
    {
      recipientCode: data.recipient_code,
      bankCode,
      accountNumber,
      accountName,
      createdAt: Date.now(),
    },
    { merge: true }
  );

  return data.recipient_code;
}

// ===============================
// TRANSFER TO BANK (WITH FEE ENGINE)
// ===============================
exports.transferToBank = async (req, res) => {
  try {
    const { userId, amount, bankCode, accountNumber, accountName, reason = "Wallet Cashout" } =
      req.body;

    if (!userId || !amount || !bankCode || !accountNumber || !accountName) {
      return res.status(400).json({
        status: false,
        message: "Missing required fields",
      });
    }

    const db = admin.firestore();
    const walletRef = db.collection("wallets").doc(userId);
    const walletDoc = await walletRef.get();

    if (!walletDoc.exists) {
      return res.status(404).json({
        status: false,
        message: "Wallet not found",
      });
    }

    const balance = Number(walletDoc.data().balance || 0);
    const amt = Number(amount);

    if (amt <= 0) {
      return res.status(400).json({
        status: false,
        message: "Invalid amount",
      });
    }

    // ⭐ Apply withdrawal fee via Fee Engine
    const feeResult = FeeEngine.withdrawal(amt);
    const debitAmount = feeResult.debitAmount; // amount + fee
    const fee = feeResult.fee;

    if (balance < debitAmount) {
      return res.status(400).json({
        status: false,
        message: "Insufficient wallet balance",
      });
    }

    // ⭐ LIVE MODE ONLY — NO SIMULATION
    const requestId = `TRF-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;

    const recipientCode = await getOrCreateRecipient({
      userId,
      bankCode,
      accountNumber,
      accountName,
    });

    const transferPayload = {
      source: "balance",
      amount: Math.round(amt * 100), // user withdrawal amount only
      recipient: recipientCode,
      reason,
      reference: requestId,
    };

    const transferResponse = await paystack.post("/transfer", transferPayload);
    const transferData = transferResponse.data?.data;

    if (!transferData) {
      return res.status(500).json({
        status: false,
        message: "Failed to initiate transfer",
      });
    }

    const newBalance = balance - debitAmount;

    const debitTx = {
      id: requestId,
      type: "debit",
      title: "Bank Transfer",
      amount: amt,
      fee, // ⭐ store fee separately
      totalDebited: debitAmount,
      timestamp: Date.now(),
      status: "success",
    };

    await walletRef.update({
      balance: newBalance,
      transactions: admin.firestore.FieldValue.arrayUnion(debitTx),
    });

    const txRef = db
      .collection("users")
      .doc(userId)
      .collection("transactions")
      .doc(requestId);

    await txRef.set(
      {
        id: requestId,
        type: "bank_transfer",
        title: `Transfer to ${accountName}`,
        amount: amt,
        fee,
        totalDebited: debitAmount,
        bankCode,
        accountNumber,
        accountName,
        reason,
        status: transferData.status || "pending",
        provider: "paystack",
        providerReference: transferData.reference,
        transferCode: transferData.transfer_code,
        timestamp: Date.now(),
        raw: transferData,
      },
      { merge: true }
    );

    return res.json({
      status: true,
      message: "Transfer initiated",
      requestId,
      newBalance,
      fee,
      debited: debitAmount,
    });
  } catch (err) {
    console.error("❌ transferToBank error:", err.response?.data || err.message);
    return res.status(500).json({
      status: false,
      message: "Server error initiating transfer",
    });
  }
};
