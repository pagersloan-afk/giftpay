const admin = require("firebase-admin");
const FeeEngine = require("../../core/fees/fee_engine");
const { sendNotification } = require("../../utils/notify");
const { verifyTransactionPin } = require("../services/transactionPin.service");
const ck = require("../services/clubkonnectBills.provider");

const db = admin.firestore();

function messageOf(raw, fallback = "ClubKonnect request failed") {
  return String(raw?.orderremark || raw?.OrderRemark || raw?.message || raw?.Message || raw?.status || raw?.Status || fallback);
}

function requestWasAccepted(raw) {
  const status = String(raw?.status || raw?.Status || raw?.orderstatus || "").toUpperCase();
  const code = String(raw?.statuscode || raw?.StatusCode || "");
  if (status === "ORDER_RECEIVED" || status === "ORDER_ONHOLD" || code === "100") return true;
  return Boolean(raw?.orderid || raw?.OrderID) && ck.normalizeStatus(raw) === "PENDING";
}

function classifyVend(raw) {
  const normalized = ck.normalizeStatus(raw);
  if (normalized !== "PENDING") return normalized;
  const status = String(raw?.status || raw?.Status || raw?.orderstatus || "").toUpperCase();
  const code = String(raw?.statuscode || raw?.StatusCode || "");
  if (status.startsWith("INVALID_") || status.includes("ERROR") || status.includes("FAILED")) return "FAILED";
  if (code && code !== "100" && code !== "200") return "FAILED";
  if (requestWasAccepted(raw)) return "PENDING";
  return "FAILED";
}

async function createPendingDebit({ userId, reference, title, amount, fee, totalDebited, type, extra = {} }) {
  const walletRef = db.collection("wallets").doc(userId);
  const txn = {
    id: reference,
    type: "debit",
    title,
    amount,
    fee,
    totalDebited,
    timestamp: Date.now(),
    status: "pending",
    provider: "clubkonnect",
    ...extra,
  };
  await db.runTransaction(async (t) => {
    const snap = await t.get(walletRef);
    if (!snap.exists) throw Object.assign(new Error("Wallet not found"), { status: 404 });
    const balance = Number(snap.data()?.balance || 0);
    if (balance < totalDebited) throw Object.assign(new Error("Insufficient wallet balance"), { status: 400 });
    t.update(walletRef, {
      balance: balance - totalDebited,
      transactions: admin.firestore.FieldValue.arrayUnion(txn),
    });
  });
  return { walletRef, txn };
}

async function updateUserTransaction(userId, reference, patch) {
  await db.collection("users").doc(userId).collection("transactions").doc(reference).set({
    reference,
    provider: "clubkonnect",
    updatedAt: Date.now(),
    ...patch,
  }, { merge: true });
}

