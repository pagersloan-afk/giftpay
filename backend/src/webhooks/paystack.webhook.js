const crypto = require("crypto");
const admin = require("firebase-admin");
const { sendNotification } = require("../../utils/notify");

const db = admin.firestore();

function isValidSignature(req) {
  const secret = process.env.PAYSTACK_SECRET_KEY || process.env.PAYSTACK_SECRET;
  const signature = req.headers["x-paystack-signature"];
  if (!secret || !signature || !Buffer.isBuffer(req.body)) return false;
  const digest = crypto.createHmac("sha512", secret).update(req.body).digest("hex");
  const a = Buffer.from(digest, "utf8");
  const b = Buffer.from(String(signature), "utf8");
  return a.length === b.length && crypto.timingSafeEqual(a, b);
}

async function findUserForPaystackEvent(data = {}) {
  const email = String(data.email || data.customer?.email || "").trim().toLowerCase();
  const customerCode = String(data.customer_code || data.customer?.customer_code || "").trim();
  const accountNumber = String(
    data.receiver_bank_account_number || data.dedicated_account?.account_number || data.account_number || ""
  ).trim();

  if (email) {
    const mapping = await db.collection("paystack_customer_map").doc(email).get();
    if (mapping.exists && mapping.data()?.userId) return mapping.data().userId;
    const userQuery = await db.collection("users").where("email", "==", email).limit(1).get();
    if (!userQuery.empty) return userQuery.docs[0].id;
  }

  if (customerCode) {
    const mapping = await db.collection("paystack_customer_codes").doc(customerCode).get();
    if (mapping.exists && mapping.data()?.userId) return mapping.data().userId;
  }

  if (accountNumber) {
    const userQuery = await db.collection("users")
      .where("virtualAccount.accountNumber", "==", accountNumber)
      .limit(1).get();
    if (!userQuery.empty) return userQuery.docs[0].id;
  }
  return null;
}

