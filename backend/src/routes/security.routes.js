const express = require("express");

const router = express.Router();

const {
  loginAlert,
} = require("../controllers/security.controller");

const authMiddleware = require("../middleware/authMiddleware");

// ============================================================
// LOGIN SECURITY ALERT
// ============================================================
//
// Firebase ID token is required.
//
// POST /api/security/login-alert
//
// ============================================================

router.post(
  "/security/login-alert",
  authMiddleware,
  loginAlert
);

module.exports = router;