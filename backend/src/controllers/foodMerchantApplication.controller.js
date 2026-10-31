const admin = require("firebase-admin");

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

function uidOf(req) {
  return req.user && req.user.uid ? String(req.user.uid) : "";
}

function clean(value) {
  return String(value ?? "").trim();
}

function fail(res, status, message) {
  return res.status(status).json({ status: false, message });
}

function lengthBetween(value, min, max) {
  return value.length >= min && value.length <= max;
}

// POST /api/food/merchant/apply
// Applications are never approved by this endpoint. A trusted admin review
// process must verify the registration details and supporting evidence.
async function applyForFoodMerchant(req, res) {
  const uid = uidOf(req);
  if (!uid) return fail(res, 401, "Authentication required");

  const legalOwnerName = clean(req.body?.legalOwnerName);
  const restaurantName = clean(req.body?.restaurantName);
  const businessType = clean(req.body?.businessType);
  const registrationType = clean(req.body?.registrationType);
  const registrationNumber = clean(req.body?.registrationNumber).toUpperCase();
  const phone = clean(req.body?.phone);
  const businessEmail = clean(req.body?.businessEmail).toLowerCase();
  const address = clean(req.body?.address);
  const foodSafetyPermitNumber = clean(req.body?.foodSafetyPermitNumber);
  const description = clean(req.body?.description);

  if (!lengthBetween(legalOwnerName, 2, 120)) {
    return fail(res, 400, "Enter the owner's full legal name");
  }
  if (!lengthBetween(restaurantName, 2, 120)) {
    return fail(res, 400, "Business / restaurant name must be between 2 and 120 characters");
  }
  if (!["sole_proprietorship", "partnership", "limited_company", "other"].includes(businessType)) {
    return fail(res, 400, "Select a valid business type");
  }
  if (!["CAC", "government", "other"].includes(registrationType)) {
    return fail(res, 400, "Select the business registration authority");
  }
  if (!lengthBetween(registrationNumber, 3, 80)) {
    return fail(res, 400, "Enter a valid business registration number");
  }
  if (!lengthBetween(phone, 7, 30)) {
    return fail(res, 400, "A valid business phone number is required");
  }
  if (businessEmail && (businessEmail.length > 254 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(businessEmail))) {
    return fail(res, 400, "Enter a valid business email address");
  }
  if (!lengthBetween(address, 5, 300)) {
    return fail(res, 400, "Enter the full physical business address");
  }
  if (foodSafetyPermitNumber.length > 100) {
    return fail(res, 400, "Food safety permit number is too long");
  }
  if (description.length > 1000) {
    return fail(res, 400, "Business description must not exceed 1000 characters");
  }

  try {
    const ref = db.collection("foodMerchants").doc(uid);
    const existing = await ref.get();

    if (existing.exists) {
      const current = existing.data() || {};
      if (current.status === "approved" && current.isActive === true) {
        return res.json({
          status: true,
          applicationStatus: "approved",
          message: "This merchant account is already approved",
        });
      }
      if (current.status === "pending") {
        return res.status(200).json({
          status: true,
          applicationStatus: "pending",
          message: "Your application is already awaiting review",
        });
      }
      // Rejected applications may be resubmitted; they remain pending until
      // an administrator completes a fresh review.
    }

    const now = FieldValue.serverTimestamp();
    await ref.set({
      uid,
      legalOwnerName,
      restaurantName,
      businessType,
      registrationType,
      registrationNumber,
      phone,
      businessEmail,
      address,
      foodSafetyPermitNumber,
      description,
      status: "pending",
      isActive: false,
      appliedAt: now,
      updatedAt: now,
      verification: {
        status: "pending",
        registrationChecked: false,
        foodSafetyPermitChecked: false,
        reviewedBy: null,
        reviewedAt: null,
        reviewNotes: "",
      },
    }, { merge: true });

    return res.status(201).json({
      status: true,
      applicationStatus: "pending",
      message: "Application submitted. Your business details must be verified before merchant access is enabled.",
    });
  } catch (err) {
    console.error("Food merchant application error:", err.message || err);
    return fail(res, 500, "Unable to submit merchant application");
  }
}

module.exports = { applyForFoodMerchant };
