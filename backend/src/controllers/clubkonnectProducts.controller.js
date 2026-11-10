const admin = require("firebase-admin");
const FeeEngine = require("../../core/fees/fee_engine");
const { verifyTransactionPin } = require("../services/transactionPin.service");
const provider = require("../services/clubkonnectProducts.service");
const { sendNotification } = require("../../utils/notify");

const db = admin.firestore();
const SUPPORTED = new Set(["airtime-pin", "data-pin", "smile", "waec", "jamb"]);
const phonePattern = /^\+?[0-9]{10,15}$/;

function cleanMessage(raw, fallback) {
  return String(raw?.orderremark || raw?.OrderRemark || raw?.remark || raw?.message || raw?.Message || fallback);
}
function extractOrderId(raw) { return raw?.orderid || raw?.OrderID || raw?.ORDER_ID || null; }

async function savePendingDebit({ userId, reference, title, amount, totalDebited, details }) {
  const walletRef = db.collection("wallets").doc(userId);
  const userTxnRef = db.collection("users").doc(userId).collection("transactions").doc(reference);
  const walletTxn = {
    id: reference, type: "debit", title, amount, fee: 0, totalDebited,
    timestamp: Date.now(), status: "pending", provider: "clubkonnect", ...details,
  };
  await db.runTransaction(async (tx) => {
    const walletSnap = await tx.get(walletRef);
    if (!walletSnap.exists) throw Object.assign(new Error("Wallet not found."), { status: 404 });
    const wallet = walletSnap.data() || {};
    const balance = Number(wallet.balance || 0);
    if (balance < totalDebited) throw Object.assign(new Error("Insufficient wallet balance."), { status: 400 });
    const transactions = Array.isArray(wallet.transactions) ? wallet.transactions : [];
    if (transactions.some((item) => item?.id === reference)) throw Object.assign(new Error("Duplicate transaction reference."), { status: 409 });
    tx.update(walletRef, { balance: balance - totalDebited, transactions: admin.firestore.FieldValue.arrayUnion(walletTxn) });
    tx.set(userTxnRef, {
      reference, id: reference, userId, provider: "clubkonnect", type: "clubkonnect_product",
      title, amount, totalDebited, status: "pending", timestamp: Date.now(), ...details,
    });
  });
  return { walletRef, userTxnRef };
}

async function finalize({ userId, reference, outcome, raw }) {
  const walletRef = db.collection("wallets").doc(userId);
  const userTxnRef = db.collection("users").doc(userId).collection("transactions").doc(reference);
  let didFinalize = false;
  let refunded = false;
  let delivery = provider.extractDelivery(raw || {});
  await db.runTransaction(async (tx) => {
    const [walletSnap, userTxnSnap] = await Promise.all([tx.get(walletRef), tx.get(userTxnRef)]);
    if (!walletSnap.exists || !userTxnSnap.exists) throw new Error("The original wallet transaction could not be found.");
    const original = userTxnSnap.data() || {};
    if (["success", "refunded", "failed"].includes(String(original.status).toLowerCase())) return;
    const wallet = walletSnap.data() || {};
    const list = Array.isArray(wallet.transactions) ? [...wallet.transactions] : [];
    const index = list.findIndex((item) => item?.id === reference);
    if (index < 0) throw new Error("Wallet debit record could not be found.");
    if (outcome === "SUCCESS") {
      list[index] = { ...list[index], status: "success", providerStatus: "ORDER_COMPLETED", providerOrderId: extractOrderId(raw), delivery, providerResponse: raw };
      tx.update(walletRef, { transactions: list });
      tx.set(userTxnRef, { status: "success", providerStatus: "ORDER_COMPLETED", providerOrderId: extractOrderId(raw), delivery, providerResponse: raw, completedAt: Date.now() }, { merge: true });
      didFinalize = true;
    } else if (outcome === "FAILED") {
      const refundId = `${reference}_refund`;
      const hasRefund = list.some((item) => item?.id === refundId);
      list[index] = { ...list[index], status: "refunded", providerStatus: "ORDER_FAILED", providerOrderId: extractOrderId(raw), providerResponse: raw };
      const updates = { transactions: list };
      if (!hasRefund) {
        const refundAmount = Number(original.totalDebited ?? original.amount ?? 0);
        updates.balance = admin.firestore.FieldValue.increment(refundAmount);
        list.push({
          id: refundId, type: "credit", title: `Refund: ${original.title || "ClubKonnect purchase"}`,
          amount: refundAmount, timestamp: Date.now(), status: "refunded", provider: "clubkonnect", reference,
        });
        updates.transactions = list;
        refunded = true;
      }
      tx.update(walletRef, updates);
      tx.set(userTxnRef, { status: "refunded", providerStatus: "ORDER_FAILED", providerOrderId: extractOrderId(raw), providerResponse: raw, refundedAt: Date.now() }, { merge: true });
      didFinalize = true;
    }
  });
  if (didFinalize) {
    try {
      await sendNotification(userId,
        outcome === "SUCCESS" ? "Purchase successful" : "Purchase failed — refund processed",
        outcome === "SUCCESS" ? "Your ClubKonnect purchase has been completed." : "Your wallet has been refunded for the failed purchase.",
        "bills");
    } catch (error) { console.warn("[CLUBKONNECT PRODUCT NOTIFICATION]", error.message); }
  }
  return { finalized: didFinalize, refunded, delivery };
}

