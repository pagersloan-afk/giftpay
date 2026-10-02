// backend/src/routes/transfer.routes.js

const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");

const {
  getBanks,
  resolveAccount,
  transferToBank,
  authorizeTransfer,
  resendTransferOtp,
  getMonnifyWalletBalance,
  getTransferStatus,
} = require("../controllers/transfer.controller");

// ---------------------------------------------------------
// BANKS
// ---------------------------------------------------------

router.get("/banks", getBanks);

// ---------------------------------------------------------
// NAME ENQUIRY
// ---------------------------------------------------------

router.post("/resolve-account", resolveAccount);

// ---------------------------------------------------------
// SINGLE BANK TRANSFER
// ---------------------------------------------------------
// Requires a valid Firebase ID token.
// The transfer controller also verifies the transaction PIN
// before any wallet debit or Monnify disbursement.

router.post(
  "/transfer-to-bank",
  authMiddleware,
  transferToBank
);

// ---------------------------------------------------------
// MFA / OTP
// ---------------------------------------------------------
// These endpoints should also require authentication so that
// an authenticated user is the one authorizing/resending OTP
// for their own transfer.

router.post(
  "/transfer-authorize",
  authMiddleware,
  authorizeTransfer
);

router.post(
  "/transfer-resend-otp",
  authMiddleware,
  resendTransferOtp
);

// ---------------------------------------------------------
// MONNIFY DISBURSEMENT WALLET BALANCE
// ---------------------------------------------------------
// Keep protected. This is a sensitive provider-wallet endpoint.

router.get(
  "/monnify-wallet-balance",
  authMiddleware,
  getMonnifyWalletBalance
);

// ---------------------------------------------------------
// TRANSFER STATUS / RECONCILIATION
// ---------------------------------------------------------
// Authentication prevents unauthenticated users from querying
// transfer references. The controller should additionally ensure
// the requested transfer belongs to the authenticated user.

router.get(
  "/transfer-status/:reference",
  authMiddleware,
  getTransferStatus
);

module.exports = router;