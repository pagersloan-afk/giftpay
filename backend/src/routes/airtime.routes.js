const express = require("express");
const router = express.Router();

// OLD CONTROLLERS (ClubKonnect direct purchase)
const {
  buyAirtimeController,
  queryAirtimeController,
  cancelAirtimeController,
} = require("../services/controllers/airtime.controller.js");

// NEW WALLET CONTROLLER (Wallet → ClubKonnect vending)
const {
  walletPayAirtime,
} = require("../services/controllers/airtime.controller.js");

// ===============================
// OLD ENDPOINTS (KEEP THEM)
// ===============================
router.get("/buy", buyAirtimeController);
router.get("/query", queryAirtimeController);
router.get("/cancel", cancelAirtimeController);

// ===============================
// NEW WALLET ENDPOINT
// ===============================
router.post("/wallet/pay-airtime", walletPayAirtime);

module.exports = router;
