// backend/src/controllers/userServices.controller.js

const admin = require("firebase-admin");

// =========================
// Save user service layout
// =========================
exports.saveUserServices = async (req, res) => {
  try {
    const db = admin.firestore(); // ⭐ moved inside function

    const { userId, services } = req.body;

    if (!userId || !Array.isArray(services)) {
      return res.status(400).json({
        status: false,
        message: "Missing userId or services array",
      });
    }

    await db.collection("user_services").doc(userId).set(
      {
        services,
        updatedAt: Date.now(),
      },
      { merge: true }
    );

    return res.json({ status: true });
  } catch (err) {
    console.error("Save user services error:", err);
    return res.status(500).json({
      status: false,
      message: "Server error saving services layout",
    });
  }
};

// =========================
// Load user service layout
// =========================
exports.loadUserServices = async (req, res) => {
  try {
    const db = admin.firestore(); // ⭐ moved inside function

    const { userId } = req.params;

    const doc = await db.collection("user_services").doc(userId).get();

    if (!doc.exists) {
      return res.json({ status: true, services: null });
    }

    return res.json({
      status: true,
      services: doc.data().services || null,
    });
  } catch (err) {
    console.error("Load user services error:", err);
    return res.status(500).json({
      status: false,
      message: "Server error loading services layout",
    });
  }
};
