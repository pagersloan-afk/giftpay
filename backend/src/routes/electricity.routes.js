// backend/src/routes/electricity.routes.js
const express = require("express");
const router = express.Router();

const { getDiscosController } = require("../controllers/electricityDiscos.controller.js");
const { verifyMeterController } = require("../controllers/electricity.controller.js");
const { walletPayElectricityController } = require("../controllers/walletPayElectricity.controller.js");
const { vendElectricityController } = require("../controllers/vendElectricity.controller.js");
const { requeryElectricityController } = require("../controllers/electricityRequery.controller.js");

// ⭐ Fetch discos
router.get("/discos", getDiscosController);

// ⭐ Verify meter
router.post("/verify-meter", verifyMeterController);

// ⭐ Wallet debit (Step 1)
router.post("/wallet/pay-electricity", walletPayElectricityController);

// ⭐ Vend electricity (Step 2)
router.post("/vend-electricity", vendElectricityController);

// ⭐ Requery (Step 3)
router.post("/requery", requeryElectricityController);

module.exports = router;
