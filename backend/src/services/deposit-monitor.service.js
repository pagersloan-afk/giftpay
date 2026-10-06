const admin = require("firebase-admin");
const crypto = require("crypto");
const { getReservedAccountTransactions } = require("./monnify.service");
const { sendNotification } = require("../../utils/notify");
const db = admin.firestore();

function depositId(accountReference, transactionReference) {
  return crypto.createHash("sha256").update(`${accountReference}|${transactionReference}`).digest("hex");
}

function isEligibleDeposit(tx) {
  return String(tx?.paymentStatus || "").toUpperCase() === "PAID" &&
    tx?.completed === true &&
    String(tx?.paymentMethod || "").toUpperCase() === "ACCOUNT_TRANSFER" &&
    String(tx?.currencyCode || "").toUpperCase() === "NGN" &&
    Number(tx?.amountPaid ?? tx?.amount) > 0 &&
    Number.isFinite(Number(tx?.amountPaid ?? tx?.amount)) &&
    Boolean(tx?.transactionReference);
}

async function fetchAllPages(accountReference) {
  const size = Number(process.env.MONNIFY_TRANSACTION_PAGE_SIZE || 100);
  const maxPages = Number(process.env.MONNIFY_TRANSACTION_MAX_PAGES || 20);
  const records = [];
  for (let page = 0; page < maxPages; page++) {
    const body = await getReservedAccountTransactions(accountReference, { page, size });
    const content = Array.isArray(body?.content) ? body.content : [];
    records.push(...content);
    const totalPages = Number(body?.totalPages);
    if (body?.last === true ||
        (Number.isFinite(totalPages) && totalPages > 0 && page + 1 >= totalPages) ||
        content.length === 0) return records;
  }
  console.warn(`Monnify pagination hit max pages for ${accountReference}`);
  return records;
}

async function creditDepositOnce(userId, accountReference, tx) {
  const amount = Number(tx.amountPaid ?? tx.amount);
  const reference = String(tx.transactionReference);
  const markerRef = db.collection("monnifyDeposits").doc(depositId(accountReference, reference));
  const walletRef = db.collection("wallets").doc(userId);
  const result = await db.runTransaction(async (t) => {
    const marker = await t.get(markerRef);
    if (marker.exists) return { credited: false, reason: "already_processed" };
    const wallet = await t.get(walletRef);
    const balance = wallet.exists ? Number(wallet.data()?.balance || 0) : 0;
    if (!Number.isFinite(balance)) throw new Error(`Invalid wallet balance for ${userId}`);
    const now = Date.now();
    const walletTx = {
      id: reference, type: "credit", title: "Wallet Funding (Monnify)",
      amount, timestamp: now, status: "success", provider: "monnify",
      channel: "account_transfer", reference, accountReference, currency: "NGN",
    };
    t.set(markerRef, {
      userId, accountReference, transactionReference: reference,
      paymentReference: tx.paymentReference || reference, amount, currency: "NGN",
      paymentStatus: tx.paymentStatus, paymentMethod: tx.paymentMethod,
      status: "credited", createdOn: tx.createdOn || null,
      completedOn: tx.completedOn || null,
      creditedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    t.set(walletRef, {
      balance: balance + amount,
      transactions: admin.firestore.FieldValue.arrayUnion(walletTx),
    }, { merge: true });
    return { credited: true, amount, reference };
  });
  if (result.credited) {
    try {
      await sendNotification(userId, "Wallet funded",
        `₦${amount.toLocaleString("en-NG")} has been added to your wallet`, "wallet");
    } catch (e) {
      console.error("Monnify deposit notification failed:", e.message || e);
    }
  }
  return result;
}

async function processReservedAccount(userId, accountReference) {
  const records = await fetchAllPages(accountReference);
  let credited = 0, skipped = 0;
  for (const tx of records) {
    if (!isEligibleDeposit(tx)) { skipped++; continue; }
    const result = await creditDepositOnce(userId, accountReference, tx);
    if (result.credited) credited++;
  }
  return { userId, accountReference, records: records.length, credited, skipped };
}

async function scanReservedAccounts() {
  const users = await db.collection("users").get();
  const results = [];
  for (const userDoc of users.docs) {
    const ref = userDoc.data()?.virtualAccount?.reference;
    if (!ref) continue;
    try {
      const result = await processReservedAccount(userDoc.id, ref);
      results.push(result);
      if (result.credited) console.log(`Monnify monitor credited ${result.credited} deposit(s) for ${userDoc.id}`);
    } catch (e) {
      console.error(`Monnify monitor failed for ${userDoc.id} (${ref}):`, e.response?.data || e.message || e);
    }
  }
  return results;
}

module.exports = { isEligibleDeposit, processReservedAccount, scanReservedAccounts };
