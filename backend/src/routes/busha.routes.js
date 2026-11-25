const express = require("express");
const controller = require("../controllers/busha.controller");
const bushaOperator = require("../middleware/bushaOperator");

const router = express.Router();

// Per-GiftPay-user Busha customer mapping (Option A).
router.get("/customer/me", controller.myCustomerProfile);
router.post("/customer/me", controller.createMyCustomerProfile);

// Customer-safe market reference data.
router.get("/currencies", controller.currencies);
router.get("/currencies/:code", controller.currency);
router.get("/pairs", controller.pairs);

// Business-account data is restricted to explicitly allowlisted operators.
// Do not expose omnibus balances or shared business transactions to customers.
router.get("/balances", bushaOperator, controller.balances);
router.get("/balances/:idOrCode", bushaOperator, controller.balance);
router.get("/quotes", bushaOperator, controller.quotes);
router.post("/quotes", bushaOperator, controller.createQuote);
router.get("/quotes/:id", bushaOperator, controller.quote);
router.get("/transactions", bushaOperator, controller.transactions);
router.get("/transactions/:id", bushaOperator, controller.transaction);
router.get("/addresses/:code", bushaOperator, controller.depositAddress);
router.post("/addresses/regenerate", bushaOperator, controller.regenerateDepositAddress);
router.get("/recipients", bushaOperator, controller.recipients);
router.post("/recipients", bushaOperator, controller.createRecipient);
router.get("/recipients/:id", bushaOperator, controller.recipient);
router.delete("/recipients/:id", bushaOperator, controller.deleteRecipient);
router.get("/transfers/:id", bushaOperator, controller.transfer);

// Transfer creation intentionally not exposed until GiftPay's customer mapping,
// ledger, approval and idempotency controls are implemented.
module.exports = router;