async function finalizeWallet({ userId, reference, outcome, raw, category, description }) {
  const walletRef = db.collection("wallets").doc(userId);
  let refundIssued = false;
  let cashback = 0;
  let finalized = false;
  await db.runTransaction(async (t) => {
    const snap = await t.get(walletRef);
    if (!snap.exists) throw Object.assign(new Error("Wallet not found during transaction finalization"), { status: 404 });
    const wallet = snap.data() || {};
    const transactions = Array.isArray(wallet.transactions) ? [...wallet.transactions] : [];
    const index = transactions.findIndex((item) => item?.id === reference);
    if (index < 0) throw new Error(`Wallet transaction ${reference} was not found`);
    const original = transactions[index];
    if (original.status === "success" || original.status === "refunded") return;

    if (outcome === "SUCCESS") {
      finalized = true;
      transactions[index] = { ...original, status: "success", providerStatus: "ORDER_COMPLETED", providerResponse: raw };
      cashback = Number(FeeEngine.cashback(category, Number(original.amount || 0)) || 0);
      const cashbackId = `${reference}_cashback`;
      const hasCashback = transactions.some((item) => item?.id === cashbackId);
      const updates = { transactions };
      if (cashback > 0 && !hasCashback) {
        updates.balance = admin.firestore.FieldValue.increment(cashback);
        transactions.push({
          id: cashbackId,
          type: "credit",
          title: `Cashback: ${description}`,
          amount: cashback,
          timestamp: Date.now(),
          status: "success",
          provider: "clubkonnect",
          reference,
        });
      }
      t.update(walletRef, updates);
    } else if (outcome === "FAILED") {
      finalized = true;
      const refundId = `${reference}_refund`;
      const hasRefund = transactions.some((item) => item?.id === refundId);
      transactions[index] = { ...original, status: "failed", providerStatus: "ORDER_FAILED", providerResponse: raw };
      const updates = { transactions };
      if (!hasRefund) {
        const refundAmount = Number(original.totalDebited ?? original.amount ?? 0);
        updates.balance = admin.firestore.FieldValue.increment(refundAmount);
        transactions.push({
          id: refundId,
          type: "credit",
          title: `Refund: ${description}`,
          amount: refundAmount,
          timestamp: Date.now(),
          status: "refunded",
          provider: "clubkonnect",
          reference,
        });
        refundIssued = true;
      }
      t.update(walletRef, updates);
    }
  });
  if (finalized) {
    await updateUserTransaction(userId, reference, {
      status: outcome === "SUCCESS" ? "success" : "refunded",
      providerStatus: outcome === "SUCCESS" ? "ORDER_COMPLETED" : "ORDER_FAILED",
      providerResponse: raw,
    });
  }
  if (finalized && refundIssued) {
    await sendNotification(userId, `${category} purchase failed`, "Your wallet has been refunded for the failed transaction.", category);
  } else if (finalized && outcome === "SUCCESS") {
    await sendNotification(userId, `${category} purchase successful`, "Your purchase has been completed successfully.", category);
  }
  return { cashback, refundIssued };
}

async function findWalletTransaction(reference) {
  const wallets = await db.collection("wallets").get();
  for (const doc of wallets.docs) {
    const transactions = Array.isArray(doc.data()?.transactions) ? doc.data().transactions : [];
    const txn = transactions.find((item) => item?.id === reference);
    if (txn) return { userId: doc.id, txn };
  }
  return null;
}

async function processQuery({ userId, reference, orderId, category, description }) {
  const raw = await ck.queryTransaction({ requestId: reference, orderId });
  const status = ck.normalizeStatus(raw);
  if (status === "SUCCESS" || status === "FAILED") {
    await finalizeWallet({ userId, reference, outcome: status, raw, category, description });
  }
  return { raw, status };
}

// ---------------- AIRTIME ----------------
exports.getAirtimeNetworks = async (_req, res) => {
  try {
    const items = await ck.getAirtimeNetworks();
    const networks = {};
    for (const item of items) networks[item.name] = item.code;
    return res.json({ status: true, networks, provider: "clubkonnect" });
  } catch (err) {
    console.error("[CLUBKONNECT AIRTIME NETWORKS]", err.response?.data || err.message);
    return res.status(502).json({ status: false, message: err.message || "Unable to load airtime networks" });
  }
};

