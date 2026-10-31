const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");
const { getKycDocumentUrls } = require("../controllers/kycAdmin.controller");

router.get("/kyc/:uid/documents", authMiddleware, getKycDocumentUrls);
module.exports = router;
