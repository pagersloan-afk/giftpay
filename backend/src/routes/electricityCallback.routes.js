// backend/src/routes/electricityCallback.routes.js
const express = require("express");
const router = express.Router();

const {
  electricityCallbackController,
} = require("../controllers/electricityCallback.controller");

// ⭐ CK will call this URL
router.get("/callback", electricityCallbackController);
router.post("/callback", electricityCallbackController);

module.exports = router;
