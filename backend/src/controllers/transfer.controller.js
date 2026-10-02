
// backend/src/controllers/transfer.controller.js
//
// Monnify single-transfer integration.
// Key properties:
// - Name enquiry is required before payout.
// - Wallet debit + internal transfer records are created atomically.
// - Monnify async/OTP statuses are preserved.
// - Provider rejection codes that Monnify documents as failed are refunded.
// - Ambiguous/network errors are NOT refunded automatically.
// - Final provider status can be reconciled through /transfer-status/:reference.
// - MFA authorization/resend endpoints are included because Monnify enables MFA
//   by default for disbursement accounts.

const axios = require("axios");
const admin = require("firebase-admin");
const FeeEngine = require("../../core/fees/fee_engine");
const { verifyTransactionPin } = require("../services/transactionPin.service");

const db = admin.firestore();

const MONNIFY_API_KEY = process.env.MONNIFY_API_KEY;
const MONNIFY_SECRET_KEY = process.env.MONNIFY_SECRET_KEY;
const MONNIFY_MERCHANT_CODE = process.env.MONNIFY_MERCHANT_CODE;

const MONNIFY_BASE_URL =
  process.env.MONNIFY_BASE_URL || "https://sandbox.monnify.com";

const MONNIFY_WALLET_ACCOUNT_NUMBER =
  process.env.MONNIFY_WALLET_ACCOUNT_NUMBER;

if (!MONNIFY_API_KEY) console.warn("⚠️ MONNIFY_API_KEY is not set.");
if (!MONNIFY_SECRET_KEY) console.warn("⚠️ MONNIFY_SECRET_KEY is not set.");
if (!MONNIFY_MERCHANT_CODE) console.warn("⚠️ MONNIFY_MERCHANT_CODE is not set.");
if (!MONNIFY_WALLET_ACCOUNT_NUMBER) {
  console.warn("⚠️ MONNIFY_WALLET_ACCOUNT_NUMBER is not set.");
}

let cachedAccessToken = null;
let tokenExpiresAt = 0;

class MonnifyResponseError extends Error {
  constructor(message, responseData = null, status = null) {
    super(message);
    this.name = "MonnifyResponseError";
    this.responseData = responseData;
    this.httpStatus = status;
  }
}

function getProviderCode(data) {
  return String(data?.responseCode || "").trim().toUpperCase();
}

function getProviderMessage(data) {
  return (
    data?.responseMessage ||
    data?.responseBody?.transactionDescription ||
    "Monnify rejected the request"
  );
}

async function getMonnifyAccessToken() {
  const now = Date.now();

  if (cachedAccessToken && now < tokenExpiresAt - 60_000) {
    return cachedAccessToken;
  }

  if (!MONNIFY_API_KEY || !MONNIFY_SECRET_KEY) {
    throw new Error("MONNIFY_API_KEY or MONNIFY_SECRET_KEY is not configured");
  }

  try {
    const credentials = Buffer.from(
      `${MONNIFY_API_KEY}:${MONNIFY_SECRET_KEY}`
    ).toString("base64");

    const response = await axios.post(
      `${MONNIFY_BASE_URL}/api/v1/auth/login`,
      {},
      {
        headers: {
          Authorization: `Basic ${credentials}`,
          "Content-Type": "application/json",
        },
        timeout: 15_000,
      }
    );

    const data = response.data;

    if (!data?.requestSuccessful || !data?.responseBody?.accessToken) {
      throw new MonnifyResponseError(
        getProviderMessage(data),
        data,
        response.status
      );
    }

    cachedAccessToken = data.responseBody.accessToken;

    const expiresIn = Number(data.responseBody.expiresIn) || 3600;
    tokenExpiresAt = now + expiresIn * 1000;

    return cachedAccessToken;
  } catch (err) {
    cachedAccessToken = null;
    tokenExpiresAt = 0;
    console.error(
      "❌ Monnify authentication error:",
      err.response?.data || err.responseData || err.message
    );
    throw err;
  }
}

