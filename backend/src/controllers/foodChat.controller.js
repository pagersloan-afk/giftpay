const admin = require("firebase-admin");

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;
const { sendNotification } = require("../../utils/notify");
const CHATS = "foodChats";

function fail(res, status, message) {
  return res.status(status).json({ status: false, message });
}

function uidOf(req) {
  return req.user && req.user.uid ? String(req.user.uid) : "";
}

function configuredMerchantUid() {
  return String(process.env.FOOD_MERCHANT_UID || "").trim();
}

async function isMerchant(req) {
  const uid = uidOf(req);
  if (!uid) return false;
  try {
    const doc = await db.collection("foodMerchants").doc(uid).get();
    if (doc.exists) {
      const data = doc.data() || {};
      return data.status === "approved" && data.isActive !== false;
    }
  } catch (err) {
    console.error("Food chat merchant lookup error:", err.message || err);
    return false;
  }
  const configured = configuredMerchantUid();
  return Boolean(configured && uid === configured);
}

function validChatId(value) {
  const id = String(value || "").trim();
  return id.length > 0 && id.length <= 180 && /^[A-Za-z0-9_-]+$/.test(id);
}

function publicChat(doc) {
  return { id: doc.id, ...(doc.data() || {}) };
}

// GET /api/food-chat/merchant/conversations
async function listMerchantConversations(req, res) {
  if (!(await isMerchant(req))) return fail(res, 403, "Merchant access required");
  try {
    const snapshot = await db.collection(CHATS)
      .where("merchantUid", "==", uidOf(req))
      .get();

    const conversations = snapshot.docs.map(publicChat).sort((a, b) => {
      const aTime = a.lastMessageAt && typeof a.lastMessageAt.toMillis === "function"
        ? a.lastMessageAt.toMillis() : 0;
      const bTime = b.lastMessageAt && typeof b.lastMessageAt.toMillis === "function"
        ? b.lastMessageAt.toMillis() : 0;
      return bTime - aTime;
    });

    return res.json({ status: true, conversations });
  } catch (err) {
    console.error("List merchant food chats error:", err.message || err);
    return fail(res, 500, "Unable to load customer conversations");
  }
}

// GET /api/food-chat/merchant/conversations/:chatId/messages
async function listMerchantMessages(req, res) {
  if (!(await isMerchant(req))) return fail(res, 403, "Merchant access required");
  const chatId = String(req.params.chatId || "");
  if (!validChatId(chatId)) return fail(res, 400, "Invalid conversation id");

  try {
    const chatRef = db.collection(CHATS).doc(chatId);
    const chat = await chatRef.get();
    if (!chat.exists) return fail(res, 404, "Conversation not found");
    if (chat.get("merchantUid") !== uidOf(req)) return fail(res, 403, "Conversation access denied");

    const messages = await chatRef.collection("messages").orderBy("createdAt", "asc").limit(500).get();
    return res.json({
      status: true,
      messages: messages.docs.map((doc) => ({ id: doc.id, ...(doc.data() || {}) })),
    });
  } catch (err) {
    console.error("List merchant food chat messages error:", err.message || err);
    return fail(res, 500, "Unable to load conversation messages");
  }
}

// POST /api/food-chat/merchant/conversations/:chatId/messages
async function sendMerchantMessage(req, res) {
  if (!(await isMerchant(req))) return fail(res, 403, "Merchant access required");
  const chatId = String(req.params.chatId || "");
  if (!validChatId(chatId)) return fail(res, 400, "Invalid conversation id");

  const text = typeof (req.body || {}).text === "string" ? req.body.text.trim() : "";
  if (!text) return fail(res, 400, "Message text is required");
  if (text.length > 2000) return fail(res, 400, "Message must be 2,000 characters or fewer");

  try {
    const chatRef = db.collection(CHATS).doc(chatId);
    const messageRef = chatRef.collection("messages").doc();

    await db.runTransaction(async (transaction) => {
      const chat = await transaction.get(chatRef);
      if (!chat.exists) {
        const error = new Error("Conversation not found");
        error.statusCode = 404;
        throw error;
      }
      if (chat.get("merchantUid") !== uidOf(req)) {
        const error = new Error("Conversation access denied");
        error.statusCode = 403;
        throw error;
      }

      transaction.set(messageRef, {
        senderUid: uidOf(req),
        senderName: String(req.user.name || req.user.email || "GiftPay Food"),
        text,
        type: "text",
        readBy: [uidOf(req)],
        createdAt: FieldValue.serverTimestamp(),
      });
      transaction.update(chatRef, {
        lastMessage: text,
        lastMessageAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
        lastSenderUid: uidOf(req),
        unreadForCustomer: FieldValue.increment(1),
        unreadForMerchant: 0,
      });
    });

    // Notify the customer after the message transaction commits. Notification
    // failures are isolated by notify.js and must not undo a sent chat message.
    try {
      const chatSnapshot = await chatRef.get();
      const customerUid = String(chatSnapshot.get("customerUid") || "").trim();
      if (customerUid) {
        await sendNotification(
          customerUid,
          "New reply from the restaurant",
          text.length > 140 ? `${text.slice(0, 137)}...` : text,
          "food_chat"
        );
      }
    } catch (notificationError) {
      console.error("Food chat notification error:", notificationError.message || notificationError);
    }

    return res.status(201).json({ status: true, message: "Reply sent", messageId: messageRef.id });
  } catch (err) {
    if (err.statusCode) return fail(res, err.statusCode, err.message);
    console.error("Send merchant food chat reply error:", err.message || err);
    return fail(res, 500, "Unable to send reply");
  }
}