function packageByCode(packages, code) {
  return (packages || []).find((item) => String(item.code) === String(code));
}

exports.catalog = async (_req, res) => {
  try {
    const names = ["airtimeNetworks", "dataNetworks", "smilePackages", "waecPackages", "jambPackages"];
    const loaders = [provider.getAirtimeNetworks, provider.getDataNetworks, provider.getSmilePackages, provider.getWaecPackages, provider.getJambPackages];
    const settled = await Promise.allSettled(loaders.map((load) => load()));
    const catalog = { airtimePinValues: [100, 200, 500] };
    const unavailable = [];
    settled.forEach((result, index) => {
      catalog[names[index]] = result.status === "fulfilled" ? result.value : [];
      if (result.status === "rejected") unavailable.push(names[index]);
    });
    return res.json({ status: true, catalog, unavailable });
  } catch (error) {
    console.error("[CLUBKONNECT PRODUCTS CATALOG]", error.response?.data || error.message);
    return res.status(502).json({ status: false, message: "Unable to load ClubKonnect product catalogue. Please try again shortly." });
  }
};

exports.dataPinPlans = async (req, res) => {
  try {
    const network = String(req.params.network || "").trim();
    if (!network) return res.status(400).json({ status: false, message: "Select a mobile network." });
    const plans = await provider.getDataPinPlans(network);
    return res.json({ status: true, plans });
  } catch (error) {
    console.error("[CLUBKONNECT DATA PIN PLANS]", error.response?.data || error.message);
    return res.status(502).json({ status: false, message: "Unable to load data PIN plans." });
  }
};

exports.verifySmile = async (req, res) => {
  try {
    const account = String(req.body?.account || "").trim();
    if (!account) return res.status(400).json({ status: false, message: "Enter your Smile account number." });
    const raw = await provider.verifySmileAccount(account);
    const name = String(raw?.customer_name || raw?.customerName || "").trim();
    if (!name || name.toUpperCase().includes("INVALID")) return res.status(400).json({ status: false, message: "Smile account could not be verified." });
    return res.json({ status: true, customerName: name, raw });
  } catch (error) {
    console.error("[CLUBKONNECT SMILE VERIFY]", error.response?.data || error.message);
    return res.status(502).json({ status: false, message: "Unable to verify this Smile account." });
  }
};

exports.verifyJamb = async (req, res) => {
  try {
    const examType = String(req.body?.examType || "").trim();
    const profileId = String(req.body?.profileId || "").trim();
    if (!examType || !profileId) return res.status(400).json({ status: false, message: "Exam type and JAMB profile ID are required." });
    const raw = await provider.verifyJambProfile(examType, profileId);
    const name = String(raw?.customer_name || raw?.customerName || "").trim();
    if (!name || name.toUpperCase().includes("INVALID")) return res.status(400).json({ status: false, message: "JAMB profile ID could not be verified." });
    return res.json({ status: true, customerName: name, raw });
  } catch (error) {
    console.error("[CLUBKONNECT JAMB VERIFY]", error.response?.data || error.message);
    return res.status(502).json({ status: false, message: "Unable to verify this JAMB profile." });
  }
};

