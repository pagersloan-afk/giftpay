const admin = require("firebase-admin");
const { createReservedAccount } = require("./monnify.service");

const db = admin.firestore();

function getActiveProvider() {
  const provider = String(process.env.VIRTUAL_ACCOUNT_PROVIDER || "monnify")
    .trim()
    .toLowerCase();
  return provider === "paystack" ? "paystack" : "monnify";
}

async function createOrGetVirtualAccount(userId) {
  const userRef = db.collection("users").doc(userId);
  const userSnap = await userRef.get();
  if (!userSnap.exists) throw new Error("GiftPay user profile was not found");

  const user = userSnap.data() || {};
  const provider = getActiveProvider();
  const existing = user.virtualAccount;
  const providerAccounts = user.virtualAccounts || {};
  // Older Monnify records predate the provider field. Treat those records
  // as Monnify so the new abstraction does not create duplicate accounts.
  const existingProvider = existing?.provider || user.virtualAccountProvider || "monnify";
  const providerExisting = providerAccounts[provider] || (existingProvider === provider ? existing : null);

  if (providerExisting?.accountNumber && providerExisting?.bankName) {
    const activeAccount = { ...providerExisting, provider };
    await userRef.set({ virtualAccount: activeAccount, virtualAccountProvider: provider }, { merge: true });
    return { status: "ready", provider, data: activeAccount };
  }

  if (provider === "paystack") {
    const status = user.virtualAccountStatus === "ready"
      ? "not_started"
      : (user.virtualAccountStatus || "not_started");
    if (existing?.accountNumber && existing?.bankName && existing.provider === "paystack") {
      return { status: "ready", provider, data: existing };
    }
    return {
      status,
      provider,
      message: status === "pending"
        ? "Paystack is processing your dedicated account assignment."
        : status === "failed"
          ? (user.virtualAccountError || "Paystack account assignment failed. Please retry the bank verification step.")
          : "Complete bank-account verification to request your dedicated account.",
    };
  }

  const firstName = String(user.firstName || "").trim();
  const lastName = String(user.lastName || "").trim();
  const fullName = `${firstName} ${lastName}`.trim();
  const email = String(user.email || "").trim();
  const phone = String(user.phone || "").trim();
  if (!fullName || !email || !phone) {
    throw new Error("Your GiftPay profile is missing your name, email, or phone number");
  }

  const accountReference = `USER_${userId}`;
  const response = await createReservedAccount({
    accountReference,
    accountName: fullName,
    customerEmail: email,
    customerName: fullName,
    customerPhoneNumber: phone,
  });
  const primary = response.accounts?.[0];
  if (!primary?.accountNumber) throw new Error("Monnify did not return a reserved account number");

  const virtualAccount = {
    accountNumber: primary.accountNumber,
    bankName: primary.bankName || "",
    accountName: primary.accountName || fullName,
    reference: accountReference,
    allAccounts: response.accounts || [],
    provider: "monnify",
    currency: "NGN",
    createdAt: Date.now(),
  };

  await userRef.set({
    virtualAccount,
    virtualAccounts: { ...providerAccounts, monnify: virtualAccount },
    virtualAccountProvider: "monnify",
    virtualAccountStatus: "ready",
    virtualAccountError: admin.firestore.FieldValue.delete(),
  }, { merge: true });

  return { status: "ready", provider: "monnify", data: virtualAccount };
}

module.exports = { getActiveProvider, createOrGetVirtualAccount };
