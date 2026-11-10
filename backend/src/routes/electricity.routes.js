const express = require("express");
const router = express.Router();
const { getDiscosController } = require("../controllers/electricityDiscos.controller.js");
const { getElectricityProductsController } = require("../controllers/electricityProducts.controller.js");
const { verifyMeterController } = require("../controllers/electricity.controller.js");
const { walletPayElectricityController } = require("../controllers/walletPayElectricity.controller.js");
const { requeryElectricityController } = require("../controllers/electricityRequery.controller.js");
const clubkonnect = require("../controllers/clubkonnectBills.controller.js");

function useClubKonnect() {
  return String(process.env.BILL_PAYMENT_PROVIDER || "monnify").trim().toLowerCase() === "clubkonnect";
}

router.get("/discos", (req, res) => (useClubKonnect() ? clubkonnect.getDiscos(req, res) : getDiscosController(req, res)));
router.get("/products/:billerCode", (req, res) => (useClubKonnect() ? clubkonnect.getElectricityProducts(req, res) : getElectricityProductsController(req, res)));
router.post("/verify-meter", (req, res) => (useClubKonnect() ? clubkonnect.verifyMeter(req, res) : verifyMeterController(req, res)));
router.post("/wallet/pay-electricity", (req, res) => (useClubKonnect() ? clubkonnect.walletPayElectricity(req, res) : walletPayElectricityController(req, res)));
router.post("/requery", (req, res) => (useClubKonnect() ? clubkonnect.requeryElectricity(req, res) : requeryElectricityController(req, res)));

module.exports = router;