exports.purchase = async (req, res) => {
  const userId = req.user?.uid;
  try {
    if (!userId) return res.status(401).json({ status: false, message: "Please sign in again." });
    const body = req.body || {};
    const product = String(body.product || "").trim().toLowerCase();
    const transactionPin = String(body.transactionPin || "").trim();
    if (!SUPPORTED.has(product)) return res.status(400).json({ status: false, message: "Unsupported product selected." });
    if (!/^\d{4}$/.test(transactionPin)) return res.status(401).json({ status: false, code: "PIN_REQUIRED", message: "Enter your 4-digit transaction PIN." });
    const pin = await verifyTransactionPin(userId, transactionPin);
    if (!pin.ok) return res.status(401).json({ status: false, code: pin.code, message: pin.code === "PIN_LOCKED" ? "Transaction PIN temporarily locked." : pin.code === "PIN_NOT_SET" ? "Set your transaction PIN before making this purchase." : "Incorrect transaction PIN." });

    const quantity = Number(body.quantity ?? 1);
    if (!Number.isInteger(quantity) || quantity < 1 || quantity > 100) return res.status(400).json({ status: false, message: "Quantity must be between 1 and 100." });
    if (["smile", "waec", "jamb"].includes(product) && quantity !== 1) return res.status(400).json({ status: false, message: "Quantity must be 1 for this product." });
    let amount = 0;
    let details = { product, quantity };
    let title = "";
    const recipient = String(body.recipient || "").trim();
    if (product === "smile" && (recipient.length < 4 || recipient.length > 30)) return res.status(400).json({ status: false, message: "Enter a valid Smile account number." });
    if (["waec", "jamb"].includes(product) && !phonePattern.test(recipient)) return res.status(400).json({ status: false, message: "Enter a valid recipient phone number (10–15 digits)." });

    if (product === "airtime-pin") {
      const network = String(body.network || "").trim();
      const value = Number(body.value);
      if (!network || ![100, 200, 500].includes(value)) return res.status(400).json({ status: false, message: "Select a network and a valid airtime PIN value." });
      amount = value * quantity;
      details = { ...details, network, unitValue: value, recipient: null };
      title = `Airtime Recharge PIN (${network}) × ${quantity}`;
    } else if (product === "data-pin") {
      const network = String(body.network || "").trim();
      const planCode = String(body.planCode || "").trim();
      if (!network || !planCode) return res.status(400).json({ status: false, message: "Select a network and data PIN plan." });
      const plans = await provider.getDataPinPlans(network);
      const plan = packageByCode(plans, planCode);
      if (!plan) return res.status(400).json({ status: false, message: "The selected data PIN plan is no longer available. Refresh the plans and try again." });
      amount = Number(plan.amount) * quantity;
      details = { ...details, network, planCode, planName: plan.name, recipient: null };
      title = `Data Recharge PIN — ${plan.name} × ${quantity}`;
    } else {
      const code = String(body.planCode || body.examType || "").trim();
      if (!code) return res.status(400).json({ status: false, message: "Select a package." });
      let packages;
      if (product === "smile") packages = await provider.getSmilePackages();
      else if (product === "waec") packages = await provider.getWaecPackages();
      else packages = await provider.getJambPackages();
      const selected = packageByCode(packages, code);
      if (!selected) return res.status(400).json({ status: false, message: "The selected package is no longer available. Refresh the catalogue and try again." });
      amount = Number(selected.amount);
      details = { ...details, planCode: code, planName: selected.name, recipient };
      if (product === "jamb" && body.profileId) details.profileId = String(body.profileId).trim();
      title = `${product.toUpperCase()} — ${selected.name}`;
    }
    if (!Number.isFinite(amount) || amount <= 0) return res.status(400).json({ status: false, message: "The provider returned an invalid product price." });
    amount = Math.round(amount * 100) / 100;
    const reference = `CKP-${Date.now()}-${require("crypto").randomBytes(4).toString("hex")}`;
    const feeResult = product === "airtime-pin" ? FeeEngine.airtime(amount) : FeeEngine.data(amount);
    const totalDebited = Number(feeResult.userPays ?? amount);
    await savePendingDebit({ userId, reference, title, amount, totalDebited, details: { ...details, fee: Number(feeResult.fee || 0) } });

    let raw;
    try {
      raw = await provider.vend({
        product, network: details.network, value: details.unitValue, planCode: details.planCode,
        quantity, recipient, examType: details.planCode, requestId: reference,
      });
    } catch (providerError) {
      await db.collection("users").doc(userId).collection("transactions").doc(reference).set({ providerError: providerError.message, lastCheckedAt: Date.now() }, { merge: true });
      return res.json({ status: true, pending: true, reference, message: "Your request was submitted but the provider has not confirmed the result yet. Your wallet debit is being held safely while we check." });
    }
    const outcome = provider.classify(raw);
    const orderId = extractOrderId(raw);
    await db.collection("users").doc(userId).collection("transactions").doc(reference).set({ providerOrderId: orderId, providerResponse: raw, providerStatus: raw?.orderstatus || raw?.status || raw?.statuscode || null }, { merge: true });
    if (outcome === "SUCCESS" || outcome === "FAILED") {
      const result = await finalize({ userId, reference, outcome, raw });
      if (outcome === "FAILED") return res.status(400).json({ status: false, refunded: result.refunded, reference, message: cleanMessage(raw, "Purchase failed; your wallet refund has been processed.") });
      return res.json({ status: true, pending: false, reference, amount, debited: totalDebited, delivery: result.delivery, message: "Purchase completed successfully." });
    }
    return res.json({ status: true, pending: true, reference, amount, debited: totalDebited, message: "Your purchase is processing. We will confirm the result shortly." });
  } catch (error) {
    console.error("[CLUBKONNECT PRODUCT PURCHASE]", error.response?.data || error.message);
    return res.status(error.status || 500).json({ status: false, message: error.message || "Unable to process this purchase." });
  }
};

