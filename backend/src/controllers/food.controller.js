const admin = require("firebase-admin");
const crypto = require("crypto");
const { createClient } = require("@supabase/supabase-js");

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

const MENU_COLLECTION = "foodMenu";
const ORDERS_COLLECTION = "foodOrders";
const PAYABLES_COLLECTION = "foodMerchantPayables";
const RESTAURANT_SETTINGS_COLLECTION = "foodRestaurantSettings";

const VALID_STATUSES = new Set([
  "pending",
  "confirmed",
  "preparing",
  "out_for_delivery",
  "delivered",
  "cancelled",
]);

function money(value) {
  const n = Number(value);
  if (!Number.isFinite(n) || n < 0) return null;
  return Math.round((n + Number.EPSILON) * 100) / 100;
}

function amountToKobo(value) {
  return Math.round(Number(value) * 100);
}

function fromKobo(value) {
  return value / 100;
}

function uidOf(req) {
  return req.user && req.user.uid ? String(req.user.uid) : "";
}

function isMerchant(req) {
  const configuredUid = String(process.env.FOOD_MERCHANT_UID || "").trim();
  return Boolean(configuredUid && uidOf(req) === configuredUid);
}

async function getMerchantAccess(req, res) {
  const merchant = isMerchant(req);

  return res.json({
    status: true,
    hasAccess: merchant,
    isMerchant: merchant,
  });
}


function safeOrderId(uid, idempotencyKey) {
  const key = String(idempotencyKey || "").trim();
  if (!/^[A-Za-z0-9_-]{12,100}$/.test(key)) return null;
  return `${uid}_${key}`;
}

function publicOrder(order) {
  const copy = { ...order };
  delete copy.deliveryCodeHash;
  return copy;
}

function fail(res, status, message) {
  return res.status(status).json({ status: false, message });
}

async function getMenu(req, res) {
  try {
    const snapshot = await db.collection(MENU_COLLECTION)
      .where("active", "==", true)
      .get();

    const items = snapshot.docs
      .map((doc) => ({ id: doc.id, ...doc.data() }))
      .sort((a, b) => String(a.name || "").localeCompare(String(b.name || "")));

    return res.json({ status: true, items });
  } catch (err) {
    console.error("Food menu error:", err.message || err);
    return fail(res, 500, "Unable to load the food menu");
  }
}

async function createMenuItem(req, res) {
  if (!isMerchant(req)) return fail(res, 403, "Merchant access required");

  const name = String(req.body?.name || "").trim();
  const description = String(req.body?.description || "").trim();
  const category = String(req.body?.category || "Meals").trim();
  const imageUrl = String(req.body?.imageUrl || "").trim();
  const price = money(req.body?.price);
  const available = req.body?.available !== false;

  if (!name || name.length > 120) return fail(res, 400, "A valid item name is required");
  if (price === null || price <= 0) return fail(res, 400, "Price must be greater than zero");
  if (description.length > 1000 || category.length > 80) {
    return fail(res, 400, "Description or category is too long");
  }
  if (imageUrl && !/^https:\/\/\S+$/i.test(imageUrl)) {
    return fail(res, 400, "imageUrl must be an HTTPS URL");
  }

  try {
    const ref = db.collection(MENU_COLLECTION).doc();
    const item = {
      name,
      description,
      category,
      imageUrl: imageUrl || null,
      price,
      active: available,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      createdBy: uidOf(req),
    };
    await ref.set(item);
    return res.status(201).json({ status: true, item: { id: ref.id, ...item } });
  } catch (err) {
    console.error("Create food item error:", err.message || err);
    return fail(res, 500, "Unable to create menu item");
  }
}