exports.walletPayAirtime = async (req, res) => {
  const userId = req.user?.uid;
  try {
    if (!userId) return res.status(401).json({ status: false, message: "Unauthorized" });
    const { phone, network, amount, transactionPin } = req.body || {};
    if (!transactionPin || !/^\d{4}$/.test(String(transactionPin))) {
      return res.status(401).json({ status: false, code: "PIN_REQUIRED", message: "Transaction PIN is required" });
    }
    const pinResult = await verifyTransactionPin(userId, String(transactionPin));
    if (!pinResult.ok) return res.status(401).json({ status: false, code: pinResult.code, message: pinResult.code === "PIN_LOCKED" ? "Transaction PIN temporarily locked" : "Incorrect transaction PIN" });
    const cleanPhone = String(phone || "").trim();
    const amountInt = Number(amount);
    const networkCode = String(network || "").trim();
    if (!cleanPhone || !networkCode || !Number.isInteger(amountInt) || amountInt < 50) {
      return res.status(400).json({ status: false, message: "Enter a valid phone number, network and amount (minimum ₦50)." });
    }
    const feeResult = FeeEngine.airtime(amountInt);
    const userPays = Number(feeResult.userPays);
    const fee = Number(feeResult.fee);
    const reference = ck.makeRequestId("AIR");
    const { walletRef } = await createPendingDebit({
      userId, reference, title: `Airtime Purchase (${cleanPhone})`, amount: amountInt, fee, totalDebited: userPays, type: "airtime",
      extra: { network: networkCode, phone: cleanPhone },
    });
    await updateUserTransaction(userId, reference, { type: "airtime", phone: cleanPhone, network: networkCode, amount: amountInt, fee, totalDebited: userPays, status: "pending", timestamp: Date.now() });
    let raw;
    try {
      raw = await ck.vendAirtime({ network: networkCode, amount: amountInt, phone: cleanPhone, requestId: reference });
    } catch (err) {
      await updateUserTransaction(userId, reference, { status: "pending", error: err.message });
      return res.json({ status: true, pending: true, reference, message: "Your airtime request is processing. We are confirming its status." });
    }
    const status = classifyVend(raw);
    await updateUserTransaction(userId, reference, { providerReference: raw?.orderid || raw?.OrderID || null, providerResponse: raw, providerStatus: raw?.status || raw?.orderstatus || raw?.statuscode || null });
    if (status === "SUCCESS" || status === "FAILED") {
      const result = await finalizeWallet({ userId, reference, outcome: status, raw, category: "airtime", description: `Airtime Purchase (${cleanPhone})` });
      if (status === "FAILED") return res.status(400).json({ status: false, message: messageOf(raw, "Airtime purchase failed; refund processed."), reference, refunded: result.refundIssued });
      return res.json({ status: true, pending: false, reference, requestId: reference, fee, debited: userPays, cashback: result.cashback, message: "Airtime purchase successful" });
    }
    return res.json({ status: true, pending: true, reference, requestId: reference, fee, debited: userPays, message: "Airtime request received and is being processed." });
  } catch (err) {
    console.error("[CLUBKONNECT AIRTIME PURCHASE]", err.response?.data || err.message || err);
    return res.status(err.status || 500).json({ status: false, message: err.message || "Unable to process airtime purchase" });
  }
};

exports.requeryAirtime = async (req, res) => {
  try {
    const reference = String(req.query.reference || req.query.requestId || "").trim();
    if (!reference) return res.status(400).json({ status: false, message: "reference is required" });
    const found = await findWalletTransaction(reference);
    if (!found) return res.status(404).json({ status: false, message: "Airtime transaction not found" });
    const result = await processQuery({ userId: found.userId, reference, orderId: found.txn.providerReference, category: "airtime", description: `Airtime Purchase (${found.txn.phone || ""})` });
    return res.json({ status: true, transactionStatus: result.status, vendStatus: result.status, message: messageOf(result.raw, "Airtime status checked"), raw: result.raw });
  } catch (err) {
    console.error("[CLUBKONNECT AIRTIME REQUERY]", err.message || err);
    return res.status(502).json({ status: false, transactionStatus: "PENDING", message: err.message || "Unable to confirm airtime status" });
  }
};

// ---------------- DATA ----------------
exports.getDataNetworks = async (_req, res) => {
  try {
    const networks = await ck.getDataNetworks();
    return res.json({ status: true, networks, provider: "clubkonnect" });
  } catch (err) {
    console.error("[CLUBKONNECT DATA NETWORKS]", err.response?.data || err.message);
    return res.status(502).json({ status: false, message: err.message || "Unable to load data networks" });
  }
};

