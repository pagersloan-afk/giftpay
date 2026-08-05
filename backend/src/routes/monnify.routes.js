// src/routes/monnify.routes.js
const express = require("express");
const router = express.Router();
const { createReservedAccount } = require("../controllers/monnify.controller");

router.post("/create", createReservedAccount);

module.exports = router;