async function updateMenuItem(req, res) {
  if (!isMerchant(req)) return fail(res, 403, "Merchant access required");

  const itemId = String(req.params.itemId || "").trim();
  if (!itemId) return fail(res, 400, "Menu item ID is required");

  const update = {};
  const body = req.body || {};

  if (body.name !== undefined) {
    const name = String(body.name).trim();
    if (!name || name.length > 120) return fail(res, 400, "Invalid item name");
    update.name = name;
  }
  if (body.description !== undefined) {
    const description = String(body.description).trim();
    if (description.length > 1000) return fail(res, 400, "Description is too long");
    update.description = description;
  }
  if (body.category !== undefined) {
    const category = String(body.category).trim();
    if (!category || category.length > 80) return fail(res, 400, "Invalid category");
    update.category = category;
  }
  if (body.price !== undefined) {
    const price = money(body.price);
    if (price === null || price <= 0) return fail(res, 400, "Price must be greater than zero");
    update.price = price;
  }
  if (body.imageUrl !== undefined) {
    const imageUrl = String(body.imageUrl || "").trim();
    if (imageUrl && !/^https:\/\/\S+$/i.test(imageUrl)) {
      return fail(res, 400, "imageUrl must be an HTTPS URL");
    }
    update.imageUrl = imageUrl || null;
  }
  if (body.active !== undefined) {
    if (typeof body.active !== "boolean") return fail(res, 400, "active must be true or false");
    update.active = body.active;
  }

  if (!Object.keys(update).length) return fail(res, 400, "No valid fields supplied");
  update.updatedAt = FieldValue.serverTimestamp();

  try {
    const ref = db.collection(MENU_COLLECTION).doc(itemId);
    const doc = await ref.get();
    if (!doc.exists) return fail(res, 404, "Menu item not found");
    await ref.update(update);
    const saved = await ref.get();
    return res.json({ status: true, item: { id: saved.id, ...saved.data() } });
  } catch (err) {
    console.error("Update food item error:", err.message || err);
    return fail(res, 500, "Unable to update menu item");
  }
}


async function listMerchantMenu(req, res) {
  if (!isMerchant(req)) return fail(res, 403, "Merchant access required");
  try {
    // Single-merchant implementation: this account manages the current menu.
    // For multi-merchant support, scope this query by restaurantId/merchantUid.
    const snapshot = await db.collection(MENU_COLLECTION).get();
    const items = snapshot.docs
      .map((doc) => ({ id: doc.id, ...doc.data() }))
      .sort((a, b) => String(a.name || "").localeCompare(String(b.name || "")));
    return res.json({ status: true, items });
  } catch (err) {
    console.error("List merchant food menu error:", err.message || err);
    return fail(res, 500, "Unable to load merchant menu");
  }
}

async function uploadMenuImage(req, res) {
  if (!isMerchant(req)) return fail(res, 403, "Merchant access required");
  if (!req.file) return fail(res, 400, "Choose a food image to upload");

  const mimeType = String(req.file.mimetype || "").toLowerCase();
  const extByType = { "image/jpeg": "jpg", "image/png": "png", "image/webp": "webp" };
  const ext = extByType[mimeType];
  if (!ext) return fail(res, 400, "Only JPG, PNG, and WebP images are supported");

  // Keep Supabase credentials on the backend only. Use the same service-role
  // configuration pattern as profile.routes.js, but a separate food bucket.
  const supabaseUrl = String(process.env.SUPABASE_URL || "").trim();
  const serviceRoleKey = String(process.env.SUPABASE_SERVICE_ROLE_KEY || "").trim();
  const bucketName = String(process.env.SUPABASE_FOOD_BUCKET || "food-menu").trim();

  if (!supabaseUrl || !serviceRoleKey || !bucketName) {
    console.error("Food image upload unavailable: Supabase URL, service-role key, or food bucket is missing.");
    return fail(res, 503, "Food image storage is not configured");
  }

  try {
    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });

    const objectPath = `${uidOf(req)}/${crypto.randomUUID()}.${ext}`;
    const { error: uploadError } = await supabase.storage
      .from(bucketName)
      .upload(objectPath, req.file.buffer, {
        contentType: mimeType,
        cacheControl: "3600",
        upsert: false,
      });

    if (uploadError) {
      console.error("Supabase food image upload error:", uploadError.message || uploadError);
      return fail(res, 502, "Unable to upload food image to storage");
    }

    const { data: publicUrlData } = supabase.storage
      .from(bucketName)
      .getPublicUrl(objectPath);
    const imageUrl = publicUrlData?.publicUrl;
    if (!imageUrl) return fail(res, 500, "Food image uploaded but its URL could not be generated");

    // The Flutter client expects { status: true, imageUrl } and saves this URL
    // into the existing Firestore foodMenu document.
    return res.status(201).json({ status: true, imageUrl, storagePath: objectPath });
  } catch (err) {
    console.error("Food image upload error:", err.message || err);
    return fail(res, 500, "Unable to upload food image");
  }
}

