const admin = require("firebase-admin");
const { sendNotification } = require("../utils/notify");

// ===============================
// DEBIT WALLET
// ===============================
exports.debitWallet = async (req, res) => {
  try {
    const { userId, amount, title } = req.body;

    if (!userId || !amount || !title) {
      return res.status(400).json({
        status: false,
        message: "Missing userId, amount, or title",
      });
    }

    const walletRef = admin.firestore().collection("wallets").doc(userId);
    const doc = await walletRef.get();

    if (!doc.exists) {
      return res.status(404).json({
        status: false,
        message: "Wallet not found",
      });
    }

    const balance = Number(doc.data().balance || 0);
    const amt = Number(amount);

    if (balance < amt) {
      return res.status(400).json({
        status: false,
        message: "Insufficient balance",
      });
    }

    const newTransaction = {
      id: Date.now().toString(),
      type: "debit",
      title,
      amount: amt,
      timestamp: Date.now(),
      status: "success",
    };

    await walletRef.update({
      balance: balance - amt,
      transactions: admin.firestore.FieldValue.arrayUnion(newTransaction),
    });

    await sendNotification(
      userId,
      "Withdrawal successful",
      `₦${amt} has been debited from your wallet`,
      "wallet"
    );

    return res.json({
      status: true,
      message: "Withdrawal successful",
      newBalance: balance - amt,
    });
  } catch (err) {
    console.error("Wallet debit error:", err);
    return res.status(500).json({
      status: false,
      message: "Server error processing withdrawal",
    });
  }
};

// ===============================
// CREDIT WALLET
// ===============================
exports.creditWallet = async (req, res) => {
  try {
    const { userId, amount, reference, title = "Wallet Funding" } = req.body;

    if (!userId || !amount || !reference) {
      return res.status(400).json({
        status: false,
        message: "Missing userId, amount, or reference",
      });
    }

    const walletRef = admin.firestore().collection("wallets").doc(userId);
    const doc = await walletRef.get();

    const currentBalance = doc.exists ? Number(doc.data().balance || 0) : 0;

    const newTransaction = {
      id: reference,
      type: "credit",
      title,
      amount: amount.toString(),
      timestamp: Date.now(),
      status: "success",
    };

    if (!doc.exists) {
      await walletRef.set({
        balance: currentBalance + Number(amount),
        transactions: [newTransaction],
      });
    } else {
      await walletRef.update({
        balance: currentBalance + Number(amount),
        transactions: admin.firestore.FieldValue.arrayUnion(newTransaction),
      });
    }

    await sendNotification(
      userId,
      "Wallet funded",
      `₦${amount} has been added to your wallet`,
      "wallet"
    );

    return res.json({
      status: true,
      message: "Wallet credited",
    });
  } catch (err) {
    console.error("Wallet credit error:", err);
    return res.status(500).json({
      status: false,
      message: "Server error crediting wallet",
    });
  }
};
