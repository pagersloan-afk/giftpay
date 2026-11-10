// Food merchant payout service.
// Transfers order earnings from GiftPay's configured Monnify source account to
// the merchant's existing USER_<firebaseUid> Reserved Account. The Reserved
// Account's incoming-transaction webhook is responsible for crediting wallet.
const crypto = require("crypto");
const admin = require("firebase-admin");
const { getJwtToken, getReservedAccountDetails } = require("./monnify.service");
const { monnifyJwtClient } = require("../clients/monnify.client");
const { request: flutterwaveRequest } = require("./flutterwave.transfer.client");

const db = admin.firestore();
const PAYABLES = "foodMerchantPayables";
const ORDERS = "foodOrders";
const TRANSFERS = "monnify_transfers";
const SOURCE_ACCOUNT = String(process.env.MONNIFY_WALLET_ACCOUNT_NUMBER || "").trim();

function referenceForOrder(orderId, provider = "monnify") {
  const digest = crypto.createHash("sha256").update(String(orderId)).digest("hex").slice(0, 20).toUpperCase();
  return `GPFOOD_${provider === "flutterwave" ? "FLW" : "MON"}_${digest}`;
}
function cleanStatus(value) {
  return String(value || "")
    .trim()
    .toUpperCase()
    .replace(/^TRANSFER[._\s-]+/, "")
    .replace(/[.\s-]+/g, "_");
}
function accountNumberFrom(account) { return String(account?.accountNumber || account?.accountNo || "").trim(); }
function bankCodeFrom(account) { return String(account?.bankCode || account?.destinationBankCode || account?.bank?.code || account?.bank?.bankCode || "").trim(); }
function accountNameFrom(account) { return String(account?.accountName || account?.accountHolderName || account?.name || "").trim(); }

async function getDestination(merchantUid) {
  const userRef = db.collection("users").doc(merchantUid);
  const userSnap = await userRef.get();
  if (!userSnap.exists) throw new Error("Merchant user record was not found");
  const virtualAccount = userSnap.data()?.virtualAccount || {};
  const accountReference = String(virtualAccount.reference || `USER_${merchantUid}`).trim();
  if (accountReference !== `USER_${merchantUid}`) {
    throw new Error("Merchant Reserved Account reference does not match merchant UID");
  }

  // Use the current provider record rather than trusting stale client data.
  const details = await getReservedAccountDetails(accountReference);
  const accounts = Array.isArray(details?.accounts) ? details.accounts : [];
  const savedNumber = String(virtualAccount.accountNumber || "").trim();
  const destination = accounts.find((a) => accountNumberFrom(a) === savedNumber) || accounts[0];
  if (!destination) throw new Error("Monnify returned no destination account for the merchant Reserved Account");

  const accountNumber = accountNumberFrom(destination) || savedNumber;
  const bankCode = bankCodeFrom(destination);
  const accountName = accountNameFrom(destination) || String(virtualAccount.accountName || "").trim();
  if (!/^\d{10}$/.test(accountNumber)) throw new Error("Merchant Reserved Account did not return a valid 10-digit account number");
  if (!bankCode) throw new Error("Monnify Reserved Account response did not include a bank code; payout was not submitted");
  if (!accountName) throw new Error("Merchant Reserved Account did not return an account name");
  return { accountReference, accountNumber, bankCode, accountName, bankName: destination.bankName || virtualAccount.bankName || null };
}

