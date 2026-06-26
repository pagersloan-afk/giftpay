// backend/src/routes/userServices.routes.js

const express = require("express");
const router = express.Router();

const {
  saveUserServices,
  loadUserServices,
} = require("../controllers/userServices.controller");

// Save layout
router.post("/user/services/save", saveUserServices);

// Load layout
router.get("/user/services/:userId", loadUserServices);

module.exports = router;
