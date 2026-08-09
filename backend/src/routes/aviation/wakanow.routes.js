const express = require("express");
const router = express.Router();
const aviation = require("./aviation.controller");

router.post("/book", aviation.book);
router.post("/ticket", aviation.ticket);

module.exports = router;
