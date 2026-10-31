const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");
const {
  reviewFoodMerchantApplication,
} = require("../controllers/foodMerchantAdmin.controller");

// Firebase ID token is required; controller also verifies the admin role
// against users/{adminUid} in Firestore.
router.post(
  "/merchant/:uid/review",
  authMiddleware,
  reviewFoodMerchantApplication
);

module.exports = router;