async function placeOrder(req, res) {
  const uid = uidOf(req);
  if (!uid) return fail(res, 401, "Authentication required");

  const merchantUid = String(process.env.FOOD_MERCHANT_UID || "").trim();
  const deliveryCodeSecret = String(process.env.FOOD_DELIVERY_CODE_SECRET || "");
  if (!merchantUid || deliveryCodeSecret.length < 32) {
    return fail(res, 503, "Food ordering is not fully configured");
  }

  const orderId = safeOrderId(uid, req.body?.idempotencyKey);
  if (!orderId) {
    return fail(res, 400, "idempotencyKey is required (12–100 letters, numbers, _ or -)");
  }

  const rawItems = req.body?.items;
  if (!Array.isArray(rawItems) || rawItems.length < 1 || rawItems.length > 30) {
    return fail(res, 400, "Choose between 1 and 30 menu items");
  }

  const quantities = new Map();
  for (const row of rawItems) {
    const itemId = String(row?.itemId || "").trim();
    const quantity = Number(row?.quantity);
    if (!itemId || !Number.isInteger(quantity) || quantity < 1 || quantity > 50) {
      return fail(res, 400, "Each item requires a valid itemId and quantity from 1 to 50");
    }
    quantities.set(itemId, (quantities.get(itemId) || 0) + quantity);
  }
  if (quantities.size > 30) return fail(res, 400, "Too many distinct menu items");

  const address = String(req.body?.deliveryAddress || "").trim();
  const phone = String(req.body?.phone || "").trim();
  const notes = String(req.body?.notes || "").trim();
  if (address.length < 5 || address.length > 500) return fail(res, 400, "A valid delivery address is required");
  if (!/^[+0-9()\-\s]{7,25}$/.test(phone)) return fail(res, 400, "A valid contact phone number is required");
  if (notes.length > 500) return fail(res, 400, "Order notes are too long");

  const deliveryFee = money(process.env.FOOD_DELIVERY_FEE_NGN || "0");
  if (deliveryFee === null) return fail(res, 500, "Food delivery fee configuration is invalid");

  try {
    const orderRef = db.collection(ORDERS_COLLECTION).doc(orderId);
    const menuRefs = [...quantities.keys()].map((id) => db.collection(MENU_COLLECTION).doc(id));
    const walletRef = db.collection("wallets").doc(uid);
    // Deterministic per order, but secret-keyed: retries can recover the same
    // code after a network timeout without storing the plaintext code.
    const codeDigest = crypto.createHmac("sha256", deliveryCodeSecret).update(orderId).digest();
    const deliveryCode = String(100000 + (codeDigest.readUInt32BE(0) % 900000));
    const deliveryCodeHash = crypto.createHash("sha256").update(deliveryCode).digest("hex");

    const result = await db.runTransaction(async (tx) => {
      const existing = await tx.get(orderRef);
      if (existing.exists) {
        const saved = existing.data();
        return { duplicate: true, order: publicOrder({ id: existing.id, ...saved }), deliveryCode };
      }

      const menuDocs = [];
      for (const ref of menuRefs) menuDocs.push(await tx.get(ref));
      const walletDoc = await tx.get(walletRef);

      if (!walletDoc.exists) {
        const error = new Error("WALLET_NOT_FOUND");
        error.code = "WALLET_NOT_FOUND";
        throw error;
      }

      const menuById = new Map();
      menuDocs.forEach((doc) => {
        if (doc.exists) menuById.set(doc.id, doc.data());
      });

      const lineItems = [];
      let subtotalKobo = 0;
      for (const [itemId, quantity] of quantities.entries()) {
        const item = menuById.get(itemId);
        if (!item || item.active !== true) {
          const error = new Error("MENU_ITEM_UNAVAILABLE");
          error.code = "MENU_ITEM_UNAVAILABLE";
          throw error;
        }
        const unitPrice = money(item.price);
        if (unitPrice === null || unitPrice <= 0) {
          const error = new Error("MENU_PRICE_INVALID");
          error.code = "MENU_PRICE_INVALID";
          throw error;
        }
        const unitPriceKobo = amountToKobo(unitPrice);
        subtotalKobo += unitPriceKobo * quantity;
        lineItems.push({
          itemId,
          name: String(item.name || "Food item"),
          quantity,
          unitPrice: fromKobo(unitPriceKobo),
          lineTotal: fromKobo(unitPriceKobo * quantity),
        });
      }

      const deliveryFeeKobo = amountToKobo(deliveryFee);
      const totalKobo = subtotalKobo + deliveryFeeKobo;
      const total = fromKobo(totalKobo);
      const wallet = walletDoc.data() || {};
      const balance = money(wallet.balance ?? 0);
      if (balance === null || balance < 0) {
        const error = new Error("WALLET_BALANCE_INVALID");
        error.code = "WALLET_BALANCE_INVALID";
        throw error;
      }
      if (amountToKobo(balance) < totalKobo) {
        const error = new Error("INSUFFICIENT_FUNDS");
        error.code = "INSUFFICIENT_FUNDS";
        throw error;
      }

      const now = FieldValue.serverTimestamp();
      const nextBalance = fromKobo(amountToKobo(balance) - totalKobo);
      const walletTransaction = {
        id: `${orderId}_debit`,
        type: "debit",
        category: "food_order",
        amount: total,
        description: `Food order ${orderId}`,
        reference: orderId,
        status: "reserved",
        createdAt: new Date().toISOString(),
      };

      const order = {
        id: orderId,
        userId: uid,
        merchantUid,
        items: lineItems,
        subtotal: fromKobo(subtotalKobo),
        deliveryFee: fromKobo(deliveryFeeKobo),
        total,
        currency: "NGN",
        deliveryAddress: address,
        phone,
        notes: notes || null,
        status: "pending",
        paymentStatus: "reserved",
        deliveryCodeHash,
        createdAt: now,
        updatedAt: now,
        statusHistory: [{ status: "pending", at: new Date().toISOString(), actorUid: uid }],
      };

      tx.update(walletRef, {
        balance: nextBalance,
        transactions: FieldValue.arrayUnion(walletTransaction),
        updatedAt: now,
      });
      tx.create(orderRef, order);

      return { duplicate: false, order: publicOrder(order), deliveryCode };
    });

    return res.status(result.duplicate ? 200 : 201).json({
      status: true,
      duplicate: result.duplicate,
      message: result.duplicate
        ? "This order request was already processed"
        : "Food order placed and wallet amount reserved",
      order: result.order,
      deliveryCode: result.deliveryCode,
    });
  } catch (err) {
    const code = err.code || "";
    if (code === "INSUFFICIENT_FUNDS") return fail(res, 402, "Insufficient available wallet balance");
    if (code === "WALLET_NOT_FOUND") return fail(res, 409, "Wallet was not found for this account");
    if (code === "MENU_ITEM_UNAVAILABLE") return fail(res, 409, "One or more selected food items are unavailable");
    if (code === "MENU_PRICE_INVALID" || code === "WALLET_BALANCE_INVALID") {
      return fail(res, 409, "Unable to validate wallet or menu pricing");
    }
    console.error("Place food order error:", err.message || err);
    return fail(res, 500, "Unable to place food order");
  }
}

