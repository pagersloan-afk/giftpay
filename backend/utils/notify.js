const admin = require("firebase-admin");

// ⭐ Send FCM Push Notification
async function sendPush(userId, title, body) {
  const db = admin.firestore();
  const userDoc = await db.collection("users").doc(userId).get();
  const token = userDoc.data()?.fcmToken;

  if (!token) return;

  await admin.messaging().send({
    token,
    notification: { title, body },
    android: { priority: "high" },
    apns: {
      payload: {
        aps: { sound: "default" }
      }
    }
  });
}

// ⭐ Unified Notification Helper (Firestore + Push + Category)
async function sendNotification(userId, title, body, category = "system") {
  const db = admin.firestore();

  // 1. Save to Firestore
  await db
    .collection("users")
    .doc(userId)
    .collection("notifications")
    .add({
      title,
      body,
      category, // wallet | electricity | payment | system
      createdAt: new Date(),
      read: false,
    });

  // 2. Send push notification
  await sendPush(userId, title, body);
}

module.exports = {
  sendNotification,
  sendPush,
};