async function submitFoodMerchantPayout({ orderId, merchantUid }) {
  const orderRef = db.collection(ORDERS).doc(orderId);
  const payableRef = db.collection(PAYABLES).doc(orderId);
  const provider = String(process.env.FOOD_SETTLEMENT_PROVIDER || "monnify").trim().toLowerCase();
  if (!["monnify", "flutterwave", "manual"].includes(provider)) throw new Error(`Unsupported FOOD_SETTLEMENT_PROVIDER: ${provider}`);
  if (provider === "manual") return { status: "MANUAL_REQUIRED", reference: null };
  const reference = referenceForOrder(orderId, provider);
  const transferRef = db.collection(TRANSFERS).doc(reference);

  // Claim the deterministic payout before making any external request. A retry
  // must not issue a second transfer if the first provider response was lost.
  const claim = await db.runTransaction(async (tx) => {
    const payableSnap = await tx.get(payableRef);
    const transferSnap = await tx.get(transferRef);
    if (!payableSnap.exists) throw new Error("Food payable record is missing");
    const payable = payableSnap.data() || {};
    if (String(payable.merchantUid || "") !== merchantUid) throw new Error("Merchant UID does not match food payable");
    if (["settled", "successful", "success"].includes(String(payable.status || "").toLowerCase())) {
      return { submit: false, status: "SUCCESS" };
    }
    const previousReference = String(payable.payoutReference || "").trim();
    if (previousReference && previousReference !== reference) {
      const previousTransferSnap = await tx.get(db.collection(TRANSFERS).doc(previousReference));
      if (previousTransferSnap.exists) {
        const previousTransfer = previousTransferSnap.data() || {};
        const previousStatus = String(previousTransfer.status || "").toLowerCase();
        if (["submitting", "pending", "processing", "success", "successful"].includes(previousStatus)) {
          return { submit: false, status: previousStatus, reference: previousReference };
        }
      }
    }
    if (String(payable.payoutStatus || "").toLowerCase() === "processing") {
      return { submit: false, status: payable.payoutStatus, reference: previousReference || reference };
    }
    if (transferSnap.exists) {
      const existing = transferSnap.data() || {};
      return { submit: false, status: existing.flutterwaveStatus || existing.monnifyStatus || existing.status || "PENDING", reference };
    }
    const now = admin.firestore.FieldValue.serverTimestamp();
    tx.create(transferRef, {
      type: "food_merchant_payout",
      userId: merchantUid,
      merchantUid,
      orderId,
      reference,
      amount: Number(payable.amount),
      currency: "NGN",
      status: "submitting",
      provider,
      ...(provider === "flutterwave" ? { flutterwaveStatus: "PENDING" } : { monnifyStatus: "PENDING" }),
      destinationAccountReference: `USER_${merchantUid}`,
      createdAt: now,
      updatedAt: now,
    });
    tx.set(payableRef, { payoutReference: reference, payoutStatus: "processing", status: "pending", updatedAt: now }, { merge: true });
    tx.set(orderRef, { payoutReference: reference, settlementStatus: "processing", updatedAt: now }, { merge: true });
    return { submit: true, amount: Number(payable.amount) };
  });
  if (!claim.submit) return { status: claim.status, reference: claim.reference || reference };

  try {
    const amount = Number(claim.amount);
    if (!Number.isFinite(amount) || amount <= 0) throw new Error("Food payout amount is invalid");
    let data = {};
    let body = {};
    let status = "PENDING";
    let destination = {};

    if (provider === "monnify") {
      if (!SOURCE_ACCOUNT) { const e = new Error("MONNIFY_WALLET_ACCOUNT_NUMBER is not configured"); e.providerRejected = true; throw e; }
      destination = await getDestination(merchantUid);
      const token = await getJwtToken();
      const client = monnifyJwtClient(token);
      const payload = {
        amount: Number(amount.toFixed(2)), reference,
        narration: `GiftPay food order settlement ${orderId}`.slice(0, 100),
        destinationBankCode: destination.bankCode,
        destinationAccountNumber: destination.accountNumber,
        destinationAccountName: destination.accountName,
        currency: "NGN", sourceAccountNumber: SOURCE_ACCOUNT, async: true,
      };
      const response = await client.post("/api/v2/disbursements/single", payload, { timeout: 30000 });
      data = response.data || {};
      if (data.requestSuccessful === false) {
        const e = new Error(data.responseMessage || "Monnify rejected the food payout");
        e.providerRejected = true; e.providerData = data; throw e;
      }
      body = data.responseBody || {};
      status = cleanStatus(body.status || body.transactionStatus || "PENDING");
    } else if (provider === "flutterwave") {
      const settingsSnap = await db.collection("foodRestaurantSettings").doc(merchantUid).get();
      const settings = settingsSnap.exists ? settingsSnap.data() || {} : {};
      const bankCode = String(settings.payoutBankCode || "").trim();
      const accountNumber = String(settings.payoutAccountNumber || "").trim();
      const accountName = String(settings.payoutAccountName || "").trim();
      if (!bankCode || !/^\d{10}$/.test(accountNumber) || !accountName || settings.payoutAccountVerified !== true) {
        const e = new Error("Merchant must add and verify a Flutterwave settlement bank account in Restaurant Settings before automatic payout can run"); e.providerRejected = true; throw e;
      }
      if (!Number.isInteger(amount)) { const e = new Error("Flutterwave NGN settlements require whole-naira amounts; this payable contains a fractional naira amount."); e.providerRejected = true; throw e; }
      const callbackUrl = String(process.env.FLUTTERWAVE_TRANSFER_CALLBACK_URL || process.env.FLW_TRANSFER_CALLBACK_URL || "").trim();
      data = await flutterwaveRequest("post", "/transfers", {
        account_bank: bankCode, account_number: accountNumber, amount: Number(amount.toFixed(2)),
        currency: "NGN", reference, narration: `GiftPay food order settlement ${orderId}`.slice(0, 100),
        beneficiary_name: accountName, ...(callbackUrl ? { callback_url: callbackUrl } : {}),
      });
      body = data || {};
      status = cleanStatus(body.status || "NEW");
      destination = { accountNumber, accountName, bankCode, bankName: settings.payoutBankName || null };
    }

    const now = admin.firestore.FieldValue.serverTimestamp();
    await db.runTransaction(async (tx) => {
      tx.set(transferRef, {
        provider,
        status: ["SUCCESS", "SUCCESSFUL", "COMPLETED"].includes(status) ? "success" : "pending",
        ...(provider === "flutterwave" ? { flutterwaveStatus: status, providerTransferId: body.id || null } : { monnifyStatus: status, providerTransactionReference: body.transactionReference || body.reference || null }),
        providerData: data,
        destinationAccountNumberMasked: destination.accountNumber ? `******${destination.accountNumber.slice(-4)}` : null,
        destinationBankName: destination.bankName || null,
        submittedAt: now, updatedAt: now,
      }, { merge: true });
      tx.set(payableRef, { payoutStatus: "processing", ...(provider === "flutterwave" ? { flutterwaveStatus: status } : { monnifyStatus: status }), updatedAt: now }, { merge: true });
      tx.set(orderRef, { settlementStatus: "processing", ...(provider === "flutterwave" ? { flutterwaveStatus: status } : { monnifyStatus: status }), updatedAt: now }, { merge: true });
    });

    if (["SUCCESS", "SUCCESSFUL", "COMPLETED", "FAILED", "REVERSED", "EXPIRED"].includes(status)) {
      await reconcileFoodMerchantPayoutStatus({ reference, status, providerData: body, provider });
    }
    return { status, reference };
  } catch (err) {
    const providerData = err.providerData || err.response?.data || null;
    const explicitlyRejected = Boolean(err.providerRejected);
    const now = admin.firestore.FieldValue.serverTimestamp();
    // Do not automatically retry timeouts/network errors: Monnify may have
    // accepted the transfer even when the response did not reach GiftPay.
    await db.runTransaction(async (tx) => {
      tx.set(transferRef, {
        status: explicitlyRejected ? "failed" : "pending",
        ...(provider === "flutterwave" ? { flutterwaveStatus: explicitlyRejected ? "FAILED" : "PENDING" } : { monnifyStatus: explicitlyRejected ? "FAILED" : "PENDING" }),
        submissionError: String(err.message || "Transfer submission outcome is unknown").slice(0, 500),
        providerData,
        updatedAt: now,
      }, { merge: true });
      tx.set(payableRef, {
        payoutStatus: explicitlyRejected ? "failed" : "pending",
        ...(explicitlyRejected ? { status: "failed" } : {}),
        payoutError: String(err.message || "Transfer submission outcome is unknown").slice(0, 500),
        updatedAt: now,
      }, { merge: true });
      tx.set(orderRef, {
        settlementStatus: explicitlyRejected ? "failed" : "pending",
        payoutError: String(err.message || "Transfer submission outcome is unknown").slice(0, 500),
        updatedAt: now,
      }, { merge: true });
    });
    throw err;
  }
}

