const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");
const {
  listMerchantConversations,
  listMerchantMessages,
  sendMerchantMessage,
  markMerchantConversationRead,
  deleteMerchantConversation,
  getMerchantConversationCustomer,
} = require("../controllers/foodChat.controller");

const router = express.Router();

// Every route verifies the Firebase ID token. Controllers additionally verify
// FOOD_MERCHANT_UID and check that the conversation belongs to that merchant.
router.use(authMiddleware);

router.get("/merchant/conversations", listMerchantConversations);
router.get("/merchant/conversations/:chatId/messages", listMerchantMessages);
router.post("/merchant/conversations/:chatId/messages", sendMerchantMessage);
router.patch("/merchant/conversations/:chatId/read", markMerchantConversationRead);
router.delete("/merchant/conversations/:chatId", deleteMerchantConversation);
router.get("/merchant/conversations/:chatId/customer", getMerchantConversationCustomer);

module.exports = router;
