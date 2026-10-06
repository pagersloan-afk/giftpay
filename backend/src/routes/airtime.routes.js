const express = require("express");

const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");

// ============================================================
// AIRTIME CONTROLLER
// ============================================================

const {
  getAirtimeNetworks,
  buyAirtimeController,
  queryAirtimeController,
  cancelAirtimeController,
  walletPayAirtime,
} = require("../services/controllers/airtime.controller.js");

// ============================================================
// AUTHENTICATION
// ============================================================
//
// All Airtime endpoints now require an authenticated
// Firebase user.
//
// This is required because:
//
// Flutter
//   ↓
// Firebase ID token
//   ↓
// authMiddleware
//   ↓
// Airtime controller
//
// ============================================================

router.use(authMiddleware);

// ============================================================
// MONNIFY AIRTIME NETWORK DISCOVERY
// ============================================================
//
// GET /api/airtime/networks
//
// Flutter uses this endpoint to populate the
// Select Network dropdown.
//
// The controller discovers:
//
// Categories
//     ↓
// Airtime category
//     ↓
// Airtime billers
//     ↓
// Airtime products
//     ↓
// Network → Product mapping
//
// ============================================================

router.get(
  "/networks",
  getAirtimeNetworks
);

// ============================================================
// OLD AIRTIME ENDPOINTS
// ============================================================
//
// These are kept so we do not unnecessarily break
// existing application functionality.
//
// ============================================================

router.get(
  "/buy",
  buyAirtimeController
);

router.get(
  "/query",
  queryAirtimeController
);

router.get(
  "/cancel",
  cancelAirtimeController
);

// ============================================================
// GIFTpay WALLET AIRTIME PAYMENT
// ============================================================
//
// POST /api/airtime/wallet/pay-airtime
//
// Flutter sends:
//
// {
//   "phone": "080...",
//   "network": "....",
//   "amount": 100
// }
//
// Firebase authentication identifies the user.
//
// The controller is responsible for:
//
// - wallet balance
// - fee
// - wallet debit
// - Monnify product resolution
// - Monnify validation
// - Monnify vend
// - pending handling
// - refund
// - cashback
// - transaction records
//
// ============================================================

router.post(
  "/wallet/pay-airtime",
  walletPayAirtime
);

// ============================================================
// EXPORT
// ============================================================

module.exports = router;