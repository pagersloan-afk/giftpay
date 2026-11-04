const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");
const controller = require("../controllers/virtualAccount.controller");

const router = express.Router();
router.use(authMiddleware);
router.get("/config", controller.getVirtualAccountConfig);
router.get("/banks", controller.getPaystackBanks);
router.post("/prepare-paystack", controller.preparePaystackVirtualAccount);
router.post("/create", controller.createOrGetVirtualAccount);
router.get("/status", controller.getVirtualAccountStatus);
router.get("/transactions/:reference", controller.getPaystackTransactionDetails);

module.exports = router;