async function listMyOrders(req, res) {
  const uid = uidOf(req);
  try {
    const snapshot = await db.collection(ORDERS_COLLECTION)
      .where("userId", "==", uid)
      .limit(100)
      .get();
    const orders = snapshot.docs
      .map((doc) => publicOrder({ id: doc.id, ...doc.data() }))
      .sort((a, b) => {
        const ad = a.createdAt?._seconds || 0;
        const bd = b.createdAt?._seconds || 0;
        return bd - ad;
      });
    return res.json({ status: true, orders });
  } catch (err) {
    console.error("List food orders error:", err.message || err);
    return fail(res, 500, "Unable to load your food orders");
  }
}

async function getMyOrder(req, res) {
  const uid = uidOf(req);
  try {
    const doc = await db.collection(ORDERS_COLLECTION).doc(String(req.params.orderId)).get();
    if (!doc.exists) return fail(res, 404, "Order not found");
    const order = doc.data();
    if (order.userId !== uid && !isMerchant(req)) return fail(res, 403, "Access denied");
    return res.json({ status: true, order: publicOrder({ id: doc.id, ...order }) });
  } catch (err) {
    console.error("Get food order error:", err.message || err);
    return fail(res, 500, "Unable to load order");
  }
}

async function listMerchantOrders(req, res) {
  if (!isMerchant(req)) return fail(res, 403, "Merchant access required");
  try {
    const snapshot = await db.collection(ORDERS_COLLECTION)
      .where("merchantUid", "==", uidOf(req))
      .limit(100)
      .get();
    const orders = snapshot.docs
      .map((doc) => publicOrder({ id: doc.id, ...doc.data() }))
      .sort((a, b) => {
        const ad = a.createdAt?._seconds || 0;
        const bd = b.createdAt?._seconds || 0;
        return bd - ad;
      });
    return res.json({ status: true, orders });
  } catch (err) {
    console.error("List merchant food orders error:", err.message || err);
    return fail(res, 500, "Unable to load merchant orders");
  }
}

