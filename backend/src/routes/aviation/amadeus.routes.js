const express = require("express");
const router = express.Router();
const aviation = require("./aviation.controller");

router.post("/search", aviation.search);

module.exports = router;
