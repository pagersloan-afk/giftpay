const express = require("express");
const router = express.Router();

const {
  getDiscosController,
} = require("../controllers/electricityDiscos.controller.js");
const {
  getElectricityProductsController,
} = require("../controllers/electricityProducts.controller.js");
const {
  verifyMeterController,
} = require("../controllers/electricity.controller.js");
const {
  walletPayElectricityController,
} = require("../controllers/walletPayElectricity.controller.js");
const {
  requeryElectricityController,
} = require("../controllers/electricityRequery.controller.js");

router.get("/discos", getDiscosController);
router.get("/products/:billerCode", getElectricityProductsController);
router.post("/verify-meter", verifyMeterController);
router.post("/wallet/pay-electricity", walletPayElectricityController);
router.post("/requery", requeryElectricityController);

module.exports = router;
