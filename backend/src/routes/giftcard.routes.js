const express = require("express");
const {
  buyGiftCard,
  quoteGiftCard,
} = require("../controllers/giftcard.controller");

const router = express.Router();

// BUY GIFT CARD
router.post("/buy", buyGiftCard);

// GET NGN QUOTE (FX preview)
router.post("/quote", quoteGiftCard);

module.exports = router;
