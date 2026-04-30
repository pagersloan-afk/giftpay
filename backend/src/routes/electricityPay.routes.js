// backend/src/routes/electricityPay.routes.js
const express = require("express");
const router = express.Router();

const {
  payElectricityController,
} = require("../controllers/electricityPay.controller");

// ⭐ Flutter calls this when user taps “Pay”
router.post("/wallet/pay-electricity", payElectricityController);

module.exports = router;
