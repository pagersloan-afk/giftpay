const admin = require("firebase-admin");
const { createPaystackClient } = require("../services/paystack.client");
const { getActiveProvider, createOrGetVirtualAccount } = require("../services/virtualAccount.service");

const db = admin.firestore();

function paystackErrorMessage(error) {
  return error.response?.data?.message || error.response?.data?.errors?.[0]?.message || error.message || "Paystack request failed";
}

exports.getVirtualAccountConfig = async (req, res) => {
  const provider = getActiveProvider();
  return res.json({
    status: true,
    provider,
    requiresBankVerification: provider === "paystack",
    message: provider === "paystack"
      ? "Paystack is the active dedicated-account provider. Bank-account verification is required before assignment."
      : "Monnify is the active dedicated-account provider.",
  });
};

exports.getPaystackBanks = async (req, res) => {
  try {
    if (getActiveProvider() !== "paystack") {
      return res.status(409).json({ status: false, message: "Paystack is not the active virtual-account provider" });
    }
    const paystack = createPaystackClient();
    const response = await paystack.get("/bank", { params: { country: "nigeria", perPage: 200 } });
    if (!response.data?.status) throw new Error(response.data?.message || "Unable to load banks");
    const banks = (response.data.data || [])
      .filter((bank) => bank.active !== false && bank.code && bank.name)
      .map((bank) => ({ name: bank.name, code: String(bank.code) }))
      .sort((a, b) => a.name.localeCompare(b.name));
    return res.json({ status: true, data: banks });
  } catch (error) {
    console.error("Paystack bank-list error:", paystackErrorMessage(error));
    return res.status(502).json({ status: false, message: "Could not load Nigerian banks from Paystack" });
  }
};

