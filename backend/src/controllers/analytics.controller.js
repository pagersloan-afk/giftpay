// backend/src/controllers/analytics.controller.js

const admin = require("firebase-admin");

exports.logServiceUsage = async (req, res) => {
  try {
    const db = admin.firestore(); // ⭐ moved inside function

    const { userId, serviceName, device } = req.body;

    if (!userId || !serviceName) {
      return res.status(400).json({
        status: false,
        message: "Missing userId or serviceName",
      });
    }

    await db.collection("service_usage").add({
      userId,
      serviceName,
      device: device || "unknown",
      timestamp: Date.now(),
    });

    return res.json({ status: true });
  } catch (err) {
    console.error("Service usage analytics error:", err);
    return res.status(500).json({
      status: false,
      message: "Server error logging service usage",
    });
  }
};