exports.getDataPlans = async (req, res) => {
  try {
    const networkCode = String(req.params.billerCode || "").trim();
    if (!networkCode) return res.status(400).json({ status: false, message: "Network code is required" });
    const plans = await ck.getDataPlans(networkCode);
    return res.json({ status: true, plans, provider: "clubkonnect" });
  } catch (err) {
    console.error("[CLUBKONNECT DATA PLANS]", err.response?.data || err.message);
    return res.status(502).json({ status: false, message: err.message || "Unable to load data plans" });
  }
};

exports.walletPayData = async (req, res) => {
  const { userId, phone, network, planId } = req.body || {};
  try {
    if (!userId || !phone || !network || !planId) return res.status(400).json({ status: false, message: "Missing userId, phone, network or planId" });
    const cleanPhone = String(phone).trim();
    const networkCode = String(network).trim();
    const plans = await ck.getDataPlans(networkCode);
    const plan = plans.find((p) => p.code === String(planId).trim());
    if (!plan) return res.status(400).json({ status: false, message: "Selected data plan is no longer available from ClubKonnect" });
    const amount = Math.round(Number(plan.price));
    if (!Number.isFinite(amount) || amount <= 0) return res.status(400).json({ status: false, message: "ClubKonnect returned an invalid price for this data plan" });
    const feeResult = FeeEngine.data(amount);
    const userPays = Number(feeResult.userPays);
    const fee = Number(feeResult.fee);
    const reference = ck.makeRequestId("DATA");
    await createPendingDebit({ userId, reference, title: `Data Purchase (${cleanPhone})`, amount, fee, totalDebited: userPays, type: "data", extra: { phone: cleanPhone, network: networkCode, planId: plan.code, planName: plan.name } });
    await updateUserTransaction(userId, reference, { type: "data", phone: cleanPhone, network: networkCode, planId: plan.code, planName: plan.name, amount, fee, totalDebited: userPays, status: "pending", timestamp: Date.now() });
    let raw;
    try {
      raw = await ck.vendData({ network: networkCode, planCode: plan.code, phone: cleanPhone, requestId: reference });
    } catch (err) {
      await updateUserTransaction(userId, reference, { status: "pending", error: err.message });
      return res.json({ status: true, pending: true, requestId: reference, reference, message: "Your data purchase is processing. We are confirming its status." });
    }
    const status = classifyVend(raw);
    await updateUserTransaction(userId, reference, { providerReference: raw?.orderid || raw?.OrderID || null, providerResponse: raw, providerStatus: raw?.status || raw?.orderstatus || raw?.statuscode || null });
    if (status === "SUCCESS" || status === "FAILED") {
      const result = await finalizeWallet({ userId, reference, outcome: status, raw, category: "data", description: `Data Purchase (${cleanPhone})` });
      if (status === "FAILED") return res.status(400).json({ status: false, message: messageOf(raw, "Data purchase failed; refund processed."), requestId: reference, reference, refunded: result.refundIssued });
      return res.json({ status: true, pending: false, requestId: reference, reference, fee, debited: userPays, cashback: result.cashback, message: "Data purchase successful" });
    }
    return res.json({ status: true, pending: true, requestId: reference, reference, fee, debited: userPays, message: "Data purchase received and is being processed." });
  } catch (err) {
    console.error("[CLUBKONNECT DATA PURCHASE]", err.response?.data || err.message || err);
    return res.status(err.status || 500).json({ status: false, message: err.message || "Unable to process data purchase" });
  }
};

