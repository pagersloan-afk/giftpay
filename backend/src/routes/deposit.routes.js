const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");
const { syncMyDeposits } = require("../controllers/deposit.controller");
router.post("/sync", authMiddleware, syncMyDeposits);
module.exports = router;