// PATCH /api/food-chat/merchant/conversations/:chatId/read
async function markMerchantConversationRead(req, res) {
  if (!(await isMerchant(req))) return fail(res, 403, "Merchant access required");
  const chatId = String(req.params.chatId || "");
  if (!validChatId(chatId)) return fail(res, 400, "Invalid conversation id");

  try {
    const ref = db.collection(CHATS).doc(chatId);
    const snapshot = await ref.get();
    if (!snapshot.exists) return fail(res, 404, "Conversation not found");
    if (snapshot.get("merchantUid") !== uidOf(req)) return fail(res, 403, "Conversation access denied");
    await ref.update({
      unreadForMerchant: 0,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return res.json({ status: true, message: "Conversation marked as read" });
  } catch (err) {
    console.error("Mark merchant food chat read error:", err.message || err);
    return fail(res, 500, "Unable to mark conversation as read");
  }
}


// DELETE /api/food-chat/merchant/conversations/:chatId
// Permanently removes the conversation and its nested messages. Firebase Admin's
// recursiveDelete is used so message subcollections are not left orphaned.
async function deleteMerchantConversation(req, res) {
  if (!(await isMerchant(req))) return fail(res, 403, "Merchant access required");
  const chatId = String(req.params.chatId || "");
  if (!validChatId(chatId)) return fail(res, 400, "Invalid conversation id");

  try {
    const chatRef = db.collection(CHATS).doc(chatId);
    const snapshot = await chatRef.get();
    if (!snapshot.exists) return fail(res, 404, "Conversation not found");
    if (snapshot.get("merchantUid") !== uidOf(req)) {
      return fail(res, 403, "Conversation access denied");
    }

    await db.recursiveDelete(chatRef);
    return res.json({ status: true, message: "Conversation deleted" });
  } catch (err) {
    console.error("Delete merchant food conversation error:", err.message || err);
    return fail(res, 500, "Unable to delete conversation");
  }
}


// GET /api/food-chat/merchant/conversations/:chatId/customer
// Return only display-safe profile fields; never expose KYC or transaction secrets.
async function getMerchantConversationCustomer(req, res) {
  if (!(await isMerchant(req))) return fail(res, 403, "Merchant access required");
  const chatId = String(req.params.chatId || "");
  if (!validChatId(chatId)) return fail(res, 400, "Invalid conversation id");

  try {
    const chatRef = db.collection(CHATS).doc(chatId);
    const chat = await chatRef.get();
    if (!chat.exists) return fail(res, 404, "Conversation not found");
    if (chat.get("merchantUid") !== uidOf(req)) return fail(res, 403, "Conversation access denied");

    const customerUid = String(chat.get("customerUid") || "").trim();
    if (!customerUid) return res.json({ status: true, customer: {} });
    const customerDoc = await db.collection("users").doc(customerUid).get();
    if (!customerDoc.exists) return res.json({ status: true, customer: {} });
    const data = customerDoc.data() || {};
    return res.json({
      status: true,
      customer: {
        firstName: typeof data.firstName === "string" ? data.firstName : "",
        lastName: typeof data.lastName === "string" ? data.lastName : "",
        name: typeof data.name === "string" ? data.name : "",
        email: typeof data.email === "string" ? data.email : "",
        profileUrl: typeof data.profileUrl === "string" ? data.profileUrl : "",
      },
    });
  } catch (err) {
    console.error("Get merchant food chat customer profile error:", err.message || err);
    return fail(res, 500, "Unable to load customer profile");
  }
}

module.exports = {
  listMerchantConversations,
  listMerchantMessages,
  sendMerchantMessage,
  markMerchantConversationRead,
  deleteMerchantConversation,
  getMerchantConversationCustomer,
};