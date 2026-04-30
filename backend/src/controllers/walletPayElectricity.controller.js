// backend/src/controllers/walletPayElectricity.controller.js
const admin = require("firebase-admin");

/**
 * ⭐ STEP 1 — WALLET DEBIT + CREATE PENDING TRANSACTION
 * This is the ONLY place where wallet is debited.
 * Vending controller MUST NOT debit wallet again.
 */
exports.walletPayElectricityController = async (req, res) => {
  try {
    const { userId, meterNumber, discoCode, amount, phone, meterType } = req.body;

    if (!userId || !meterNumber || !discoCode || !amount || !phone || !meterType) {
      return res.status(400).json({
        status: false,
        message: "Missing required fields",
      });
    }

    const walletRef = admin.firestore().collection("wallets").doc(userId);
    const walletDoc = await walletRef.get();

    if (!walletDoc.exists) {
      return res.status(400).json({
        status: false,
        message: "Wallet not found",
      });
    }

    const wallet = walletDoc.data();
    const numericAmount = Number(amount);

    if (numericAmount <= 0 || Number.isNaN(numericAmount)) {
      return res.status(400).json({
        status: false,
        message: "Invalid amount",
      });
    }

    const newBalance = wallet.balance - numericAmount;

    if (newBalance < 0) {
      return res.status(400).json({
        status: false,
        message: "Insufficient balance",
      });
    }

    // ⭐ SINGLE SOURCE OF TRUTH — requestId used for CK vending + requery
    const requestId = `WL-${Date.now()}`;

    const txn = {
      id: requestId,
      type: "debit",
      title: `Electricity Purchase (${meterNumber})`,
      amount: numericAmount,
      timestamp: Date.now(),
      status: "pending",
    };

    await walletRef.update({
      balance: newBalance,
      transactions: admin.firestore.FieldValue.arrayUnion(txn),
    });

    return res.json({
      status: true,
      pending: true,
      requestId,
      message: "Wallet debited. Proceed to vending.",
    });
  } catch (err) {
    console.error("❌ WALLET PAY ERROR:", err.message);
    return res.status(500).json({
      status: false,
      message: "Server error processing wallet payment",
    });
  }
};
