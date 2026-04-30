const express = require("express");
const router = express.Router();

const { debitWallet } = require("../../controllers/wallet.controller");

// NEW MODULAR ENDPOINT
router.post("/wallet/debit", debitWallet);

module.exports = router;
