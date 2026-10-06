const admin = require("firebase-admin");
const { processReservedAccount } = require("../services/deposit-monitor.service");
const db = admin.firestore();

exports.syncMyDeposits = async (req, res) => {
  try {
    const userId = req.user?.uid;
    if (!userId) return res.status(401).json({ status: false, message: "Unauthorized" });
    const user = await db.collection("users").doc(userId).get();
    const accountReference = user.data()?.virtualAccount?.reference;
    if (!accountReference) {
      return res.status(404).json({ status: false, message: "No reserved account is linked to this user" });
    }
    const result = await processReservedAccount(userId, accountReference);
    return res.json({ status: true, message: "Deposit synchronization completed", data: result });
  } catch (e) {
    console.error("Manual deposit sync error:", e.response?.data || e.message || e);
    return res.status(502).json({ status: false, message: "Unable to synchronize deposits right now" });
  }
};
