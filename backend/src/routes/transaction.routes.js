const express = require("express");
const router = express.Router();

const {
  getTransactionHistory,
} = require("../../controllers/transaction.controller");


// Unified transaction history
router.get("/transaction-history", getTransactionHistory);

module.exports = router;
