const express = require("express");
const { createOrGetDVA, dvaWebhook } = require("../controllers/dva.controller");

const router = express.Router();

router.post("/virtual-account", createOrGetDVA);
router.post("/virtual-account/webhook", express.json({ type: "*/*" }), dvaWebhook);

module.exports = router;
