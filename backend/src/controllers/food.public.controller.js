const admin = require("firebase-admin");
const db = admin.firestore();
const COLLECTION = "foodRestaurantSettings";

function fail(res, status, message) {
  return res.status(status).json({ status: false, message });
}

// Customer-safe profile endpoint; authMiddleware is applied by food.routes.js.
async function getPublicRestaurantProfile(_req, res) {
  try {
    const merchantUid = String(process.env.FOOD_MERCHANT_UID || "").trim();
    if (!merchantUid) return fail(res, 503, "Restaurant profile is not configured");
    const doc = await db.collection(COLLECTION).doc(merchantUid).get();
    const saved = doc.exists ? (doc.data() || {}) : {};
    return res.json({ status: true, settings: {
      restaurantName: String(saved.restaurantName || "GiftPay Food"),
      description: String(saved.description || ""),
      phone: String(saved.phone || ""),
      email: String(saved.email || ""),
      address: String(saved.address || ""),
      openingHours: String(saved.openingHours || ""),
      deliveryNotes: String(saved.deliveryNotes || ""),
      logoUrl: typeof saved.logoUrl === "string" ? saved.logoUrl : "",
      acceptingOrders: saved.acceptingOrders !== false,
    }});
  } catch (err) {
    console.error("Public restaurant profile error:", err.message || err);
    return fail(res, 500, "Unable to load restaurant profile");
  }
}
module.exports = { getPublicRestaurantProfile };
