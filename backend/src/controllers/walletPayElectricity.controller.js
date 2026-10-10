const admin = require("firebase-admin");
const { vend, requery } = require("../services/monnifyBills.service.js");
const { sendNotification } = require("../../utils/notify");
const FeeEngine = require("../../core/fees/fee_engine");

const COOLDOWN_MS = 10 * 60 * 1000;
const db = admin.firestore();

function normalizeStatus(value) {
  return String(value || "").trim().toUpperCase();
}

async function getUserEmail(userId) {
  const authUser = await admin.auth().getUser(userId);
  const email = String(authUser?.email || "").trim();
  if (!email) {
    throw Object.assign(new Error("A verified user email is required for Monnify Bills Payment"), {
      status: 400,
    });
  }
  return email;
}

function providerBody(response) {
  return response?.responseBody ?? response?.data ?? response ?? {};
}

async function refundTransaction({ userId, reference, txn, reason, raw }) {
  const walletRef = db.collection("wallets").doc(userId);
  const walletDoc = await walletRef.get();
  const walletData = walletDoc.exists ? walletDoc.data() : {};
  const transactions = Array.isArray(walletData.transactions)
    ? walletData.transactions
    : [];

  const updated = transactions.map((item) =>
    item?.id === reference ? { ...item, status: "refunded" } : item
  );

  const alreadyRefunded = transactions.some(
    (item) => item?.id === `${reference}_refund`
  );

  const updates = {
    balance: Number(walletData.balance || 0) + Number(txn.totalDebited || txn.amount || 0),
    transactions: alreadyRefunded
      ? updated
      : [
          ...updated,
          {
            id: `${reference}_refund`,
            type: "credit",
            title: `Refund: Electricity Purchase Failed (${txn.meterNumber})`,
            amount: Number(txn.totalDebited || txn.amount || 0),
            timestamp: Date.now(),
            status: "refunded",
            reason,
          },
        ],
  };

  await walletRef.set(updates, { merge: true });

  await db
    .collection("users")
    .doc(userId)
    .collection("transactions")
    .doc(reference)
    .set(
      {
        status: "refunded",
        raw,
        updatedAt: Date.now(),
      },
      { merge: true }
    );
}

