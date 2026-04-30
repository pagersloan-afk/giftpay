// backend/src/routes/betting.routes.js
const express = require("express");
const router = express.Router();

const { walletFundBetting } = require("../../controllers/betting.controller");
const {
  verifyBettingCustomerController,
} = require("../controllers/bettingVerify.controller");
const {
  requeryBettingController,
} = require("../controllers/bettingRequery.controller");

// Wallet fund betting
router.post("/wallet/fund", walletFundBetting);

// Verify betting customer
router.post("/verify", verifyBettingCustomerController);

// Requery betting transaction
router.post("/requery", requeryBettingController);

module.exports = router;