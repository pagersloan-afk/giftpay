const express = require("express");
const router = express.Router();

const transactionAuthMiddleware = require("../middleware/transactionAuthMiddleware");
const { setTransactionPin } = require("../controllers/security.controller");

router.post("/transaction-pin/set", transactionAuthMiddleware, setTransactionPin);

module.exports = router;
