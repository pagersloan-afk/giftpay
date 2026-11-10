const express = require("express");
const monnify = require("../../controllers/data.controller");
const clubkonnect = require("../controllers/clubkonnectBills.controller");
const router = express.Router();

function useClubKonnect() {
  return String(process.env.BILL_PAYMENT_PROVIDER || "monnify").trim().toLowerCase() === "clubkonnect";
}

router.get("/networks", (req, res) => (useClubKonnect() ? clubkonnect.getDataNetworks(req, res) : monnify.fetchDataNetworksController(req, res)));
router.get("/plans/:billerCode", (req, res) => (useClubKonnect() ? clubkonnect.getDataPlans(req, res) : monnify.fetchDataPlansController(req, res)));
router.post("/wallet/pay-data", (req, res) => (useClubKonnect() ? clubkonnect.walletPayData(req, res) : monnify.walletPayData(req, res)));
router.get("/requery/:requestId", (req, res) => (useClubKonnect() ? clubkonnect.requeryData(req, res) : monnify.requeryDataController(req, res)));

module.exports = router;
