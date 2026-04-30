// backend/src/utils/saveElectricityToken.js
const { db } = require("../config/firebase");

/**
 * Save token + units into the user's wallet transaction.
 * This is called AFTER CK callback + APIQueryV1 returns the token.
 */
exports.saveElectricityToken = async ({
  userId,
  requestId,
  orderId,
  token,
  units,
}) => {
  try {
    console.log("\n==============================");
    console.log("💾 SAVING ELECTRICITY TOKEN TO FIRESTORE");
    console.log("==============================");
    console.log({ userId, requestId, orderId, token, units });

    const userRef = db.collection("wallets").doc(userId);
    const userSnap = await userRef.get();

    if (!userSnap.exists) {
      console.log("❌ Wallet not found for user:", userId);
      return false;
    }

    const wallet = userSnap.data();
    const transactions = wallet.transactions || [];

    // Find the pending electricity transaction
    const index = transactions.findIndex(
      (t) =>
        (t.requestId && t.requestId === requestId) ||
        (t.orderId && t.orderId === orderId)
    );

    if (index === -1) {
      console.log("❌ No matching pending transaction found");
      return false;
    }

    // Update transaction
    transactions[index].status = "success";
    transactions[index].token = token;
    transactions[index].units = units;
    transactions[index].completedAt = Date.now();

    // Save back to Firestore
    await userRef.update({ transactions });

    console.log("✅ Token saved successfully");
    return true;
  } catch (err) {
    console.error("❌ ERROR SAVING TOKEN:", err.message);
    return false;
  }
};
