// Run once after backing up Firestore:
//   node scripts/migrateFoodMerchantOwnership.js
// Requires the same Firebase service-account path used by backend/server.js.
require("dotenv").config();
const admin = require("firebase-admin");
const fs = require("fs");

const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
const legacyUid = String(process.env.FOOD_MERCHANT_UID || "").trim();
if (!serviceAccountPath || !legacyUid) {
  throw new Error("Set FIREBASE_SERVICE_ACCOUNT_PATH and FOOD_MERCHANT_UID before migration.");
}
if (!admin.apps.length) {
  admin.initializeApp({ credential: admin.credential.cert(JSON.parse(fs.readFileSync(serviceAccountPath, "utf8"))) });
}
const db = admin.firestore();

async function migrateCollection(collectionName, predicate) {
  const snapshot = await db.collection(collectionName).get();
  let batch = db.batch();
  let pending = 0;
  let updated = 0;
  for (const doc of snapshot.docs) {
    const data = doc.data() || {};
    if (!predicate(data)) continue;
    batch.update(doc.ref, { merchantUid: legacyUid });
    pending++;
    updated++;
    if (pending === 400) {
      await batch.commit();
      batch = db.batch();
      pending = 0;
    }
  }
  if (pending) await batch.commit();
  console.log(`${collectionName}: tagged ${updated} records`);
}

(async () => {
  // Do not overwrite records already assigned to a merchant.
  await migrateCollection("foodMenu", d => !d.merchantUid && (!d.createdBy || d.createdBy === legacyUid));
  await migrateCollection("foodOrders", d => !d.merchantUid && (!d.merchantUid || d.merchantUid === legacyUid));
  await migrateCollection("foodChats", d => !d.merchantUid && (!d.merchantUid || d.merchantUid === legacyUid));

  const merchantRef = db.collection("foodMerchants").doc(legacyUid);
  const existing = await merchantRef.get();
  if (!existing.exists) {
    await merchantRef.set({
      uid: legacyUid,
      restaurantName: "GiftPay Food",
      status: "approved",
      isActive: true,
      migratedFromLegacyConfig: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    console.log("Created approved foodMerchants record for the legacy merchant.");
  } else {
    console.log("Existing foodMerchants record preserved.");
  }
  console.log("Migration complete. Review records and back up Firestore before deploying.");
  process.exit(0);
})().catch(error => {
  console.error("Food merchant migration failed:", error);
  process.exit(1);
});
