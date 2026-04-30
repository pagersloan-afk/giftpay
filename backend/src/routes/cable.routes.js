// backend/src/routes/cable.routes.js
const express = require("express");
const router = express.Router();

const { walletPayCable } = require("../../controllers/cable.controller");
const {
  verifyCableSmartcardController,
} = require("../controllers/cableVerify.controller");
const {
  getCablePackagesController,
} = require("../controllers/cablePackages.controller");
const { requeryCableController } = require("../controllers/cableRequery.controller");

// Wallet pay cable
router.post("/wallet/pay", walletPayCable);

// Verify smartcard
router.post("/verify", verifyCableSmartcardController);

// Get packages
router.get("/packages", getCablePackagesController);

// Requery cable transaction
router.post("/requery", requeryCableController);
module.exports = router;