async function updateOrderStatus(req, res) {
  if (!isMerchant(req)) return fail(res, 403, "Merchant access required");

  const requestedStatus = String(req.body?.status || "").trim();
  if (!VALID_STATUSES.has(requestedStatus) || requestedStatus === "delivered") {
    return fail(res, 400, "Use a valid merchant status; delivery must be confirmed by the customer");
  }

  const orderRef = db.collection(ORDERS_COLLECTION).doc(String(req.params.orderId));
  const walletRefFrom = (uid) => db.collection("wallets").doc(uid);

  try {
    const result = await db.runTransaction(async (tx) => {
      const orderDoc = await tx.get(orderRef);
      if (!orderDoc.exists) {
        const error = new Error("ORDER_NOT_FOUND"); error.code = "ORDER_NOT_FOUND"; throw error;
      }
      const order = orderDoc.data();
      if (order.merchantUid !== uidOf(req)) {
        const error = new Error("FORBIDDEN"); error.code = "FORBIDDEN"; throw error;
      }
      if (order.status === requestedStatus) return { unchanged: true, order: publicOrder({ id: orderDoc.id, ...order }) };
      if (["delivered", "cancelled"].includes(order.status)) {
        const error = new Error("ORDER_FINAL"); error.code = "ORDER_FINAL"; throw error;
      }

      const allowed = {
        pending: ["confirmed", "cancelled"],
        confirmed: ["preparing", "cancelled"],
        preparing: ["out_for_delivery", "cancelled"],
        out_for_delivery: [],
      };
      if (!(allowed[order.status] || []).includes(requestedStatus)) {
        const error = new Error("INVALID_TRANSITION"); error.code = "INVALID_TRANSITION"; throw error;
      }

      const now = FieldValue.serverTimestamp();
      const history = Array.isArray(order.statusHistory) ? order.statusHistory : [];
      const updatedOrder = {
        status: requestedStatus,
        updatedAt: now,
        statusHistory: [...history, { status: requestedStatus, at: new Date().toISOString(), actorUid: uidOf(req) }],
      };

      if (requestedStatus === "cancelled") {
        if (order.paymentStatus !== "reserved") {
          const error = new Error("PAYMENT_NOT_RESERVED"); error.code = "PAYMENT_NOT_RESERVED"; throw error;
        }
        const walletRef = walletRefFrom(order.userId);
        const walletDoc = await tx.get(walletRef);
        if (!walletDoc.exists) {
          const error = new Error("WALLET_NOT_FOUND"); error.code = "WALLET_NOT_FOUND"; throw error;
        }
        const wallet = walletDoc.data() || {};
        const currentBalance = money(wallet.balance ?? 0);
        if (currentBalance === null) {
          const error = new Error("WALLET_BALANCE_INVALID"); error.code = "WALLET_BALANCE_INVALID"; throw error;
        }
        const refund = money(order.total);
        const refundTx = {
          id: `${order.id}_refund`,
          type: "credit",
          category: "food_order_refund",
          amount: refund,
          description: `Refund for cancelled food order ${order.id}`,
          reference: order.id,
          status: "completed",
          createdAt: new Date().toISOString(),
        };
        tx.update(walletRef, {
          balance: fromKobo(amountToKobo(currentBalance) + amountToKobo(refund)),
          transactions: FieldValue.arrayUnion(refundTx),
          updatedAt: now,
        });
        updatedOrder.paymentStatus = "refunded";
        updatedOrder.refundedAt = now;
      }

      tx.update(orderRef, updatedOrder);
      return {
        unchanged: false,
        order: publicOrder({ id: orderDoc.id, ...order, ...updatedOrder }),
      };
    });

    return res.json({
      status: true,
      message: result.unchanged ? "Order status is already set" : "Order status updated",
      order: result.order,
    });
  } catch (err) {
    if (err.code === "ORDER_NOT_FOUND") return fail(res, 404, "Order not found");
    if (err.code === "FORBIDDEN") return fail(res, 403, "This order does not belong to your merchant account");
    if (err.code === "ORDER_FINAL") return fail(res, 409, "This order is already finalised");
    if (err.code === "INVALID_TRANSITION") return fail(res, 409, "That order status transition is not allowed");
    if (err.code === "PAYMENT_NOT_RESERVED") return fail(res, 409, "Order payment is not in a refundable reserved state");
    console.error("Update food order status error:", err.message || err);
    return fail(res, 500, "Unable to update food order");
  }
}

