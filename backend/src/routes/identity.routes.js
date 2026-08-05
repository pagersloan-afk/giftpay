const express = require("express");
const router = express.Router();
const { verifyIdentity } = require("../controllers/identity.controller");

router.post("/verify-identity", verifyIdentity);

module.exports = router;
