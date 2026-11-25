
const admin = require("firebase-admin");
const { verifyTransactionPin } = require("../services/transactionPin.service");
const { request } = require("../services/flutterwave.transfer.client");
const { applyFlutterwaveTransferStatus } = require("../services/flutterwaveTransferStatus.service");

const db = admin.firestore();
const money = (n) => Number(Number(n || 0).toFixed(2));
const uid = (req) => req.user?.uid || req.auth?.uid || req.user?.id || null;
const newReference = () => `GPFLW-${Date.now()}-${Math.random().toString(36).slice(2, 10).toUpperCase()}`;

const roundMoney = (value) => Number((Number(value || 0) + Number.EPSILON).toFixed(2));

/**
 * Build a consistent sender signature for every GiftPay bank transfer.
 * The authenticated user's verified name is preferred; registered profile
 * name and Firebase Auth display name are fallbacks. A customer description
 * is retained, but it never replaces the GiftPay/customer signature.
 * Flutterwave narration is limited to 100 characters, so the description is
 * shortened when necessary to preserve the full signature.
 */
async function resolveTransferNarration(userId, customerDescription) {
  let customerName = "";

  try {
    const userSnapshot = await db.collection("users").doc(userId).get();
    if (userSnapshot.exists) {
      const profile = userSnapshot.data() || {};
      const verification = profile.paystackBankVerification || {};
      const verifiedAccountName = verification.verifiedAt != null
        ? String(verification.accountName || "").trim()
        : "";
      const registeredName = [profile.firstName, profile.lastName]
        .map((part) => String(part || "").trim())
        .filter(Boolean)
        .join(" ");
      customerName = verifiedAccountName || registeredName ||
        String(profile.displayName || profile.fullName || profile.name || "").trim();
    }
  } catch (error) {
    console.error("Could not load customer name for transfer narration:", error.message);
  }

  // Firebase Auth display name is a final fallback if the profile has no name.
  if (!customerName) {
    try {
      const authUser = await admin.auth().getUser(userId);
      customerName = String(authUser.displayName || "").trim();
    } catch (error) {
      console.error("Could not load Firebase Auth display name for transfer narration:", error.message);
    }
  }

  const senderSignature = customerName
    ? `GiftPay / ${customerName}`
    : "GiftPay Wallet Transfer";
  const description = String(customerDescription ?? "").trim();

  if (!description) return senderSignature.slice(0, 100);

  // Always retain the sender signature, even when the customer supplies a remark.
  const separator = " | ";
  const availableDescriptionLength = Math.max(0, 100 - senderSignature.length - separator.length);
  const safeDescription = description.slice(0, availableDescriptionLength).trim();
  return safeDescription
    ? `${safeDescription}${separator}${senderSignature}`
    : senderSignature.slice(0, 100);
}

async function getFlutterwaveTransferFee(amount) {
  const response = await request("get", "/transfers/fee", null, {
    amount,
    currency: "NGN",
    type: "account",
  });

  const rows = Array.isArray(response) ? response : [];
  const ngnFee = rows.find((item) =>
    String(item?.currency || "").toUpperCase() === "NGN"
  );

  if (!ngnFee || !Number.isFinite(Number(ngnFee.fee))) {
    throw new Error("FLUTTERWAVE_FEE_UNAVAILABLE");
  }

  const providerFee = roundMoney(ngnFee.fee);
  // Flutterwave's published Nigerian transfer fees attract 7.5% VAT.
  const vat = roundMoney(providerFee * 0.075);
  return {
    amount: roundMoney(amount),
    providerFee,
    vat,
    totalFee: roundMoney(providerFee + vat),
    totalDebited: roundMoney(Number(amount) + providerFee + vat),
    currency: "NGN",
    provider: "flutterwave",
  };
}

async function persistStatus(reference, providerData) {
  const result = await applyFlutterwaveTransferStatus({ reference, providerData });
  if (!result.found) throw new Error("TRANSFER_RECORD_NOT_FOUND");
  return result.status;
}