exports.requeryData = async (req, res) => {
  try {
    const reference = String(req.params.requestId || "").trim();
    const found = await findWalletTransaction(reference);
    if (!found) return res.json({ status: true, data: { status: "PENDING", remark: "Transaction not found yet" } });
    const result = await processQuery({ userId: found.userId, reference, orderId: found.txn.providerReference, category: "data", description: `Data Purchase (${found.txn.phone || ""})` });
    return res.json({ status: true, data: { status: result.status === "SUCCESS" ? "ORDER_COMPLETED" : result.status === "FAILED" ? "ORDER_FAILED" : "PENDING", remark: messageOf(result.raw, "Data purchase status checked") } });
  } catch (err) {
    console.error("[CLUBKONNECT DATA REQUERY]", err.message || err);
    return res.json({ status: false, data: { status: "PENDING", remark: err.message || "Unable to confirm data purchase status" } });
  }
};

// ---------------- ELECTRICITY ----------------
exports.getDiscos = async (_req, res) => res.json({ status: true, data: ck.DISCOS.map(({ code, name }) => ({ code, name })), provider: "clubkonnect" });

exports.getElectricityProducts = async (req, res) => {
  const disco = ck.findDisco(req.params.billerCode);
  if (!disco) return res.status(404).json({ status: false, message: "Unsupported electricity distribution company" });
  return res.json({ status: true, billerCode: disco.code, products: [
    { code: "01", name: "Prepaid", amount: null, priceType: "OPEN" },
    { code: "02", name: "Postpaid", amount: null, priceType: "OPEN" },
  ], provider: "clubkonnect" });
};

exports.verifyMeter = async (req, res) => {
  try {
    const meterNumber = String(req.body?.meterNumber || "").trim();
    const disco = String(req.body?.billerCode || req.body?.discoCode || "").trim();
    const meterType = req.body?.meterType || req.body?.productCode;
    if (!meterNumber || !disco) return res.status(400).json({ status: false, message: "Meter number and distribution company are required" });
    const raw = await ck.verifyMeter({ disco, meterNumber, meterType });
    const customerName = String(raw?.customer_name || raw?.customerName || "").trim();
    if (!customerName || customerName.toUpperCase().includes("INVALID")) return res.status(400).json({ status: false, message: "Invalid meter number. Please check the number and meter type.", raw });
    return res.json({ status: true, customerName, address: raw?.customer_address || "", meterNumber, billerCode: ck.findDisco(disco).code, productCode: ck.normalizeMeterType(meterType), meterType: ck.normalizeMeterType(meterType), validationReference: null, raw });
  } catch (err) {
    console.error("[CLUBKONNECT METER VERIFY]", err.response?.data || err.message || err);
    return res.status(err.status || 502).json({ status: false, message: err.message || "Unable to verify meter" });
  }
};

