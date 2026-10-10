const express = require("express");

const {
  fetchDataNetworksController,
  fetchDataPlansController,
  walletPayData,
  requeryDataController,
} = require("../../controllers/data.controller");

const router = express.Router();

// ============================================================
// MONNIFY DATA DISCOVERY
// ============================================================

// Monnify DATA billers currently available in the merchant account.
router.get("/networks", fetchDataNetworksController);

// Monnify products for the selected DATA biller.
// :billerCode is the actual Monnify biller code.
router.get("/plans/:billerCode", fetchDataPlansController);

// ============================================================
// WALLET DATA PURCHASE
// ============================================================
router.post("/wallet/pay-data", walletPayData);

// ============================================================
// MONNIFY DATA REQUERY
// ============================================================
router.get("/requery/:requestId", requeryDataController);

module.exports = router;