async function confirmDelivery(req, res) {
  const uid = uidOf(req);
  const suppliedCode = String(req.body?.deliveryCode || "").trim();
  if (!/^\d{6}$/.test(suppliedCode)) return fail(res, 400, "Enter the six-digit delivery code");

  const orderRef = db.collection(ORDERS_COLLECTION).doc(String(req.params.orderId));
  const payableRef = db.collection(PAYABLES_COLLECTION).doc(String(req.params.orderId));

  try {
    const result = await db.runTransaction(async (tx) => {
      const orderDoc = await tx.get(orderRef);
      if (!orderDoc.exists) {
        const error = new Error("ORDER_NOT_FOUND"); error.code = "ORDER_NOT_FOUND"; throw error;
      }
      const order = orderDoc.data();
      if (order.userId !== uid) {
        const error = new Error("FORBIDDEN"); error.code = "FORBIDDEN"; throw error;
      }
      if (order.status === "delivered" && order.paymentStatus === "captured") {
        return { duplicate: true, order: publicOrder({ id: orderDoc.id, ...order }) };
      }
      if (order.status !== "out_for_delivery" || order.paymentStatus !== "reserved") {
        const error = new Error("NOT_READY"); error.code = "NOT_READY"; throw error;
      }
      const hash = crypto.createHash("sha256").update(suppliedCode).digest("hex");
      if (!order.deliveryCodeHash || hash !== order.deliveryCodeHash) {
        const error = new Error("INVALID_CODE"); error.code = "INVALID_CODE"; throw error;
      }

      const now = FieldValue.serverTimestamp();
      const history = Array.isArray(order.statusHistory) ? order.statusHistory : [];
      const updated = {
        status: "delivered",
        paymentStatus: "captured",
        deliveryCodeHash: FieldValue.delete(),
        deliveredAt: now,
        updatedAt: now,
        statusHistory: [...history, { status: "delivered", at: new Date().toISOString(), actorUid: uid }],
      };

      tx.update(orderRef, updated);
      tx.create(payableRef, {
        orderId: orderDoc.id,
        merchantUid: order.merchantUid,
        customerUid: order.userId,
        amount: order.total,
        currency: "NGN",
        status: "payable",
        createdAt: now,
      });

      return { duplicate: false, order: publicOrder({ id: orderDoc.id, ...order, status: "delivered", paymentStatus: "captured" }) };
    });

    return res.json({
      status: true,
      duplicate: result.duplicate,
      message: result.duplicate ? "Delivery was already confirmed" : "Delivery confirmed; merchant payable recorded",
      order: result.order,
    });
  } catch (err) {
    if (err.code === "ORDER_NOT_FOUND") return fail(res, 404, "Order not found");
    if (err.code === "FORBIDDEN") return fail(res, 403, "Only the customer can confirm delivery");
    if (err.code === "NOT_READY") return fail(res, 409, "This order is not ready for delivery confirmation");
    if (err.code === "INVALID_CODE") return fail(res, 400, "Delivery code is incorrect");
    console.error("Confirm food delivery error:", err.message || err);
    return fail(res, 500, "Unable to confirm delivery");
  }
}


