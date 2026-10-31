const admin = require("firebase-admin");

const db = admin.firestore();
const COLLECTION = "foodRestaurantSettings";

function fail(res, status, message) {
  return res.status(status).json({
    status: false,
    message,
  });
}

// Returns the public restaurant profile, including the merchant UID
// required by the Flutter food-item chat feature.
async function getPublicRestaurantProfile(req, res) {
  try {
    // The food detail screen supplies the owner of the selected menu item.
    // Never fall back to FOOD_MERCHANT_UID: that points every customer at
    // the pre-multi-merchant restaurant profile.
    const merchantUid = String(req.query.merchantUid || "").trim();
    if (!merchantUid || merchantUid.length > 180) {
      return fail(res, 400, "A valid merchantUid is required");
    }

    // Only expose profiles belonging to an approved, active merchant.
    const merchantDoc = await db.collection("foodMerchants").doc(merchantUid).get();
    if (!merchantDoc.exists) {
      return fail(res, 404, "Restaurant not found");
    }
    const merchant = merchantDoc.data() || {};
    if (merchant.status !== "approved" || merchant.isActive === false) {
      return fail(res, 404, "Restaurant not found");
    }

    const doc = await db.collection(COLLECTION).doc(merchantUid).get();
    const saved = doc.exists ? doc.data() || {} : {};

    return res.json({
      status: true,
      settings: {
        // Required by the Flutter chat feature.
        merchantUid,

        restaurantName: String(
          saved.restaurantName || "GiftPay Food"
        ),
        description: String(saved.description || ""),
        phone: String(saved.phone || ""),
        email: String(saved.email || ""),
        address: String(saved.address || ""),
        openingHours: String(saved.openingHours || ""),
        deliveryNotes: String(saved.deliveryNotes || ""),

        logoUrl:
          typeof saved.logoUrl === "string"
            ? saved.logoUrl
            : "",

        facebookUrl:
          typeof saved.facebookUrl === "string"
            ? saved.facebookUrl
            : "",

        instagramUrl:
          typeof saved.instagramUrl === "string"
            ? saved.instagramUrl
            : "",

        tiktokUrl:
          typeof saved.tiktokUrl === "string"
            ? saved.tiktokUrl
            : "",

        linkedinUrl:
          typeof saved.linkedinUrl === "string"
            ? saved.linkedinUrl
            : "",

        youtubeUrl:
          typeof saved.youtubeUrl === "string"
            ? saved.youtubeUrl
            : "",

        xUrl:
          typeof saved.xUrl === "string"
            ? saved.xUrl
            : "",

        acceptingOrders: saved.acceptingOrders !== false,
      },
    });
  } catch (err) {
    console.error(
      "Public restaurant profile error:",
      err.message || err
    );

    return fail(
      res,
      500,
      "Unable to load restaurant profile"
    );
  }
}

module.exports = {
  getPublicRestaurantProfile,
};
