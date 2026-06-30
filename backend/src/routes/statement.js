const express = require("express");
const router = express.Router();
const admin = require("firebase-admin");

router.get("/", async (req, res) => {
  try {
    console.log("📡 Incoming /v1/statement request");

    const userId = req.user?.uid;
    console.log("➡️ Authenticated userId:", userId);

    if (!userId) {
      console.log("❌ No userId found in req.user");
      return res.status(401).json({ error: "Unauthorized" });
    }

    const { start, end } = req.query;
    console.log("➡️ Query params:", { start, end });

    if (!start || !end) {
      console.log("❌ Missing start or end date");
      return res.status(400).json({ error: "Start and end dates are required" });
    }

    const startDate = new Date(start).getTime();
    const endDate = new Date(end).getTime();

    console.log("➡️ Parsed dates:", { startDate, endDate });

    const db = admin.firestore();
    const allTx = [];

    // ⭐ WALLET TRANSACTIONS
    console.log("📡 Fetching wallet transactions...");
    const walletDoc = await db.collection("wallets").doc(userId).get();
    const walletData = walletDoc.data() || {};
    const walletTx = walletData.transactions || [];

    console.log(`➡️ Wallet transactions found: ${walletTx.length}`);

    walletTx.forEach((tx) => {
      if (tx.timestamp >= startDate && tx.timestamp <= endDate) {
        allTx.push({
          id: tx.id,
          type: tx.type,
          title: tx.title,
          amount: tx.amount,
          fee: tx.fee || 0,
          totalDebited: tx.totalDebited || tx.amount,
          status: tx.status,
          date: new Date(tx.timestamp).toISOString(),
          source: "wallet",
        });
      }
    });

    // ⭐ USERS TRANSACTIONS
    console.log("📡 Fetching users/{userId}/transactions...");
    const userTxSnap = await db
      .collection("users")
      .doc(userId)
      .collection("transactions")
      .where("timestamp", ">=", startDate)
      .where("timestamp", "<=", endDate)
      .get();

    console.log(`➡️ User transactions found: ${userTxSnap.size}`);

    userTxSnap.forEach((doc) => {
      const tx = doc.data();
      allTx.push({
        id: doc.id,
        type: tx.type,
        title: tx.title,
        amount: tx.amount,
        fee: tx.fee || 0,
        totalDebited: tx.totalDebited || tx.amount,
        status: tx.status,
        date: new Date(tx.timestamp).toISOString(),
        source: "users",
      });
    });

    // ⭐ Sort
    allTx.sort((a, b) => new Date(b.date) - new Date(a.date));

    console.log(`📦 FINAL TRANSACTION COUNT: ${allTx.length}`);

    return res.json({
      count: allTx.length,
      transactions: allTx,
    });

  } catch (err) {
    console.error("❌ Statement error:", err);
    return res.status(500).json({ error: "Failed to generate statement" });
  }
});

module.exports = router;
