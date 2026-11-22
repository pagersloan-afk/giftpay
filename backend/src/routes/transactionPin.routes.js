const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const { setTransactionPin } = require("../controllers/security.controller");

router.post("/transaction-pin/set", authMiddleware, setTransactionPin);

module.exports = router;