exports.requery = async (req, res) => {
  const userId = req.user?.uid;
  try {
    if (!userId) return res.status(401).json({ status: false, message: "Please sign in again." });
    const reference = String(req.params.reference || "").trim();
    if (!reference) return res.status(400).json({ status: false, message: "Transaction reference is required." });
    const ref = db.collection("users").doc(userId).collection("transactions").doc(reference);
    const snap = await ref.get();
    if (!snap.exists) return res.status(404).json({ status: false, message: "Transaction not found." });
    const txn = snap.data() || {};
    if (txn.status === "success") return res.json({ status: true, transactionStatus: "SUCCESS", delivery: txn.delivery || null, message: "Purchase completed." });
    if (["failed", "refunded"].includes(txn.status)) return res.json({ status: true, transactionStatus: "FAILED", refunded: true, message: "Purchase failed and wallet refund was processed." });
    const raw = await provider.query(reference, txn.providerOrderId);
    const outcome = provider.classify(raw);
    if (outcome === "SUCCESS" || outcome === "FAILED") await finalize({ userId, reference, outcome, raw });
    const updated = await ref.get();
    const latest = updated.data() || {};
    return res.json({ status: true, transactionStatus: outcome, pending: outcome === "PENDING", delivery: latest.delivery || provider.extractDelivery(raw), refunded: latest.status === "refunded", message: outcome === "PENDING" ? "The provider has not confirmed this transaction yet." : outcome === "SUCCESS" ? "Purchase completed." : "Purchase failed; refund processed." });
  } catch (error) {
    console.error("[CLUBKONNECT PRODUCT REQUERY]", error.response?.data || error.message);
    return res.status(502).json({ status: false, pending: true, transactionStatus: "PENDING", message: "We could not confirm the provider status right now. Your transaction remains pending; please check again shortly." });
  }
};
