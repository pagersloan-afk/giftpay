// backend/src/routes/analytics.routes.js

const express = require("express");
const router = express.Router();

const { logServiceUsage } = require("../controllers/analytics.controller");

// Log usage
router.post("/analytics/service-usage", logServiceUsage);

module.exports = router;

