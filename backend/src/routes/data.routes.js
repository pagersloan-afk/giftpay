const express = require("express");
const router = express.Router();

// OLD CONTROLLERS
const {
  buyDataController,
  queryDataController,
  cancelDataController,
  fetchDataPlansController,
} = require("../services/controllers/data.controller.js");

// NEW WALLET CONTROLLER
const { walletPayData } = require("../../controllers/data.controller");

// ===============================
// OLD ENDPOINTS (KEEP THEM)
// ===============================
router.get("/buy", buyDataController);

// ⭐ FIXED: now accepts /plans/:network
router.get("/plans/:network", fetchDataPlansController);

router.get("/query", queryDataController);
router.get("/cancel", cancelDataController);

// ===============================
// NEW WALLET ENDPOINT
// ===============================
router.post("/wallet/pay-data", walletPayData);

module.exports = router;