async function handleDvaAssignment(eventName, data) {
  const userId = await findUserForPaystackEvent(data);
  if (!userId) {
    console.warn("Paystack DVA assignment webhook could not map customer", eventName);
    return;
  }

  const userRef = db.collection("users").doc(userId);
  if (eventName.endsWith(".failed")) {
    const reason = String(data.reason || data.message || "Paystack could not assign the dedicated account");
    await userRef.set({ virtualAccountStatus: "failed", virtualAccountError: reason }, { merge: true });
    const email = String(data.email || data.customer?.email || "").trim().toLowerCase();
    if (email) await db.collection("paystack_customer_map").doc(email).set({ status: "assignment_failed", lastError: reason }, { merge: true });
    return;
  }

  const account = data.dedicated_account || data.virtual_account || data;
  const accountNumber = String(account.account_number || data.account_number || "").trim();
  const bankName = String(account.bank?.name || data.bank?.name || account.bank_name || data.bank_name || "").trim();
  const accountName = String(account.account_name || data.account_name || "").trim();
  const customerCode = String(data.customer_code || data.customer?.customer_code || "").trim();
  const accountId = account.id || data.dedicated_account_id || null;

  if (!accountNumber || !bankName) {
    console.warn("Paystack DVA success event did not include account details", JSON.stringify(data));
    await userRef.set({ virtualAccountStatus: "pending", virtualAccountError: "Paystack confirmed assignment but account details were incomplete. Support reconciliation is required." }, { merge: true });
    return;
  }

  const virtualAccount = {
    accountNumber,
    bankName,
    accountName,
    provider: "paystack",
    customerCode: customerCode || null,
    dedicatedAccountId: accountId,
    reference: customerCode || `PAYSTACK_${userId}`,
    currency: "NGN",
    createdAt: Date.now(),
  };

  await userRef.set({
    virtualAccount,
    virtualAccounts: { paystack: virtualAccount },
    virtualAccountProvider: "paystack",
    virtualAccountStatus: "ready",
    virtualAccountError: admin.firestore.FieldValue.delete(),
    // Treat Paystack's confirmed dedicated-account assignment as completion
    // of the Paystack onboarding identity step. No raw BVN is persisted.
    kycStatus: "tier1",
    onboardingStatus: "identity_verified",
    identityVerificationProvider: "paystack",
    identityVerifiedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });

  if (customerCode) {
    await db.collection("paystack_customer_codes").doc(customerCode).set({ userId, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  }
  const email = String(data.email || data.customer?.email || "").trim().toLowerCase();
  if (email) await db.collection("paystack_customer_map").doc(email).set({ userId, email, status: "account_ready", customerCode: customerCode || null, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
}

async function handleSuccessfulCharge(data) {
  const channel = String(data.authorization?.channel || "").toLowerCase();
  if (channel !== "dedicated_nuban") return;
  if (String(data.status || "").toLowerCase() !== "success") return;
  if (String(data.currency || "NGN").toUpperCase() !== "NGN") return;

  const userId = await findUserForPaystackEvent(data);
  if (!userId) {
    console.error("Paystack DVA payment could not be mapped to a GiftPay user", data.reference);
    return;
  }

  const reference = String(data.reference || data.id || "").trim();
  const amount = Number(data.amount || 0) / 100;
  if (!reference || !Number.isFinite(amount) || amount <= 0) return;

  const processedRef = db.collection("paystack_processed_webhooks").doc(`charge_${reference}`);
  const userRef = db.collection("users").doc(userId);
  const walletRef = db.collection("wallets").doc(userId);
  const timestamp = Date.now();
  const senderName = String(
    data.authorization?.sender_name || data.sender_name ||
    [data.customer?.first_name, data.customer?.last_name].filter(Boolean).join(" ") || ""
  ).trim();
  const senderAccount = String(
    data.authorization?.sender_account_number || data.sender_account_number || ""
  ).trim();
  const receiverAccount = String(
    data.receiver_bank_account_number || data.dedicated_account?.account_number || ""
  ).trim();
  const senderBank = String(
    data.authorization?.sender_bank || data.sender_bank || ""
  ).trim();
  const receiverBank = String(
    data.receiver_bank || data.dedicated_account?.bank?.name || data.dedicated_account?.bank_name || ""
  ).trim();

  const lastFour = (value) => value ? value.slice(-4) : null;
  const walletTransaction = {
    id: reference,
    type: "credit",
    title: senderName ? `from – ${senderName}` : "Wallet Funding",
    amount,
    timestamp,
    date: timestamp,
    paidAt: data.paid_at || data.paidAt || data.created_at || null,
    status: "success",
    provider: "paystack",
    channel: "dedicated_nuban",
    reference,
    currency: "NGN",
    senderName: senderName || null,
    senderBank: senderBank || null,
    senderAccountNumberLast4: lastFour(senderAccount),
    receiverBank: receiverBank || null,
    receiverAccountNumberLast4: lastFour(receiverAccount),
    narration: data.narration || data.metadata?.narration || null,
    fees: data.fees != null ? Number(data.fees) / 100 : null,
    gatewayResponse: data.gateway_response || null,
  };

  const credited = await db.runTransaction(async (transaction) => {
    const processed = await transaction.get(processedRef);
    if (processed.exists) return false;

    const userDoc = await transaction.get(userRef);
    const walletDoc = await transaction.get(walletRef);
    if (!userDoc.exists && !walletDoc.exists) throw new Error(`GiftPay user ${userId} does not exist`);

    if (userDoc.exists) {
      transaction.update(userRef, { walletBalance: admin.firestore.FieldValue.increment(amount) });
    }
    if (walletDoc.exists) {
      transaction.update(walletRef, {
        balance: admin.firestore.FieldValue.increment(amount),
        transactions: admin.firestore.FieldValue.arrayUnion(walletTransaction),
        updatedAt: admin.firestore.Timestamp.now(),
      });
    } else {
      transaction.create(walletRef, { balance: amount, transactions: [walletTransaction], updatedAt: admin.firestore.Timestamp.now() });
    }
    transaction.create(processedRef, {
      provider: "paystack",
      event: "charge.success",
      reference,
      userId,
      amount,
      processedAt: admin.firestore.Timestamp.now(),
    });
    return true;
  });

  if (credited) {
    await sendNotification(userId, "Wallet funded", `₦${amount.toLocaleString("en-NG")} has been added to your GiftPay wallet.`, "wallet");
    console.log(`Paystack wallet credit completed: ${userId} | ₦${amount} | ${reference}`);
  }
}

exports.paystackWebhook = async (req, res) => {
  if (!isValidSignature(req)) {
    console.warn("Rejected Paystack webhook with invalid signature");
    return res.status(401).send("Invalid signature");
  }

  let event;
  try {
    event = JSON.parse(req.body.toString("utf8"));
  } catch (_) {
    return res.status(400).send("Invalid JSON");
  }

  try {
    const eventName = String(event.event || "");
    const data = event.data || {};

    // The same Paystack webhook URL handles DVA collection and transfer events.
    if (["transfer.success", "transfer.failed", "transfer.reversed"].includes(eventName)) {
      const { paystackTransferWebhook } = require("./paystack.transfer.webhook");
      return paystackTransferWebhook(req, res);
    }

    if (eventName === "customeridentification.failed" || eventName === "assigndedicatedaccount.failed" || eventName === "dedicatedaccount.assign.failed") {
      await handleDvaAssignment("dedicatedaccount.assign.failed", data);
    } else if (eventName === "customeridentification.success") {
      const userId = await findUserForPaystackEvent(data);
      const customerCode = String(data.customer_code || "").trim();
      if (userId && customerCode) {
        await db.collection("paystack_customer_codes").doc(customerCode).set({ userId, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
      }
    } else if (eventName === "assigndedicatedaccount.success" || eventName === "dedicatedaccount.assign.success") {
      await handleDvaAssignment("dedicatedaccount.assign.success", data);
    } else if (eventName === "charge.success") {
      await handleSuccessfulCharge(data);
    }
    return res.status(200).send("OK");
  } catch (error) {
    console.error("Paystack webhook processing error:", error.message || error);
    // Return non-2xx so Paystack can retry after transient Firestore failures.
    return res.status(500).send("Webhook processing failed");
  }
};