async function reconcileFoodMerchantPayoutStatus({ reference, status, providerData = {}, provider = "monnify" }) {
  const normalized = cleanStatus(status || providerData.status || providerData.transactionStatus);
  const finalSuccess = ["SUCCESS", "SUCCESSFUL", "COMPLETED"].includes(normalized);
  const finalFailure = ["FAILED", "REVERSED", "EXPIRED"].includes(normalized);
  const finalPending = ["NEW", "QUEUED", "PENDING", "AWAITING_PROCESSING", "IN_PROGRESS", "PENDING_AUTHORIZATION", "OTP_EMAIL_DISPATCH_FAILED"].includes(normalized);
  if (!reference || (!finalSuccess && !finalFailure && !finalPending)) return { handled: false, reason: "UNKNOWN_STATUS" };

  const transferRef = db.collection(TRANSFERS).doc(String(reference));
  const transferSnap = await transferRef.get();
  if (!transferSnap.exists || transferSnap.data()?.type !== "food_merchant_payout") return { handled: false, reason: "NOT_FOOD_PAYOUT" };
  const transfer = transferSnap.data() || {};
  const orderId = String(transfer.orderId || "");
  if (!orderId || !transfer.merchantUid) return { handled: false, reason: "PAYOUT_RECORD_INCOMPLETE" };
  const payableRef = db.collection(PAYABLES).doc(orderId);
  const orderRef = db.collection(ORDERS).doc(orderId);
  const now = admin.firestore.FieldValue.serverTimestamp();

  await db.runTransaction(async (tx) => {
    const [currentTransfer, payableSnap, orderSnap] = await Promise.all([
      tx.get(transferRef), tx.get(payableRef), tx.get(orderRef),
    ]);
    if (!currentTransfer.exists) return;
    const current = currentTransfer.data() || {};
    // Provider-specific reconciliation must only touch records belonging to
    // that provider; this protects Monnify payouts from Flutterwave callbacks.
    if (current.provider && String(current.provider).toLowerCase() !== String(provider).toLowerCase()) return;

    const oldStatus = cleanStatus(current[provider === "flutterwave" ? "flutterwaveStatus" : "monnifyStatus"] || current.status);
    const oldSuccess = ["SUCCESS", "SUCCESSFUL", "COMPLETED"].includes(oldStatus);
    const oldFailure = ["FAILED", "REVERSED", "EXPIRED"].includes(oldStatus);

    // Final payout states are immutable. Contradictory later callbacks need
    // provider-side/manual reconciliation rather than automatic state flips.
    if (oldSuccess && !finalSuccess) return;
    if (oldFailure && !finalFailure) return;

    const payableStatus = finalSuccess ? "settled" : finalFailure ? "failed" : "pending";
    const payoutStatus = finalSuccess ? "successful" : finalFailure ? "failed" : "processing";
    tx.set(transferRef, {
      status: finalSuccess ? "success" : finalFailure ? "failed" : "pending",
      [provider === "flutterwave" ? "flutterwaveStatus" : "monnifyStatus"]: normalized,
      providerFinalData: providerData,
      ...(finalFailure ? { failureReason: providerData?.message || providerData?.responseMessage || `${provider} transfer ${normalized.toLowerCase()}` } : {}),
      updatedAt: now,
    }, { merge: true });
    if (payableSnap.exists) tx.set(payableRef, {
      status: payableStatus,
      payoutStatus,
      [provider === "flutterwave" ? "flutterwaveStatus" : "monnifyStatus"]: normalized,
      ...(finalSuccess ? { settledAt: now, payoutError: admin.firestore.FieldValue.delete() } : {}),
      ...(finalFailure ? { failedAt: now, payoutError: providerData?.message || providerData?.responseMessage || `${provider} transfer ${normalized.toLowerCase()}` } : {}),
      updatedAt: now,
    }, { merge: true });
    if (orderSnap.exists) tx.set(orderRef, {
      settlementStatus: finalSuccess ? "settled" : finalFailure ? "failed" : "pending",
      [provider === "flutterwave" ? "flutterwaveStatus" : "monnifyStatus"]: normalized,
      ...(finalSuccess ? { settledAt: now, payoutError: admin.firestore.FieldValue.delete() } : {}),
      ...(finalFailure ? { payoutError: providerData?.message || providerData?.responseMessage || `${provider} transfer ${normalized.toLowerCase()}` } : {}),
      updatedAt: now,
    }, { merge: true });
  });
  return { handled: true, reference, orderId, status: normalized };
}

module.exports = { referenceForOrder, submitFoodMerchantPayout, reconcileFoodMerchantPayoutStatus };
