// backend/src/jobs/requeryPendingTransactions.js
const axios = require("axios");
const admin = require("firebase-admin");
const cron = require("node-cron");

async function requeryPendingTransactions() {
  try {
    const db = admin.firestore();

    // 🔎 Find all pending electricity transactions
    const pendingSnap = await db.collectionGroup("transactions")
      .where("type", "==", "electricity")
      .where("status", "==", "pending")
      .get();

    if (pendingSnap.empty) {
      console.log("✅ No pending electricity transactions found.");
      return;
    }

    console.log(`🔄 Found ${pendingSnap.size} pending transactions.`);

    for (const doc of pendingSnap.docs) {
      const txnData = doc.data();
      const { id: requestId, userId } = txnData;

      if (!requestId || !userId) continue;

      const USER_ID = process.env.CLUBKONNECT_USERID;
      const API_KEY = process.env.CLUBKONNECT_APIKEY;

      const url =
        `https://www.nellobytesystems.com/APIQueryV1.asp` +
        `?UserID=${encodeURIComponent(USER_ID)}` +
        `&APIKey=${encodeURIComponent(API_KEY)}` +
        `&RequestID=${encodeURIComponent(requestId)}`;

      console.log("🔄 Requerying:", url);

      try {
        const axiosResponse = await axios.get(url);
        const raw = axiosResponse.data;

        const token = raw.metertoken || raw.Token || raw.token || "";
        const status = (raw.status || raw.statuscode || "").toString().toUpperCase();

        const txnRef = db
          .collection("users")
          .doc(userId)
          .collection("transactions")
          .doc(requestId);

        const walletRef = db.collection("wallets").doc(userId);
        const walletDoc = await walletRef.get();
        const walletData = walletDoc.exists ? walletDoc.data() : {};

        // ✅ Case 1: Token finally available
        if (token && token.trim() !== "") {
          await txnRef.update({
            status: "success",
            token,
            raw,
          });
          console.log(`✅ Token saved for ${requestId}`);
          continue;
        }

        // ✅ Case 2: Explicit failure → refund
        if (status.includes("FAILED") || status.includes("ERROR")) {
          const refundAmount = txnData?.totalDebited || txnData?.amount || 0;

          await walletRef.update({
            balance: (walletData.balance || 0) + refundAmount,
            transactions: admin.firestore.FieldValue.arrayUnion({
              id: `${requestId}_refund`,
              type: "credit",
              title: `Refund: Electricity Purchase Failed (${txnData.meterNumber})`,
              amount: refundAmount,
              timestamp: Date.now(),
              status: "refunded",
            }),
          });

          await txnRef.update({
            status: "refunded",
            raw,
          });

          console.log(`💸 Refund issued for ${requestId}`);
          continue;
        }

        // ✅ Case 3: Still pending
        console.log(`⏳ Transaction still pending: ${requestId}`);
      } catch (err) {
        console.error(`❌ Error requerying ${requestId}:`, err.message);
      }
    }
  } catch (err) {
    console.error("❌ Error in requeryPendingTransactions job:", err.message);
  }
}

// Schedule job every 10 minutes
cron.schedule("*/10 * * * *", async () => {
  console.log("🔄 Running electricity requery job...");
  await requeryPendingTransactions();
});

module.exports = { requeryPendingTransactions };