exports.getBanks = async (_req, res) => {
  try {
    const banks = await request("get", "/banks/NG", null, { include_provider_type: 1 });
    return res.json({ status: true, data: (banks || []).filter((b) => !/mobile|momo/i.test(String(b.provider_type || ""))).map((b) => ({ name: b.name, code: String(b.code), id: b.id })) });
  } catch (e) {
    console.error("Flutterwave bank list failed:", e.response?.data || e.message);
    return res.status(502).json({ status: false, message: e.response?.data?.message || e.message || "Failed to load banks" });
  }
};

exports.resolveAccount = async (req, res) => {
  try {
    const bankCode = String(req.body?.bankCode || "").trim();
    const accountNumber = String(req.body?.accountNumber || "").trim();
    if (!bankCode || !/^\d{10}$/.test(accountNumber)) return res.status(400).json({ status: false, message: "Enter a valid 10-digit account number and select a bank." });
    const data = await request("post", "/accounts/resolve", { account_number: accountNumber, account_bank: bankCode });
    if (!data?.account_name) return res.status(400).json({ status: false, message: "Flutterwave could not verify this account." });
    return res.json({ status: true, data: { accountName: data.account_name, accountNumber: data.account_number || accountNumber, bankCode } });
  } catch (e) {
    console.error("Flutterwave account resolution failed:", e.response?.data || e.message);
    return res.status(400).json({ status: false, message: e.response?.data?.message || e.providerData?.message || e.message || "Could not verify this bank account." });
  }
};

exports.getTransferFeeQuote = async (req, res) => {
  const userId = uid(req);
  if (!userId) {
    return res.status(401).json({
      status: false,
      code: "AUTH_REQUIRED",
      message: "Authentication required.",
    });
  }

  try {
    const amount = Number(req.body?.amount);
    if (!Number.isFinite(amount) || amount <= 0 || !Number.isInteger(amount)) {
      return res.status(400).json({
        status: false,
        code: "INVALID_AMOUNT",
        message: "Enter a valid whole-naira transfer amount.",
      });
    }

    const quote = await getFlutterwaveTransferFee(amount);
    return res.json({ status: true, data: quote });
  } catch (e) {
    console.error("Flutterwave transfer fee quote failed:", e.response?.data || e.message);
    return res.status(502).json({
      status: false,
      code: "FEE_QUOTE_UNAVAILABLE",
      message: "GiftPay could not retrieve the current transfer fee from Flutterwave. Please try again.",
    });
  }
};