exports.walletPayElectricityController = async (req, res) => {
  try {
    const userId = String(req.body?.userId || "").trim();
    const meterNumber = String(req.body?.meterNumber || "").trim();
    const billerCode = String(req.body?.billerCode || req.body?.discoCode || req.body?.disco || "").trim();
    const productCode = String(req.body?.productCode || "").trim();
    const meterType = String(req.body?.meterType || "").trim();
    const phone = String(req.body?.phone || "").trim();
    const validationReference = String(req.body?.validationReference || "").trim();
    const amountInt = Math.round(Number(req.body?.amount));

    if (!userId || !meterNumber || !billerCode || !productCode || !Number.isFinite(amountInt)) {
      return res.status(400).json({
        status: false,
        message: "Missing userId, meterNumber, billerCode, productCode or valid amount",
      });
    }

    if (amountInt < 200) {
      return res.status(400).json({
        status: false,
        message: "Invalid amount (min ₦200)",
      });
    }

    const feeResult = FeeEngine.electricity(amountInt);
    const userPays = Number(feeResult.userPays);
    const fee = Number(feeResult.fee);

    const txSnap = await db
      .collection("users")
      .doc(userId)
      .collection("transactions")
      .where("type", "==", "electricity")
      .where("meterNumber", "==", meterNumber)
      .where("disco", "==", billerCode)
      .orderBy("timestamp", "desc")
      .limit(1)
      .get();

    if (!txSnap.empty) {
      const lastTx = txSnap.docs[0].data();
      const age = Date.now() - Number(lastTx.timestamp || 0);
      if (age < COOLDOWN_MS && lastTx.status === "pending") {
        return res.status(429).json({
          status: false,
          code: "COOLDOWN_PENDING",
          message: "You have a recent electricity request for this meter still processing. Please wait and use Requery in history.",
        });
      }
    }

    const walletRef = db.collection("wallets").doc(userId);
    const walletDoc = await walletRef.get();
    if (!walletDoc.exists) {
      return res.status(404).json({ status: false, message: "Wallet not found" });
    }

    const currentBalance = Number(walletDoc.data()?.balance || 0);
    if (currentBalance < userPays) {
      return res.status(400).json({ status: false, message: "Insufficient wallet balance" });
    }

    const emailAddress = await getUserEmail(userId);
    const reference = `WL-ELEC-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
    const timestamp = Date.now();

    const debitTx = {
      id: reference,
      type: "debit",
      title: `Electricity Purchase (${meterNumber})`,
      amount: amountInt,
      fee,
      totalDebited: userPays,
      timestamp,
      status: "pending",
      provider: "monnify",
    };

    await walletRef.set(
      {
        balance: currentBalance - userPays,
        transactions: admin.firestore.FieldValue.arrayUnion(debitTx),
      },
      { merge: true }
    );

    await db
      .collection("users")
      .doc(userId)
      .collection("transactions")
      .doc(reference)
      .set({
        type: "electricity",
        provider: "monnify",
        meterNumber,
        disco: billerCode,
        billerCode,
        meterType,
        productCode,
        amount: amountInt,
        fee,
        totalDebited: userPays,
        phone,
        reference,
        status: "pending",
        timestamp,
      });

    await sendNotification(
      userId,
      "Wallet debited",
      `₦${userPays} debited for electricity purchase (${meterNumber})`,
      "electricity"
    );

    const vendResponse = await vend({
      amount: amountInt,
      customerId: meterNumber,
      productCode,
      reference,
      emailAddress,
      phoneNumber: phone || undefined,
      validationReference: validationReference || undefined,
    });

    const body = providerBody(vendResponse);
    const vendStatus = normalizeStatus(body?.vendStatus);
    const transactionReference = body?.transactionReference || null;
    const vendReference = body?.vendReference || reference;

    await db
      .collection("users")
      .doc(userId)
      .collection("transactions")
      .doc(reference)
      .set(
        {
          providerReference: vendReference,
          transactionReference,
          vendStatus,
          raw: vendResponse,
          updatedAt: Date.now(),
        },
        { merge: true }
      );

    if (vendStatus === "SUCCESS") {
      const cashback = Number(FeeEngine.cashback("electricity", amountInt) || 0);

      const walletNow = await walletRef.get();
      const walletNowData = walletNow.data() || {};
      const txs = Array.isArray(walletNowData.transactions) ? walletNowData.transactions : [];
      const finalized = txs.map((item) =>
        item?.id === reference ? { ...item, status: "success" } : item
      );

      const walletUpdates = { transactions: finalized };
      if (cashback > 0) {
        walletUpdates.balance = admin.firestore.FieldValue.increment(cashback);
        walletUpdates.transactions = admin.firestore.FieldValue.arrayUnion({
          id: `${reference}_cashback`,
          type: "credit",
          title: `Cashback: Electricity Purchase (${meterNumber})`,
          amount: cashback,
          timestamp: Date.now(),
          status: "success",
        });
      }
      await walletRef.set(walletUpdates, { merge: true });

      await db
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .doc(reference)
        .set(
          {
            status: "success",
            cashback,
            vendStatus,
            raw: vendResponse,
            updatedAt: Date.now(),
          },
          { merge: true }
        );

      await sendNotification(
        userId,
        "Electricity purchase successful",
        `Electricity purchase for meter ${meterNumber} was completed.`,
        "electricity"
      );

      return res.json({
        status: true,
        pending: false,
        requestId: reference,
        reference,
        transactionReference,
        vendStatus,
        amount: amountInt,
        fee,
        debited: userPays,
        cashback,
        meterNumber,
        billerCode,
        productCode,
        raw: vendResponse,
      });
    }

    if (vendStatus === "IN_PROGRESS") {
      return res.json({
        status: true,
        pending: true,
        requestId: reference,
        reference,
        transactionReference,
        vendStatus,
        message: "Processing electricity purchase...",
      });
    }

    await refundTransaction({
      userId,
      reference,
      txn: debitTx,
      reason: body?.message || body?.responseMessage || "Monnify vending failed",
      raw: vendResponse,
    });

    return res.status(400).json({
      status: false,
      message: body?.message || body?.responseMessage || "Electricity vending failed",
      reference,
      transactionReference,
      vendStatus,
      raw: vendResponse,
    });
  } catch (err) {
    console.error("Monnify wallet electricity error:", err);
    return res.status(err.status || 500).json({
      status: false,
      message: err.message || "Server error processing electricity payment. If you were debited, use Requery.",
      provider: err.provider,
    });
  }
};

exports.reconcileElectricityWithMonnify = async ({ userId, reference }) => {
  const response = await requery(reference);
  const body = providerBody(response);
  const vendStatus = normalizeStatus(body?.vendStatus);
  const txRef = db.collection("users").doc(userId).collection("transactions").doc(reference);
  const snap = await txRef.get();
  const txn = snap.exists ? snap.data() : null;
  if (!txn) throw Object.assign(new Error("Electricity transaction not found"), { status: 404 });
  return { response, body, vendStatus, txn };
};
