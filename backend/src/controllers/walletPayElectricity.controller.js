// backend/src/controllers/walletPayElectricity.controller.js
const admin = require("firebase-admin");

exports.walletPayElectricityController = async (req, res) => {
  try {
    const { 
      userId, 
      meterNumber, 
      discoCode, 
      amount, 
      phone, 
      meterType 
    } = req.body;

    // ⭐ VALIDATION — MATCHES YOUR FLUTTER EXACTLY
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

    if (numericAmount < 1000) {
      return res.status(400).json({
        status: false,
        message: "Minimum electricity purchase is ₦1000.",
      });
    }

    const newBalance = wallet.balance - numericAmount;

    if (newBalance < 0) {
      return res.status(400).json({
        status: false,
        message: "Insufficient balance",
      });
    }

    const requestId = `WL-${Date.now()}`;

    // ⭐ CREATE PENDING TRANSACTION (OLD BEHAVIOR)
    const txn = {
      id: requestId,
      type: "debit",
      title: `Electricity Purchase (${meterNumber})`,
      amount: numericAmount,
      timestamp: Date.now(),
      status: "pending",

      meterNumber,
      meterType,
      discoCode,
      customerName: "",
      phone,
    };

    // ⭐ DEBIT WALLET
    await walletRef.update({ balance: newBalance });

    // ⭐ SAVE PENDING TRANSACTION
    await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .collection("transactions")
      .doc(requestId)
      .set(txn);

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