// Restaurant settings are stored separately from menu and order records.
// Document ID is the configured merchant's Firebase UID, preserving a single-restaurant setup.
async function getRestaurantSettings(req, res) {
  if (!isMerchant(req)) return fail(res, 403, "Merchant access required");

  try {
    const snapshot = await db.collection(RESTAURANT_SETTINGS_COLLECTION).doc(uidOf(req)).get();
    const defaults = {
      restaurantName: "",
      description: "",
      phone: "",
      email: "",
      address: "",
      openingHours: "",
      deliveryNotes: "",
      logoUrl: "",
      acceptingOrders: true,
    };
    const settings = snapshot.exists ? { ...defaults, ...snapshot.data() } : defaults;
    return res.json({ status: true, settings });
  } catch (err) {
    console.error("Get restaurant settings error:", err.message || err);
    return fail(res, 500, "Unable to load restaurant settings");
  }
}

async function updateRestaurantSettings(req, res) {
  if (!isMerchant(req)) return fail(res, 403, "Merchant access required");

  const body = req.body || {};
  const allowedTextFields = {
    restaurantName: 120,
    description: 1000,
    phone: 40,
    email: 254,
    address: 500,
    openingHours: 500,
    deliveryNotes: 1000,
    logoUrl: 2048,
  };
  const update = {};

  for (const [field, maxLength] of Object.entries(allowedTextFields)) {
    if (body[field] === undefined) continue;
    if (typeof body[field] !== "string") {
      return fail(res, 400, `${field} must be text`);
    }
    const value = body[field].trim();
    if (value.length > maxLength) return fail(res, 400, `${field} is too long`);
    update[field] = value;
  }

  if (body.acceptingOrders !== undefined) {
    if (typeof body.acceptingOrders !== "boolean") {
      return fail(res, 400, "acceptingOrders must be true or false");
    }
    update.acceptingOrders = body.acceptingOrders;
  }

  if (update.restaurantName !== undefined && !update.restaurantName) {
    return fail(res, 400, "Restaurant name is required");
  }
  if (update.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(update.email)) {
    return fail(res, 400, "Enter a valid business email");
  }
  if (update.logoUrl && !/^https:\/\/\S+$/i.test(update.logoUrl)) {
    return fail(res, 400, "logoUrl must be an HTTPS URL");
  }
  if (!Object.keys(update).length) return fail(res, 400, "No valid settings supplied");

  try {
    const ref = db.collection(RESTAURANT_SETTINGS_COLLECTION).doc(uidOf(req));
    await ref.set({
      ...update,
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: uidOf(req),
    }, { merge: true });
    const saved = await ref.get();
    return res.json({ status: true, message: "Restaurant settings saved", settings: saved.data() || {} });
  } catch (err) {
    console.error("Update restaurant settings error:", err.message || err);
    return fail(res, 500, "Unable to save restaurant settings");
  }
}

module.exports = {
  getMenu,
  getMerchantAccess,
  listMerchantMenu,
  uploadMenuImage,
  createMenuItem,
  updateMenuItem,
  placeOrder,
  listMyOrders,
  getMyOrder,
  listMerchantOrders,
  updateOrderStatus,
  confirmDelivery,
  getRestaurantSettings,
  updateRestaurantSettings,
};
