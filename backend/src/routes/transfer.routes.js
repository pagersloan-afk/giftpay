// backend/src/routes/transfer.routes.js
const express = require("express");
const router = express.Router();

const {
  getBanks,
  resolveAccount,
  transferToBank,
} = require("../controllers/transfer.controller");

// Get list of banks
router.get("/banks", getBanks);

// Resolve account name
router.post("/resolve-account", resolveAccount);

// Transfer to bank (cashout)
router.post("/transfer-to-bank", transferToBank);

module.exports = router;
