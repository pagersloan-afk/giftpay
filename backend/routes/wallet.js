import express from "express";
import { db } from "../services/firestore.js";
import { sendNotification } from "../utils/notify.js";

const router = express.Router();

// ⭐ CREDIT WALLET AFTER PAYMENT VERIFICATION
router.post("/credit", async (req, res) => {
  try {
    const { userId, amount, reference } = req.body;

    if (!userId || !amount) {
      return res.status(400).json({
        status: false,
        message: "Missing userId or amount",
      });
    }

    const walletRef = db.collection("wallets").doc(userId);
    const doc = await walletRef.get();

    const currentBalance = doc.data()?.balance ?? 0;

    await walletRef.update({
      balance: currentBalance + Number(amount),
    });

    // ⭐ SEND NOTIFICATION
    await sendNotification(
      userId,
      "Wallet Funded",
      `Your wallet has been credited with ₦${amount}.`
    );

    return res.json({ status: true, message: "Wallet credited" });
  } catch (err) {
    return res.status(500).json({
      status: false,
      message: err.message,
    });
  }
});

export default router;
