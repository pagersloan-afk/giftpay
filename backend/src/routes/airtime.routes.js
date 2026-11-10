const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");
const monnify = require("../services/controllers/airtime.controller.js");
const clubkonnect = require("../controllers/clubkonnectBills.controller.js");

function useClubKonnect() {
  return String(process.env.BILL_PAYMENT_PROVIDER || "monnify").trim().toLowerCase() === "clubkonnect";
}

router.use(authMiddleware);
router.get("/networks", (req, res) => (useClubKonnect() ? clubkonnect.getAirtimeNetworks(req, res) : monnify.getAirtimeNetworks(req, res)));
router.post("/wallet/pay-airtime", (req, res) => (useClubKonnect() ? clubkonnect.walletPayAirtime(req, res) : monnify.walletPayAirtime(req, res)));
router.get("/buy", monnify.buyAirtimeController);
router.get("/query", monnify.queryAirtimeController);
router.get("/cancel", monnify.cancelAirtimeController);

module.exports = router;