exports.walletPayElectricity = async (req, res) => {
  const userId = String(req.body?.userId || "").trim();
  try {
    const meterNumber = String(req.body?.meterNumber || "").trim();
    const disco = String(req.body?.billerCode || req.body?.discoCode || req.body?.disco || "").trim();
    const meterType = req.body?.meterType || req.body?.productCode;
    const phone = String(req.body?.phone || "").trim();
    const amount = Math.round(Number(req.body?.amount));
    if (!userId || !meterNumber || !disco || !Number.isFinite(amount)) return res.status(400).json({ status: false, message: "Missing userId, meterNumber, distribution company or valid amount" });
    if (amount < 200) return res.status(400).json({ status: false, message: "Minimum electricity purchase is ₦200" });
    const normalizedMeterType = ck.normalizeMeterType(meterType);
    const feeResult = FeeEngine.electricity(amount);
    const userPays = Number(feeResult.userPays);
    const fee = Number(feeResult.fee);
    const reference = ck.makeRequestId("ELEC");
    await createPendingDebit({ userId, reference, title: `Electricity Purchase (${meterNumber})`, amount, fee, totalDebited: userPays, type: "electricity", extra: { meterNumber, disco, meterType: normalizedMeterType, phone } });
    await updateUserTransaction(userId, reference, { type: "electricity", meterNumber, disco, billerCode: disco, meterType: normalizedMeterType, amount, fee, totalDebited: userPays, phone, status: "pending", timestamp: Date.now() });
    let raw;
    try {
      raw = await ck.vendElectricity({ disco, meterNumber, meterType: normalizedMeterType, amount, phone, requestId: reference });
    } catch (err) {
      await updateUserTransaction(userId, reference, { status: "pending", error: err.message });
      return res.json({ status: true, pending: true, requestId: reference, reference, message: "Your electricity payment is processing. We are confirming its status." });
    }
    const status = classifyVend(raw);
    const orderId = raw?.orderid || raw?.OrderID || null;
    await updateUserTransaction(userId, reference, { providerReference: orderId, orderId, providerResponse: raw, providerStatus: raw?.status || raw?.statuscode || null, token: raw?.metertoken || null, units: raw?.units || null });
    if (status === "SUCCESS" || status === "FAILED") {
      const result = await finalizeWallet({ userId, reference, outcome: status, raw, category: "electricity", description: `Electricity Purchase (${meterNumber})` });
      if (status === "FAILED") return res.status(400).json({ status: false, message: messageOf(raw, "Electricity payment failed; refund processed."), requestId: reference, reference, refunded: result.refundIssued });
      return res.json({ status: true, pending: false, requestId: reference, reference, vendStatus: "SUCCESS", amount, fee, debited: userPays, meterNumber, raw });
    }
    return res.json({ status: true, pending: true, requestId: reference, reference, vendStatus: "IN_PROGRESS", message: "Electricity order received and is being processed." });
  } catch (err) {
    console.error("[CLUBKONNECT ELECTRICITY PURCHASE]", err.response?.data || err.message || err);
    return res.status(err.status || 500).json({ status: false, message: err.message || "Unable to process electricity payment" });
  }
};

exports.requeryElectricity = async (req, res) => {
  try {
    const userId = String(req.body?.userId || "").trim();
    const reference = String(req.body?.requestId || req.body?.reference || "").trim();
    if (!userId || !reference) return res.status(400).json({ status: false, message: "Missing userId or requestId" });
    const txSnap = await db.collection("users").doc(userId).collection("transactions").doc(reference).get();
    const txn = txSnap.exists ? txSnap.data() : {};
    const result = await processQuery({ userId, reference, orderId: txn?.providerReference || txn?.orderId, category: "electricity", description: `Electricity Purchase (${txn?.meterNumber || ""})` });
    const raw = result.raw || {};
    return res.json({ status: true, pending: result.status === "PENDING", refunded: result.status === "FAILED", vendStatus: result.status, status: result.status, message: messageOf(raw, "Electricity transaction status checked"), raw });
  } catch (err) {
    console.error("[CLUBKONNECT ELECTRICITY REQUERY]", err.message || err);
    return res.status(502).json({ status: false, pending: true, vendStatus: "IN_PROGRESS", message: err.message || "Unable to confirm electricity transaction" });
  }
};

exports.requeryBills = async (req, res) => {
  try {
    const reference = String(req.query.reference || "").trim();
    if (!reference) return res.status(400).json({ status: false, message: "reference is required" });
    const found = await findWalletTransaction(reference);
    if (!found) return res.status(404).json({ status: false, message: "Transaction not found" });
    const category = String(found.txn.title || "").toLowerCase().includes("airtime") ? "airtime" : "data";
    const result = await processQuery({ userId: found.userId, reference, orderId: found.txn.providerReference, category, description: found.txn.title || `${category} purchase` });
    return res.json({ status: true, transactionStatus: result.status, message: messageOf(result.raw, "Transaction status checked"), raw: result.raw });
  } catch (err) {
    console.error("[CLUBKONNECT BILLS REQUERY]", err.message || err);
    return res.status(502).json({ status: false, transactionStatus: "PENDING", message: err.message || "Unable to confirm transaction status" });
  }
};