exports.preparePaystackVirtualAccount = async (req, res) => {
  try {
    if (getActiveProvider() !== "paystack") {
      return res.status(409).json({ status: false, message: "Paystack is not the active virtual-account provider" });
    }

    const userId = req.user.uid;
    if (!req.body || typeof req.body !== "object") return res.status(400).json({ status: false, message: "Invalid request body" });
    const accountNumber = String(req.body.accountNumber || "").replace(/\s+/g, "");
    const bankCode = String(req.body.bankCode || "").trim();
    const bvn = String(req.body.bvn || "").trim();
    const preferredBank = String(req.body.preferredBank || process.env.PAYSTACK_DVA_BANK || "titan-paystack").trim();
    const consent = req.body.consent === true;

    if (!/^\d{10}$/.test(accountNumber)) {
      return res.status(400).json({ status: false, message: "Enter a valid 10-digit Nigerian bank account number" });
    }
    if (!bankCode) return res.status(400).json({ status: false, message: "Select your bank" });
    if (!/^\d{11}$/.test(bvn)) {
      return res.status(400).json({ status: false, message: "A valid 11-digit BVN is required for Paystack bank-account validation. NIN alone cannot replace this requirement." });
    }
    if (!consent) return res.status(400).json({ status: false, message: "Customer consent is required to submit identity and bank details to Paystack" });

    const userRef = db.collection("users").doc(userId);
    const userSnap = await userRef.get();
    if (!userSnap.exists) return res.status(404).json({ status: false, message: "GiftPay profile not found" });
    const user = userSnap.data() || {};

    if (!["tier1", "tier2", "verified"].includes(String(user.kycStatus || "").toLowerCase())) {
      return res.status(403).json({ status: false, message: "Complete your BVN or NIN identity verification before bank-account verification" });
    }
    const existingPaystackAccount = user.virtualAccounts?.paystack || (
      user.virtualAccount?.provider === "paystack" ? user.virtualAccount : null
    );
    if (existingPaystackAccount?.accountNumber) {
      await userRef.set({ virtualAccount: existingPaystackAccount, virtualAccountProvider: "paystack", virtualAccountStatus: "ready" }, { merge: true });
      return res.json({ status: true, statusCode: "ready", data: existingPaystackAccount });
    }
    if (user.virtualAccountStatus === "pending") {
      return res.status(202).json({ status: true, statusCode: "pending", message: "Your dedicated account assignment is already processing" });
    }

    const email = String(user.email || "").trim().toLowerCase();
    const firstName = String(user.firstName || "").trim();
    const lastName = String(user.lastName || "").trim();
    const phone = String(user.phone || "").trim();
    if (!email || !firstName || !lastName || !phone) {
      return res.status(400).json({ status: false, message: "Your profile must contain your first name, last name, email and phone number" });
    }

    const paystack = createPaystackClient();

    // Resolve the supplied bank account before sending the BVN/account pair for Paystack DVA validation.
    const resolved = await paystack.get("/bank/resolve", {
      params: { account_number: accountNumber, bank_code: bankCode },
    });
    if (!resolved.data?.status || !resolved.data?.data?.account_name) {
      return res.status(422).json({ status: false, message: "We could not verify this bank account. Check the bank and account number and try again." });
    }

    // Store only a mapping and masked verification metadata. Do not persist BVN or the full personal bank account number.
    await db.collection("paystack_customer_map").doc(email).set({
      userId,
      email,
      status: "assignment_pending",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    await userRef.set({
      virtualAccountProvider: "paystack",
      virtualAccountStatus: "pending",
      virtualAccountError: admin.firestore.FieldValue.delete(),
      paystackBankVerification: {
        bankCode,
        bankName: String(resolved.data.data.bank_name || ""),
        accountName: String(resolved.data.data.account_name),
        accountNumberLast4: accountNumber.slice(-4),
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
    }, { merge: true });

    const assignResponse = await paystack.post("/dedicated_account/assign", {
      email,
      first_name: firstName,
      last_name: lastName,
      phone,
      preferred_bank: preferredBank,
      country: "NG",
      account_number: accountNumber,
      bvn,
      bank_code: bankCode,
    });

    if (!assignResponse.data?.status) {
      throw new Error(assignResponse.data?.message || "Paystack could not start dedicated-account assignment");
    }

    return res.status(202).json({
      status: true,
      statusCode: "pending",
      message: "Your bank account was verified and Paystack is assigning your permanent GiftPay account. We will update it automatically when Paystack confirms the assignment.",
      verifiedAccountName: resolved.data.data.account_name,
    });
  } catch (error) {
    const message = paystackErrorMessage(error);
    console.error("Paystack DVA assignment error:", error.response?.data?.message || error.message);
    // If the request timed out or the connection dropped, Paystack may still
    // have accepted it. Keep the state pending to avoid an unsafe duplicate
    // assignment; the webhook/status endpoint remains authoritative.
    if (!error.response && error.isAxiosError) {
      return res.status(202).json({
        status: true,
        statusCode: "pending",
        message: "Paystack's response could not be confirmed. Your request is being treated as pending; check account status before retrying.",
      });
    }
    try {
      const userRef = db.collection("users").doc(req.user.uid);
      await userRef.set({ virtualAccountStatus: "failed", virtualAccountError: message }, { merge: true });
    } catch (_) {}
    const statusCode = error.response && error.response.status >= 400 && error.response.status < 500 ? 422 : 502;
    return res.status(statusCode).json({
      status: false,
      message: error.response?.data?.message || "Could not submit your dedicated-account request to Paystack. Please try again.",
    });
  }
};

exports.createOrGetVirtualAccount = async (req, res) => {
  try {
    const result = await createOrGetVirtualAccount(req.user.uid);
    if (result.status === "ready") return res.json({ status: true, statusCode: "ready", provider: result.provider, data: result.data });
    if (result.status === "pending") return res.status(202).json({ status: true, statusCode: "pending", provider: result.provider, message: result.message });
    return res.status(result.status === "failed" ? 409 : 202).json({ status: false, statusCode: result.status, provider: result.provider, message: result.message });
  } catch (error) {
    console.error("Virtual account creation error:", error.response?.data || error.message);
    return res.status(502).json({ status: false, message: error.message || "Unable to create virtual account" });
  }
};

exports.getVirtualAccountStatus = async (req, res) => {
  try {
    const userSnap = await db.collection("users").doc(req.user.uid).get();
    if (!userSnap.exists) return res.status(404).json({ status: false, message: "GiftPay profile not found" });
    const user = userSnap.data() || {};
    const provider = getActiveProvider();
    const providerAccount = user.virtualAccounts?.[provider] || (
      (user.virtualAccount?.provider || user.virtualAccountProvider || "monnify") === provider
        ? user.virtualAccount
        : null
    );
    if (providerAccount?.accountNumber && providerAccount?.bankName) {
      return res.json({ status: true, statusCode: "ready", provider, data: providerAccount });
    }
    const activeStatus = user.virtualAccountStatus === "ready"
      ? "not_started"
      : (user.virtualAccountStatus || "not_started");
    return res.status(activeStatus === "failed" ? 409 : 202).json({
      status: activeStatus !== "failed",
      statusCode: activeStatus,
      provider,
      message: activeStatus === "not_started"
        ? "A dedicated account has not yet been assigned for the active provider."
        : (user.virtualAccountError || "Your dedicated account is not ready yet."),
    });
  } catch (error) {
    console.error("Virtual account status error:", error.message);
    return res.status(500).json({ status: false, message: "Unable to retrieve virtual-account status" });
  }
};

// Retrieve verified details for a Paystack dedicated-account wallet credit.
// The Firebase-authenticated user can only request a reference already present
// in their own wallet transaction history.
exports.getPaystackTransactionDetails = async (req, res) => {
  try {
    const userId = req.user?.uid;
    const reference = String(req.params.reference || "").trim();

    if (!userId) {
      return res.status(401).json({ status: false, message: "Authentication required" });
    }
    if (!reference) {
      return res.status(400).json({ status: false, message: "Transaction reference is required" });
    }

    const walletSnap = await db.collection("wallets").doc(userId).get();
    if (!walletSnap.exists) {
      return res.status(404).json({ status: false, message: "Wallet not found" });
    }

    const transactions = Array.isArray(walletSnap.data()?.transactions)
      ? walletSnap.data().transactions
      : [];
    const walletTransaction = transactions.find((item) =>
      String(item?.reference || item?.id || "").trim() === reference
    );

    if (!walletTransaction || String(walletTransaction.provider || "").toLowerCase() !== "paystack") {
      return res.status(404).json({ status: false, message: "Paystack wallet transaction was not found" });
    }

    const paystack = createPaystackClient();
    const response = await paystack.get(`/transaction/verify/${encodeURIComponent(reference)}`);
    const verified = response.data?.data;

    if (!response.data?.status || !verified ||
        String(verified.reference || "") !== reference ||
        String(verified.status || "").toLowerCase() !== "success") {
      return res.status(409).json({ status: false, message: "The payment could not be verified" });
    }

    const verifiedAmount = Number(verified.amount || 0) / 100;
    const storedAmount = Number(walletTransaction.amount || 0);
    if (!Number.isFinite(verifiedAmount) || Math.abs(verifiedAmount - storedAmount) > 0.01) {
      return res.status(409).json({ status: false, message: "Verified payment details do not match this wallet transaction" });
    }

    const authorization = verified.authorization || {};
    const lastFour = (value) => {
      const digits = String(value || "").replace(/\\D/g, "");
      return digits ? digits.slice(-4) : null;
    };
    const safeDetails = {
      ...walletTransaction,
      reference,
      amount: storedAmount,
      currency: String(verified.currency || walletTransaction.currency || "NGN").toUpperCase(),
      status: "success",
      senderName: walletTransaction.senderName || authorization.sender_name || null,
      senderBank: walletTransaction.senderBank || authorization.sender_bank || null,
      senderAccountNumberLast4: walletTransaction.senderAccountNumberLast4 ||
        lastFour(authorization.sender_account_number),
      receiverAccountNumberLast4: walletTransaction.receiverAccountNumberLast4 ||
        lastFour(verified.receiver_bank_account_number),
      receiverBank: walletTransaction.receiverBank || verified.receiver_bank || null,
      narration: walletTransaction.narration || verified.metadata?.narration || null,
      fees: walletTransaction.fees ?? (verified.fees != null ? Number(verified.fees) / 100 : null),
      paidAt: walletTransaction.paidAt || verified.paid_at || verified.paidAt || verified.created_at || null,
      gatewayResponse: walletTransaction.gatewayResponse || verified.gateway_response || null,
    };

    return res.json({ status: true, data: safeDetails });
  } catch (error) {
    console.error("Paystack transaction detail error:", error.response?.data || error.message || error);
    return res.status(502).json({
      status: false,
      message: error.response?.data?.message || "Unable to retrieve payment details right now",
    });
  }
};