async function monnifyRequest(config, retry = true) {
  try {
    const token = await getMonnifyAccessToken();

    const response = await axios({
      ...config,
      baseURL: MONNIFY_BASE_URL,
      headers: {
        ...(config.headers || {}),
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      timeout: 30_000,
    });

    // Monnify can return HTTP 200 while requestSuccessful is false.
    if (response.data && response.data.requestSuccessful === false) {
      throw new MonnifyResponseError(
        getProviderMessage(response.data),
        response.data,
        response.status
      );
    }

    return response;
  } catch (err) {
    const providerData = err.response?.data || err.responseData;
    const providerCode = getProviderCode(providerData);

    if (
      retry &&
      (
        err.response?.status === 401 ||
        providerCode === "401"
      )
    ) {
      cachedAccessToken = null;
      tokenExpiresAt = 0;
      return monnifyRequest(config, false);
    }

    throw err;
  }
}

function generateTransferReference() {
  return `GP-${Date.now()}-${Math.random()
    .toString(36)
    .slice(2, 10)
    .toUpperCase()}`;
}

function normalizeProviderStatus(status) {
  return String(status || "").trim().toUpperCase();
}


function isFailureStatus(status) {
  return ["FAILED", "REVERSED", "EXPIRED"].includes(
    normalizeProviderStatus(status)
  );
}

function getFailureReason(data, fallback = "Monnify transfer failed.") {
  return (
    data?.responseMessage ||
    data?.responseBody?.transactionDescription ||
    data?.responseBody?.errorMessage ||
    fallback
  );
}

// Monnify documents these codes as failed/rejected request outcomes.
// Code 99 is deliberately excluded because the docs instruct re-querying.
function isSafeImmediateRefundCode(code) {
  return [
    "D01",
    "D02",
    "D03",
    "D04",
    "D05",
    "D06",
    "D07",
  ].includes(String(code || "").toUpperCase());
}

function getUserIdFromRequest(req, requestedUserId) {
  const authenticatedUserId =
    req.user?.uid ||
    req.auth?.uid ||
    req.user?.id ||
    null;

  if (authenticatedUserId) {
    if (requestedUserId && requestedUserId !== authenticatedUserId) {
      const error = new Error("USER_ID_MISMATCH");
      error.statusCode = 403;
      throw error;
    }
    return authenticatedUserId;
  }

  return requestedUserId;
}

async function createTransferRecordsAtomically({
  userId,
  reference,
  withdrawalAmount,
  fee,
  debitAmount,
  bankCode,
  accountNumber,
  accountName,
  reason,
}) {
  const walletRef = db.collection("wallets").doc(userId);
  const userTxRef = db
    .collection("users")
    .doc(userId)
    .collection("transactions")
    .doc(reference);
  const lookupRef = db.collection("monnify_transfers").doc(reference);

  let newBalance = 0;

  await db.runTransaction(async (transaction) => {
    const walletDoc = await transaction.get(walletRef);

    if (!walletDoc.exists) {
      throw new Error("WALLET_NOT_FOUND");
    }

    const walletData = walletDoc.data();
    const balance = Number(walletData.balance || 0);

    if (!Number.isFinite(balance) || balance < debitAmount) {
      throw new Error("INSUFFICIENT_BALANCE");
    }

    const transactions = Array.isArray(walletData.transactions)
      ? [...walletData.transactions]
      : [];

    if (transactions.some((tx) => tx.id === reference)) {
      throw new Error("DUPLICATE_INTERNAL_REFERENCE");
    }

    newBalance = Number((balance - debitAmount).toFixed(2));

    const pendingTx = {
      id: reference,
      type: "debit",
      title: "Bank Transfer",
      amount: withdrawalAmount,
      fee,
      totalDebited: debitAmount,
      timestamp: Date.now(),
      status: "pending",
      provider: "monnify",
      bankCode,
      accountNumber,
      accountName,
      reason,
    };

    transaction.update(walletRef, {
      balance: newBalance,
      transactions: admin.firestore.FieldValue.arrayUnion(pendingTx),
      updatedAt: admin.firestore.Timestamp.now(),
    });

    transaction.set(
      userTxRef,
      {
        id: reference,
        type: "bank_transfer",
        title: `Transfer to ${accountName}`,
        amount: withdrawalAmount,
        fee,
        totalDebited: debitAmount,
        bankCode,
        accountNumber,
        accountName,
        reason,
        status: "pending",
        provider: "monnify",
        providerReference: reference,
        monnifyReference: null,
        timestamp: Date.now(),
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now(),
      },
      { merge: true }
    );

    transaction.set(
      lookupRef,
      {
        reference,
        userId,
        amount: withdrawalAmount,
        fee,
        totalDebited: debitAmount,
        bankCode,
        accountNumber,
        accountName,
        reason,
        status: "pending",
        provider: "monnify",
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now(),
      },
      { merge: false }
    );
  });

  return { walletRef, userTxRef, lookupRef, newBalance };
}

async function updateLocalTransfer({
  userId,
  reference,
  providerStatus,
  providerData = {},
  failureReason = null,
}) {
  const status = normalizeProviderStatus(providerStatus);
  const userTxRef = db
    .collection("users")
    .doc(userId)
    .collection("transactions")
    .doc(reference);
  const walletRef = db.collection("wallets").doc(userId);
  const lookupRef = db.collection("monnify_transfers").doc(reference);

  await db.runTransaction(async (transaction) => {
    const userTxDoc = await transaction.get(userTxRef);
    const lookupDoc = await transaction.get(lookupRef);
    const walletDoc = await transaction.get(walletRef);

    const current = userTxDoc.exists ? userTxDoc.data() : {};
    const lookup = lookupDoc.exists ? lookupDoc.data() : {};

    const providerReference =
      providerData.reference ||
      lookup.providerReference ||
      reference;

    const monnifyReference =
      providerData.transactionReference ||
      lookup.monnifyReference ||
      null;

    const patch = {
      status: status.toLowerCase(),
      provider: "monnify",
      providerReference,
      monnifyReference,
      monnifyStatus: status,
      providerFee:
        providerData.totalFee !== undefined
          ? Number(providerData.totalFee)
          : providerData.fee !== undefined
            ? Number(providerData.fee)
            : null,
      sessionId: providerData.sessionId || null,
      destinationBankName:
        providerData.destinationBankName || null,
      failureReason: failureReason || null,
      raw: providerData,
      updatedAt: admin.firestore.Timestamp.now(),
    };

    transaction.set(userTxRef, patch, { merge: true });

    transaction.set(
      lookupRef,
      {
        ...patch,
        userId,
        reference,
        amount:
          lookup.amount ??
          providerData.amount ??
          current.amount ??
          null,
        totalDebited:
          lookup.totalDebited ??
          current.totalDebited ??
          null,
      },
      { merge: true }
    );

    if (walletDoc.exists) {
      const walletData = walletDoc.data();
      const transactions = Array.isArray(walletData.transactions)
        ? [...walletData.transactions]
        : [];

      const index = transactions.findIndex(
        (tx) => tx.id === reference
      );

      if (index !== -1) {
        transactions[index] = {
          ...transactions[index],
          status: status.toLowerCase(),
          provider: "monnify",
          providerReference,
          monnifyReference,
          monnifyStatus: status,
          failureReason: failureReason || null,
          updatedAt: Date.now(),
        };

        transaction.update(walletRef, {
          transactions,
          updatedAt: admin.firestore.Timestamp.now(),
        });
      }
    }
  });
}

async function refundFailedTransfer({
  userId,
  reference,
  reason,
  finalStatus = "FAILED",
}) {
  const walletRef = db.collection("wallets").doc(userId);
  const userTxRef = db
    .collection("users")
    .doc(userId)
    .collection("transactions")
    .doc(reference);
  const lookupRef = db.collection("monnify_transfers").doc(reference);

  let refundedAmount = 0;

  await db.runTransaction(async (transaction) => {
    const walletDoc = await transaction.get(walletRef);
    const userTxDoc = await transaction.get(userTxRef);
    const lookupDoc = await transaction.get(lookupRef);

    if (!walletDoc.exists) {
      throw new Error("WALLET_NOT_FOUND");
    }

    const walletData = walletDoc.data();
    const currentBalance = Number(walletData.balance || 0);
    const transactions = Array.isArray(walletData.transactions)
      ? [...walletData.transactions]
      : [];

    const lookup = lookupDoc.exists ? lookupDoc.data() : {};
    const originalTx = userTxDoc.exists ? userTxDoc.data() : {};

    refundedAmount = Number(
      lookup.totalDebited ??
      originalTx.totalDebited ??
      0
    );

    if (!Number.isFinite(refundedAmount) || refundedAmount <= 0) {
      throw new Error(`INVALID_REFUND_AMOUNT:${reference}`);
    }

    const refundId = `${reference}_refund`;

    if (transactions.some((tx) => tx.id === refundId)) {
      transaction.set(
        userTxRef,
        {
          status: "failed",
          monnifyStatus: normalizeProviderStatus(finalStatus),
          failureReason: reason,
          refunded: true,
          updatedAt: admin.firestore.Timestamp.now(),
        },
        { merge: true }
      );

      transaction.set(
        lookupRef,
        {
          status: "failed",
          monnifyStatus: normalizeProviderStatus(finalStatus),
          failureReason: reason,
          refunded: true,
          updatedAt: admin.firestore.Timestamp.now(),
        },
        { merge: true }
      );

      return;
    }

    const originalIndex = transactions.findIndex(
      (tx) => tx.id === reference
    );

    if (originalIndex !== -1) {
      transactions[originalIndex] = {
        ...transactions[originalIndex],
        status: "failed",
        provider: "monnify",
        failureReason: reason,
        updatedAt: Date.now(),
      };
    }

    transactions.push({
      id: refundId,
      type: "credit",
      title: "Bank Transfer Refund",
      amount: refundedAmount,
      timestamp: Date.now(),
      status: "refunded",
      provider: "monnify",
      reference,
      reason,
      providerStatus: normalizeProviderStatus(finalStatus),
    });

    const newBalance = Number(
      (currentBalance + refundedAmount).toFixed(2)
    );

    transaction.update(walletRef, {
      balance: newBalance,
      transactions,
      updatedAt: admin.firestore.Timestamp.now(),
    });

    transaction.set(
      userTxRef,
      {
        status: "failed",
        monnifyStatus: normalizeProviderStatus(finalStatus),
        failureReason: reason,
        refunded: true,
        updatedAt: admin.firestore.Timestamp.now(),
      },
      { merge: true }
    );

    transaction.set(
      lookupRef,
      {
        status: "failed",
        monnifyStatus: normalizeProviderStatus(finalStatus),
        failureReason: reason,
        refunded: true,
        refundedAmount,
        updatedAt: admin.firestore.Timestamp.now(),
      },
      { merge: true }
    );
  });

  console.log(
    `↩️ GiftPay wallet refunded: ${userId} | ${reference} | ₦${refundedAmount}`
  );

  return refundedAmount;
}

async function applyFinalProviderStatus({
  reference,
  providerData,
  statusOverride = null,
}) {
  if (!reference) {
    return { found: false, reason: "MISSING_REFERENCE" };
  }

  const lookupRef = db.collection("monnify_transfers").doc(reference);
  const lookupDoc = await lookupRef.get();

  if (!lookupDoc.exists) {
    return { found: false, reason: "TRANSFER_NOT_FOUND" };
  }

  const lookup = lookupDoc.data();
  const userId = lookup.userId;

  const providerStatus = normalizeProviderStatus(
    statusOverride || providerData?.status
  );

  if (!userId || !providerStatus) {
    return { found: false, reason: "MISSING_USER_OR_STATUS" };
  }

  const currentStatus = normalizeProviderStatus(
    lookup.monnifyStatus || lookup.status
  );

  // Never let an older/later callback downgrade a transfer that GiftPay
  // has already finalized successfully.
  if (
    ["SUCCESS", "COMPLETED"].includes(currentStatus) &&
    !["SUCCESS", "COMPLETED"].includes(providerStatus)
  ) {
    return {
      found: true,
      ignored: true,
      reason: "ALREADY_SUCCESSFUL",
      userId,
      reference,
      status: currentStatus,
    };
  }

  // Never allow a stale success/pending notification to undo a transfer
  // that has already been refunded.
  if (
    ["FAILED", "REVERSED", "EXPIRED"].includes(currentStatus) &&
    ["SUCCESS", "COMPLETED", "PENDING", "AWAITING_PROCESSING", "IN_PROGRESS", "PENDING_AUTHORIZATION", "OTP_EMAIL_DISPATCH_FAILED"].includes(providerStatus)
  ) {
    return {
      found: true,
      ignored: true,
      reason: "ALREADY_FINAL_FAILURE",
      userId,
      reference,
      status: currentStatus,
    };
  }

  const failureReason = getFailureReason(
    providerData,
    `Monnify transfer status: ${providerStatus}`
  );

  if (isFailureStatus(providerStatus)) {
    await refundFailedTransfer({
      userId,
      reference,
      reason: failureReason,
      finalStatus: providerStatus,
    });
  } else {
    await updateLocalTransfer({
      userId,
      reference,
      providerStatus,
      providerData,
      failureReason: null,
    });
  }

  return {
    found: true,
    userId,
    reference,
    status: providerStatus,
  };
}

// Public helper used by the normal Monnify webhook. The webhook deliberately
// does not depend on undocumented disbursement event names; it only applies
// a documented transfer status when the callback payload contains one.
exports.reconcileMonnifyTransfer = applyFinalProviderStatus;

// ============================================================
// BANK LIST
// ============================================================

exports.getBanks = async (req, res) => {
  try {
    const response = await monnifyRequest({
      method: "GET",
      url: "/api/v1/banks",
    });

    const banks = response.data?.responseBody || [];

    return res.json({
      status: true,
      data: banks.map((bank) => ({
        name: bank.name,
        code: bank.code,
        slug: bank.slug || null,
      })),
    });
  } catch (err) {
    console.error(
      "❌ Monnify getBanks error:",
      err.response?.data || err.responseData || err.message
    );

    return res.status(500).json({
      status: false,
      message: "Failed to load banks",
    });
  }
};

// ============================================================
// NAME ENQUIRY
// ============================================================

exports.resolveAccount = async (req, res) => {
  try {
    const { bankCode, accountNumber } = req.body;

    if (!bankCode || !accountNumber) {
      return res.status(400).json({
        status: false,
        message: "Missing bankCode or accountNumber",
      });
    }

    const normalizedAccountNumber = String(accountNumber).trim();

    if (!/^\d{10}$/.test(normalizedAccountNumber)) {
      return res.status(400).json({
        status: false,
        message: "Invalid Nigerian account number",
      });
    }

    const response = await monnifyRequest({
      method: "GET",
      url: "/api/v2/disbursements/account/validate",
      params: {
        accountNumber: normalizedAccountNumber,
        bankCode: String(bankCode).trim(),
      },
    });

    const data = response.data?.responseBody;

    if (!data) {
      return res.status(400).json({
        status: false,
        message:
          response.data?.responseMessage ||
          "Unable to resolve account",
      });
    }

    return res.json({
      status: true,
      data: {
        accountName: data.accountName,
        accountNumber: data.accountNumber,
        bankCode: data.bankCode,
        bankName: data.bankName,
      },
    });
  } catch (err) {
    console.error(
      "❌ Monnify resolveAccount error:",
      err.response?.data || err.responseData || err.message
    );

    return res.status(400).json({
      status: false,
      message:
        err.response?.data?.responseMessage ||
        err.responseData?.responseMessage ||
        "Failed to resolve account",
    });
  }
};

// ============================================================
// SINGLE TRANSFER
// ============================================================

exports.transferToBank = async (req, res) => {
  // Confirms the request reached this controller.
  // Never log the transaction PIN or full account numbers.
  console.log("\n========================================");
  console.log("📥 GIFTPAY transferToBank endpoint reached");
  console.log("========================================");
  console.log("Method:", req.method);
  console.log("Path:", req.originalUrl);
  console.log("Timestamp:", new Date().toISOString());
  console.log("Has request body:", Boolean(req.body));
  console.log("Has transaction PIN:", Boolean(req.body?.transactionPin));
  console.log(
    "Authenticated:",
    Boolean(req.user?.uid || req.auth?.uid || req.user?.id)
  );
  console.log("========================================\n");

  let reference = null;
  let userId = null;
  let walletRef = null;
  let debitAmount = 0;

  try {
    const {
      userId: requestUserId,
      amount,
      bankCode,
      accountNumber,
      accountName,
      reason = "Wallet Cashout",
      transactionPin,
    } = req.body;

    userId = getUserIdFromRequest(req, requestUserId);

    if (!userId) {
      return res.status(401).json({
        status: false,
        message: "Authentication required",
        code: "AUTH_REQUIRED",
      });
    }

    if (!transactionPin || !/^\d{4}$/.test(String(transactionPin))) {
      return res.status(401).json({
        status: false,
        message: "Transaction PIN is required",
        code: "PIN_REQUIRED",
      });
    }

    // Verify before any wallet debit, transfer record, or Monnify call.
    const pinResult = await verifyTransactionPin(
      userId,
      String(transactionPin)
    );

    if (!pinResult.ok) {
      return res.status(401).json({
        status: false,
        message:
          pinResult.code === "PIN_LOCKED"
            ? "Transaction PIN temporarily locked after too many failed attempts"
            : "Incorrect transaction PIN",
        code: pinResult.code,
        lockedUntil: pinResult.lockedUntil || null,
      });
    }

    if (
      !userId ||
      amount === undefined ||
      amount === null ||
      !bankCode ||
      !accountNumber ||
      !accountName
    ) {
      return res.status(400).json({
        status: false,
        message: "Missing required fields",
      });
    }

    const withdrawalAmount = Number(Number(amount).toFixed(2));

    if (!Number.isFinite(withdrawalAmount) || withdrawalAmount <= 0) {
      return res.status(400).json({
        status: false,
        message: "Invalid amount",
      });
    }

    const normalizedAccountNumber = String(accountNumber).trim();
    const normalizedBankCode = String(bankCode).trim();
    const normalizedAccountName = String(accountName).trim();

    if (!/^\d{10}$/.test(normalizedAccountNumber)) {
      return res.status(400).json({
        status: false,
        message: "Invalid destination account number",
      });
    }

    const feeResult = FeeEngine.withdrawal(withdrawalAmount);

    const fee = Number(Number(feeResult.fee || 0).toFixed(2));
    debitAmount = Number(
      Number(
        feeResult.debitAmount || withdrawalAmount + fee
      ).toFixed(2)
    );

    reference = generateTransferReference();

    const records = await createTransferRecordsAtomically({
      userId,
      reference,
      withdrawalAmount,
      fee,
      debitAmount,
      bankCode: normalizedBankCode,
      accountNumber: normalizedAccountNumber,
      accountName: normalizedAccountName,
      reason,
    });

    walletRef = records.walletRef;

    if (!MONNIFY_WALLET_ACCOUNT_NUMBER) {
      await refundFailedTransfer({
        userId,
        reference,
        reason: "MONNIFY_WALLET_ACCOUNT_NUMBER is not configured",
        finalStatus: "FAILED",
      });

      return res.status(500).json({
        status: false,
        message: "Monnify payout wallet is not configured",
      });
    }

    const transferPayload = {
      amount: withdrawalAmount,
      reference,
      narration: reason,
      destinationBankCode: normalizedBankCode,
      destinationAccountNumber: normalizedAccountNumber,
      destinationAccountName: normalizedAccountName,
      currency: "NGN",
      sourceAccountNumber: MONNIFY_WALLET_ACCOUNT_NUMBER,
      async: true,
    };

    let response;

    // Log the request immediately before calling Monnify.
    console.log("\n========================================");
    console.log("🚀 GIFTPAY BANK TRANSFER: SENDING TO MONNIFY");
    console.log("========================================");
    console.log("Request reference:", reference);
    console.log("User ID:", userId);
    console.log("Amount:", withdrawalAmount);
    console.log("Fee:", fee);
    console.log("Total debit:", debitAmount);
    console.log("Bank code:", normalizedBankCode);
    console.log("Account name:", normalizedAccountName);
    console.log(
      "Destination account:",
      "******" + normalizedAccountNumber.slice(-4)
    );
    console.log(
      "Transfer payload:",
      JSON.stringify(
        {
          ...transferPayload,
          sourceAccountNumber: "REDACTED",
          destinationAccountNumber:
            "******" + normalizedAccountNumber.slice(-4),
        },
        null,
        2
      )
    );
    console.log(
      "Monnify endpoint:",
      `${MONNIFY_BASE_URL}/api/v2/disbursements/single`
    );
    console.log("========================================");

    try {
      response = await monnifyRequest({
        method: "POST",
        url: "/api/v2/disbursements/single",
        data: transferPayload,
      });

      console.log("\n========================================");
      console.log("✅ MONNIFY TRANSFER HTTP RESPONSE");
      console.log("========================================");
      console.log("HTTP status:", response.status);
      console.log("Request reference:", reference);
      console.log(
        "Monnify response body:",
        JSON.stringify(response.data, null, 2)
      );
      console.log("========================================\n");
    } catch (err) {
      const providerData = err.response?.data || err.responseData;
      const providerCode = getProviderCode(providerData);
      const providerMessage =
        providerData?.responseMessage ||
        providerData?.responseBody?.transactionDescription ||
        err.message;

      console.error("\n========================================");
      console.error("❌ MONNIFY TRANSFER REQUEST ERROR");
      console.error("========================================");
      console.error("Request reference:", reference);
      console.error(
        "HTTP status:",
        err.response?.status ?? err.httpStatus ?? "No HTTP response"
      );
      console.error(
        "Monnify error response:",
        JSON.stringify(providerData ?? null, null, 2)
      );
      console.error("Error message:", err.message);
      console.error("========================================\n");

      if (isSafeImmediateRefundCode(providerCode)) {
        await refundFailedTransfer({
          userId,
          reference,
          reason: providerMessage,
          finalStatus: "FAILED",
        });

        return res.status(
          providerCode === "D07" || providerCode === "D05" ? 409 : 400
        ).json({
          status: false,
          message: providerMessage,
          code: `MONNIFY_${providerCode}`,
          requestId: reference,
        });
      }

      // Ambiguous errors are not automatically refunded.
      await updateLocalTransfer({
        userId,
        reference,
        providerStatus: "PENDING",
        providerData: providerData || {},
        failureReason: providerMessage,
      });

      await db.collection("monnify_transfers").doc(reference).set(
        {
          reconciliationRequired: true,
          updatedAt: admin.firestore.Timestamp.now(),
        },
        { merge: true }
      );

      return res.status(202).json({
        status: false,
        message:
          "Transfer status is being verified. Please do not retry this withdrawal yet.",
        requestId: reference,
        transferStatus: "PENDING_RECONCILIATION",
      });
    }

    const transferData = response.data?.responseBody;

    if (!transferData) {
      await updateLocalTransfer({
        userId,
        reference,
        providerStatus: "PENDING",
        providerData: response.data || {},
        failureReason: "Monnify returned no transfer data",
      });

      await db.collection("monnify_transfers").doc(reference).set(
        { reconciliationRequired: true },
        { merge: true }
      );

      return res.status(202).json({
        status: false,
        message:
          "Transfer status is being verified. Please do not retry this withdrawal yet.",
        requestId: reference,
        transferStatus: "PENDING_RECONCILIATION",
      });
    }

    const providerStatus = normalizeProviderStatus(
      transferData.status || "PENDING"
    );

    const providerReference = transferData.reference || reference;
    const monnifyReference = transferData.transactionReference || null;

    await updateLocalTransfer({
      userId,
      reference,
      providerStatus,
      providerData: transferData,
      failureReason: null,
    });

    if (isFailureStatus(providerStatus)) {
      await refundFailedTransfer({
        userId,
        reference,
        reason: getFailureReason(
          transferData,
          `Monnify transfer ${providerStatus}`
        ),
        finalStatus: providerStatus,
      });
    }

    const statusForClient = providerStatus;

    return res.json({
      status: true,
      message:
        statusForClient === "PENDING_AUTHORIZATION"
          ? "Transfer created and awaiting Monnify authorization"
          : "Transfer initiated",
      requestId: reference,
      newBalance: records.newBalance,
      amount: withdrawalAmount,
      fee,
      debited: debitAmount,
      provider: "monnify",
      providerReference,
      monnifyReference,
      transferStatus: statusForClient,
    });
  } catch (err) {
    console.error("\n========================================");
    console.error("❌ GIFTPAY transferToBank CONTROLLER ERROR");
    console.error("========================================");
    console.error("Request reference:", reference || "Not generated");
    console.error("User ID:", userId || "Not resolved");
    console.error(
      "HTTP status:",
      err.response?.status ?? err.httpStatus ?? "No HTTP response"
    );
    console.error(
      "Error response:",
      JSON.stringify(
        err.response?.data || err.responseData || null,
        null,
        2
      )
    );
    console.error("Error message:", err.message);
    console.error("Stack:", err.stack);
    console.error("========================================\n");

    if (err.message === "USER_ID_MISMATCH") {
      return res.status(403).json({
        status: false,
        message: "User identity does not match the transfer request",
      });
    }

    if (err.message === "WALLET_NOT_FOUND") {
      return res.status(404).json({
        status: false,
        message: "Wallet not found",
      });
    }

    if (err.message === "INSUFFICIENT_BALANCE") {
      return res.status(400).json({
        status: false,
        message: "Insufficient wallet balance",
      });
    }

    if (err.message === "DUPLICATE_INTERNAL_REFERENCE") {
      return res.status(409).json({
        status: false,
        message: "Unable to create a unique transfer reference",
      });
    }

    return res.status(500).json({
      status: false,
      message: "Server error initiating transfer",
    });
  }
};

// ============================================================
// AUTHORIZE SINGLE TRANSFER (MFA / OTP)
// ============================================================

exports.authorizeTransfer = async (req, res) => {
  try {
    const { reference, authorizationCode } = req.body;

    if (!reference || !authorizationCode) {
      return res.status(400).json({
        status: false,
        message: "Missing reference or authorizationCode",
      });
    }

    const lookupRef = db.collection("monnify_transfers").doc(reference);
    const lookupDoc = await lookupRef.get();

    if (!lookupDoc.exists) {
      return res.status(404).json({
        status: false,
        message: "Transfer not found",
      });
    }

    const transfer = lookupDoc.data();
    const userId = getUserIdFromRequest(req, transfer.userId);

    const response = await monnifyRequest({
      method: "POST",
      url: "/api/v2/disbursements/single/validate-otp",
      data: {
        reference,
        authorizationCode: String(authorizationCode).trim(),
      },
    });

    const data = response.data?.responseBody || {};

    await updateLocalTransfer({
      userId,
      reference,
      providerStatus: data.status || "PENDING",
      providerData: data,
      failureReason: null,
    });

    if (isFailureStatus(data.status)) {
      await refundFailedTransfer({
        userId,
        reference,
        reason: getFailureReason(data),
        finalStatus: data.status,
      });
    }

    return res.json({
      status: true,
      message: "Transfer authorization submitted",
      data,
    });
  } catch (err) {
    console.error(
      "❌ Monnify authorizeTransfer error:",
      err.response?.data || err.responseData || err.message
    );

    return res.status(400).json({
      status: false,
      message:
        err.response?.data?.responseMessage ||
        err.responseData?.responseMessage ||
        err.message ||
        "Unable to authorize transfer",
    });
  }
};

// ============================================================
// RESEND OTP
// ============================================================

exports.resendTransferOtp = async (req, res) => {
  try {
    const reference = req.body?.reference || req.params?.reference;

    if (!reference) {
      return res.status(400).json({
        status: false,
        message: "Missing transfer reference",
      });
    }

    const lookupRef = db.collection("monnify_transfers").doc(reference);
    const lookupDoc = await lookupRef.get();

    if (!lookupDoc.exists) {
      return res.status(404).json({
        status: false,
        message: "Transfer not found",
      });
    }

    getUserIdFromRequest(req, lookupDoc.data().userId);

    const response = await monnifyRequest({
      method: "POST",
      url: "/api/v2/disbursements/single/resend-otp",
      data: { reference },
    });

    return res.json({
      status: true,
      message: "OTP resend requested",
      data: response.data?.responseBody || null,
    });
  } catch (err) {
    console.error(
      "❌ Monnify resend OTP error:",
      err.response?.data || err.responseData || err.message
    );

    return res.status(400).json({
      status: false,
      message:
        err.response?.data?.responseMessage ||
        err.responseData?.responseMessage ||
        err.message ||
        "Unable to resend OTP",
    });
  }
};

// ============================================================
// MONNIFY PAYOUT WALLET BALANCE
// ============================================================

exports.getMonnifyWalletBalance = async (req, res) => {
  try {
    if (!MONNIFY_WALLET_ACCOUNT_NUMBER) {
      return res.status(500).json({
        status: false,
        message: "MONNIFY_WALLET_ACCOUNT_NUMBER is not configured",
      });
    }

    const response = await monnifyRequest({
      method: "GET",
      url: "/api/v2/disbursements/wallet-balance",
      params: {
        accountNumber: MONNIFY_WALLET_ACCOUNT_NUMBER,
      },
    });

    return res.json({
      status: true,
      data: response.data?.responseBody || null,
    });
  } catch (err) {
    console.error(
      "❌ Monnify wallet balance error:",
      err.response?.data || err.responseData || err.message
    );

    return res.status(500).json({
      status: false,
      message: "Failed to retrieve Monnify wallet balance",
    });
  }
};

// ============================================================
// TRANSFER STATUS / RECONCILIATION
// ============================================================

exports.getTransferStatus = async (req, res) => {
  try {
    const reference = String(req.params.reference || "").trim();

    if (!reference) {
      return res.status(400).json({
        status: false,
        message: "Missing transfer reference",
      });
    }

    const lookupRef = db.collection("monnify_transfers").doc(reference);
    const lookupDoc = await lookupRef.get();

    if (!lookupDoc.exists) {
      return res.status(404).json({
        status: false,
        message: "Transfer not found",
      });
    }

    const lookup = lookupDoc.data();
    getUserIdFromRequest(req, lookup.userId);

    const response = await monnifyRequest({
      method: "GET",
      url: "/api/v2/disbursements/single/summary",
      params: { reference },
    });

    const data = response.data?.responseBody;

    if (!data) {
      return res.status(400).json({
        status: false,
        message:
          response.data?.responseMessage ||
          "Unable to retrieve transfer status",
      });
    }

    const providerStatus = normalizeProviderStatus(data.status);

    if (isFailureStatus(providerStatus)) {
      await refundFailedTransfer({
        userId: lookup.userId,
        reference,
        reason: getFailureReason(data),
        finalStatus: providerStatus,
      });
    } else {
      await updateLocalTransfer({
        userId: lookup.userId,
        reference,
        providerStatus,
        providerData: data,
        failureReason: null,
      });
    }

    return res.json({
      status: true,
      data,
    });
  } catch (err) {
    console.error(
      "❌ Monnify transfer status error:",
      err.response?.data || err.responseData || err.message
    );

    return res.status(400).json({
      status: false,
      message:
        err.response?.data?.responseMessage ||
        err.responseData?.responseMessage ||
        "Failed to retrieve transfer status",
    });
  }
};