exports.transferToBank = async (req, res) => {
  const userId = uid(req);
  if (!userId) return res.status(401).json({ status: false, code: "AUTH_REQUIRED", message: "Authentication required." });
  const { amount, bankCode, accountNumber, accountName, reason, transactionPin } = req.body || {};
  if (!/^\d{4}$/.test(String(transactionPin || ""))) return res.status(401).json({ status: false, code: "PIN_REQUIRED", message: "A valid 4-digit transaction PIN is required." });

  let reference;
  try {
    const pin = await verifyTransactionPin(userId, String(transactionPin));
    if (!pin?.ok) return res.status(401).json({ status: false, code: pin?.code || "PIN_INVALID", message: pin?.code === "PIN_LOCKED" ? "Transaction PIN temporarily locked." : "Incorrect transaction PIN.", lockedUntil: pin?.lockedUntil || null });

    const withdrawalAmount = money(amount);
    const bank = String(bankCode || "").trim();
    const account = String(accountNumber || "").trim();
    const name = String(accountName || "").trim();
    if (!Number.isFinite(withdrawalAmount) || withdrawalAmount <= 0 || !bank || !/^\d{10}$/.test(account) || !name) return res.status(400).json({ status: false, message: "Enter a valid amount and verified destination bank account." });
    if (!Number.isInteger(withdrawalAmount)) return res.status(400).json({ status: false, message: "Flutterwave NGN bank transfers require a whole-naira amount. Please remove the decimal part." });

    // Re-resolve the beneficiary server-side; never trust a client-supplied account name.
    const resolved = await request("post", "/accounts/resolve", { account_number: account, account_bank: bank });
    const verifiedName = String(resolved?.account_name || "").trim();
    if (!verifiedName) return res.status(400).json({ status: false, message: "Flutterwave could not verify the destination account." });

    // Resolve the customer's custom/default narration on the server.
    // Customers do not need to see or enter the generated fallback.
    const transferNarration = await resolveTransferNarration(userId, reason);

    // Always obtain the current provider fee on the server immediately
    // before reserving wallet funds. Never trust a fee supplied by Flutter.
    const feeQuote = await getFlutterwaveTransferFee(withdrawalAmount);
    const fee = money(feeQuote.totalFee);
    const providerFee = money(feeQuote.providerFee);
    const vat = money(feeQuote.vat);
    const totalDebited = money(withdrawalAmount + fee);

    // The customer confirms the quote before entering their PIN. If the
    // provider's fee changes between quote and submission, stop and re-confirm.
    const quotedTotalFee = req.body?.quotedTotalFee;
    if (quotedTotalFee != null && Math.abs(money(quotedTotalFee) - fee) > 0.009) {
      return res.status(409).json({
        status: false,
        code: "FEE_CHANGED",
        message: "Flutterwave's transfer fee has changed. Please review the updated fee and confirm again.",
        data: feeQuote,
      });
    }
    reference = newReference();
    const walletRef = db.collection("wallets").doc(userId);
    const transferRef = db.collection("flutterwave_transfers").doc(reference);
    const userTxRef = db.collection("users").doc(userId).collection("transactions").doc(reference);
    let newBalance;

    await db.runTransaction(async (tx) => {
      const [walletSnap, existing] = await Promise.all([tx.get(walletRef), tx.get(transferRef)]);
      if (!walletSnap.exists) throw new Error("WALLET_NOT_FOUND");
      if (existing.exists) throw new Error("DUPLICATE_REFERENCE");
      const balance = money(walletSnap.data().balance || 0);
      if (balance < totalDebited) throw new Error("INSUFFICIENT_BALANCE");
      newBalance = money(balance - totalDebited);
      const record = {
        id: reference, reference, userId, type: "bank_transfer", title: `Transfer to ${verifiedName}`,
        amount: withdrawalAmount, fee, providerFee, vat, totalDebited, bankCode: bank, accountNumber: account,
        accountName: verifiedName, reason: transferNarration, narration: transferNarration,
        status: "SUBMITTING", provider: "flutterwave",
        createdAt: admin.firestore.FieldValue.serverTimestamp(), timestamp: Date.now(),
      };
      tx.update(walletRef, { balance: newBalance, updatedAt: admin.firestore.FieldValue.serverTimestamp() });
      tx.create(transferRef, record);
      tx.create(userTxRef, record);
      tx.create(db.collection("wallet_ledger").doc(`${reference}_debit`), { userId, reference, type: "bank_transfer_debit", amount: totalDebited, status: "reserved", createdAt: admin.firestore.FieldValue.serverTimestamp() });
    });

    try {
      const callbackUrl = String(process.env.FLUTTERWAVE_TRANSFER_CALLBACK_URL || process.env.FLW_TRANSFER_CALLBACK_URL || "").trim();
      const data = await request("post", "/transfers", {
        account_bank: bank, account_number: account, amount: withdrawalAmount, currency: "NGN",
        reference, narration: transferNarration,
        beneficiary_name: verifiedName, ...(callbackUrl ? { callback_url: callbackUrl } : {}),
      });
      const transferStatus = await persistStatus(reference, data || {});
      const message = transferStatus === "SUCCESS"
        ? "Transfer successful."
        : transferStatus === "FAILED"
          ? "Transfer failed. Any applicable refund has been processed or is being reconciled."
          : "Transfer submitted. GiftPay is confirming the final settlement status.";

      return res.status(transferStatus === "PENDING" ? 202 : 200).json({
        status: transferStatus !== "FAILED",
        message,
        requestId: reference, newBalance, amount: withdrawalAmount, fee, providerFee, vat, debited: totalDebited,
        provider: "flutterwave", providerReference: reference, providerTransferId: data?.id || null, transferStatus,
      });
    } catch (e) {
      const providerData = e.providerData || e.response?.data || null;
      const httpStatus = e.response?.status || e.httpStatus || 0;
      if (e.providerRejected || (httpStatus >= 400 && httpStatus < 500)) {
        await applyFlutterwaveTransferStatus({ reference, providerData: { ...(providerData || {}), status: "FAILED", message: providerData?.message || e.message } });
        return res.status(400).json({ status: false, code: "FLUTTERWAVE_REJECTED", message: providerData?.message || e.message || "Flutterwave rejected this transfer.", requestId: reference });
      }
      await transferRef.set({ status: "PENDING", reconciliationRequired: true, submissionError: String(e.message || "Unknown submission result"), updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
      return res.status(202).json({ status: false, code: "SUBMISSION_UNCONFIRMED", message: "Flutterwave submission could not be confirmed. Your funds remain reserved while GiftPay checks the transfer. Do not submit again.", requestId: reference, transferStatus: "PENDING_RECONCILIATION" });
    }
  } catch (e) {
    console.error("Flutterwave single transfer error:", e.response?.data || e.message);
    const message = e.message === "INSUFFICIENT_BALANCE" ? "Insufficient wallet balance for the amount and fees." : e.message === "WALLET_NOT_FOUND" ? "GiftPay wallet was not found." : e.response?.data?.message || e.providerData?.message || e.message || "Unable to initiate transfer.";
    return res.status(400).json({ status: false, code: e.message, message });
  }
};

exports.authorizeTransfer = async (_req, res) => res.status(400).json({ status: false, code: "NOT_REQUIRED", message: "Flutterwave bank transfers do not use GiftPay's Monnify OTP authorization flow. Check the transfer status instead." });
exports.resendTransferOtp = async (_req, res) => res.status(400).json({ status: false, code: "NOT_SUPPORTED", message: "OTP resend is not available for Flutterwave transfers." });

exports.getTransferStatus = async (req, res) => {
  const userId = uid(req);
  const reference = String(req.params.reference || "").trim();
  try {
    const ref = db.collection("flutterwave_transfers").doc(reference);
    const snap = await ref.get();
    if (!userId || !snap.exists || snap.data().userId !== userId) return res.status(404).json({ status: false, message: "Transfer not found." });
    const record = snap.data();
    const localDetails = {
      reference,
      providerReference: reference,
      provider: "flutterwave",
      amount: record.amount ?? null,
      fee: record.fee ?? null,
      providerFee: record.providerFee ?? null,
      vat: record.vat ?? null,
      totalDebited: record.totalDebited ?? null,
      beneficiaryName: record.accountName ?? null,
      accountNumber: record.accountNumber ?? null,
      bankCode: record.bankCode ?? null,
      narration: record.reason ?? null,
      createdAt: record.timestamp ?? null,
      providerTransferId: record.providerTransferId ?? null,
    };

    if (!record.providerTransferId) {
      return res.status(202).json({
        status: true,
        data: { ...localDetails, status: record.status || "PENDING" },
        transferStatus: record.status || "PENDING",
        message: "Flutterwave has not returned a transfer ID yet. The request remains under reconciliation.",
      });
    }

    const data = await request("get", `/transfers/${encodeURIComponent(record.providerTransferId)}`);
    const transferStatus = await persistStatus(reference, data || {});
    return res.json({
      status: true,
      data: {
        ...localDetails,
        ...(data || {}),
        reference,
        providerReference: reference,
        provider: "flutterwave",
        amount: data?.amount ?? localDetails.amount,
        fee: localDetails.fee,
        totalDebited: localDetails.totalDebited,
        beneficiaryName: data?.full_name || localDetails.beneficiaryName,
        accountNumber: data?.account_number || localDetails.accountNumber,
        bankCode: data?.bank_code || localDetails.bankCode,
        bankName: data?.bank_name || null,
        narration: data?.narration || localDetails.narration,
        createdAt: data?.created_at || localDetails.createdAt,
        status: transferStatus,
        providerStatus: data?.status || null,
      },
      transferStatus,
    });
  } catch (e) {
    console.error("Flutterwave transfer status failed:", e.response?.data || e.message);
    return res.status(502).json({ status: false, message: e.response?.data?.message || "Could not confirm transfer status. Funds remain reserved pending reconciliation." });
  }
};
