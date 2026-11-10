const admin = require('firebase-admin');
const FeeEngine = require('../../core/fees/fee_engine');
const { verifyTransactionPin } = require('../services/transactionPin.service');
const { request } = require('../services/paystack.transfer.client');
const { db, money, reserveBatch, updateBatch } = require('../services/bulkTransfer.service');

const uid = (req) => req.user?.uid || req.user?.id || req.auth?.uid || null;
const paystackRef = () => `gp-${Date.now()}-${Math.random().toString(36).slice(2, 12)}`;
const wait = (ms) => new Promise(resolve => setTimeout(resolve, ms));
const normalize = (s) => {
  const v = String(s || 'pending').toLowerCase();
  if (['success', 'successful', 'completed'].includes(v)) return 'success';
  if (['failed', 'reversed', 'abandoned', 'rejected', 'blocked'].includes(v)) return 'failed';
  return 'processing';
};

function cleanItems(input) {
  if (!Array.isArray(input) || input.length < 1 || input.length > 5000) throw new Error('ITEM_COUNT_MUST_BE_1_TO_5000');
  return input.map((x, index) => {
    const amount = money(x.amount);
    const bankCode = String(x.bankCode || '').trim();
    const accountNumber = String(x.accountNumber || '').trim();
    const accountName = String(x.accountName || '').trim();
    const narration = String(x.narration || x.reason || 'GiftPay bulk transfer').trim().slice(0, 80);
    if (!Number.isFinite(amount) || amount <= 0 || !bankCode || !/^\d{10}$/.test(accountNumber) || !accountName) throw new Error(`INVALID_RECIPIENT_AT_ROW_${index + 1}`);
    const fees = FeeEngine.withdrawal(amount);
    const fee = money(fees.fee || 0);
    return { index, amount, fee, debitAmount: money(fees.debitAmount ?? amount + fee), bankCode, accountNumber, accountName, narration, reference: paystackRef() };
  });
}

async function refundFailedItems(userId, batchReference, items) {
  const walletRef = db.collection('wallets').doc(userId);
  for (const item of items.filter(x => x.status === 'failed')) {
    const ledgerRef = db.collection('wallet_ledger').doc(`${item.reference}_refund`);
    await db.runTransaction(async tx => {
      const [walletSnap, ledgerSnap] = await Promise.all([tx.get(walletRef), tx.get(ledgerRef)]);
      if (!walletSnap.exists || ledgerSnap.exists) return;
      const amount = money(item.debitAmount || 0);
      tx.update(walletRef, { balance: money(Number(walletSnap.data().balance || 0) + amount), updatedAt: admin.firestore.FieldValue.serverTimestamp() });
      tx.set(ledgerRef, { userId, reference: item.reference, batchReference, type: 'bulk_transfer_refund', amount, status: 'completed', reason: item.failureReason || 'Paystack transfer failed', createdAt: admin.firestore.FieldValue.serverTimestamp() });
    });
  }
}

async function refreshBatch(userId, batchReference) {
  const snap = await db.collection('bulk_transfers').doc(batchReference).get();
  if (!snap.exists || snap.data().userId !== userId) throw new Error('BATCH_NOT_FOUND');
  const batch = snap.data();
  const oldItems = Array.isArray(batch.items) ? batch.items : [];
  const items = await Promise.all(oldItems.map(async item => {
    if (['success', 'failed'].includes(String(item.status).toLowerCase())) return item;
    try {
      const data = await request('get', `/transfer/verify/${encodeURIComponent(item.reference)}`);
      return { ...item, status: normalize(data?.status), providerStatus: data?.status || null, transferCode: data?.transfer_code || item.transferCode || null, failureReason: data?.failures?.message || data?.reason || null };
    } catch (_) { return item; }
  }));
  await updateBatch({ userId, batchReference, patch: { items, status: items.every(x => ['success', 'failed'].includes(String(x.status).toLowerCase())) ? (items.some(x => x.status === 'failed') ? 'partial' : 'success') : 'processing', provider: 'paystack', reconciledAt: admin.firestore.FieldValue.serverTimestamp() } });
  await refundFailedItems(userId, batchReference, items);
  const refreshedStatus = items.every(x => ['success', 'failed'].includes(String(x.status).toLowerCase())) ? (items.some(x => x.status === 'failed') ? 'partial' : 'success') : 'processing';
  return { ...batch, items, status: refreshedStatus };
}

async function createBulkTransfer(req, res) {
  const userId = uid(req);
  if (!userId) return res.status(401).json({ status: false, code: 'AUTH_REQUIRED', message: 'Authentication required.' });
  const { recipients, transactionPin, batchName = 'GiftPay bulk transfer' } = req.body || {};
  if (!/^\d{4}$/.test(String(transactionPin || ''))) return res.status(401).json({ status: false, code: 'PIN_REQUIRED', message: 'A valid 4-digit transaction PIN is required.' });
  try {
    const pin = await verifyTransactionPin(userId, String(transactionPin));
    if (!pin?.ok) return res.status(401).json({ status: false, code: pin?.code || 'INVALID_PIN', message: pin?.code === 'PIN_LOCKED' ? 'Transaction PIN temporarily locked.' : 'Incorrect transaction PIN.', lockedUntil: pin?.lockedUntil || null });
    const items = cleanItems(recipients);
    const batchReference = `gpb-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
    const totalAmount = money(items.reduce((s, x) => s + x.amount, 0));
    const totalFees = money(items.reduce((s, x) => s + x.fee, 0));
    const totalDebited = money(items.reduce((s, x) => s + x.debitAmount, 0));

    // Paystack's bulk endpoint requires transfer OTP approval to be disabled in the Paystack Dashboard.
    await reserveBatch({ userId, batchReference, items, totalAmount, totalFees, totalDebited });
    await updateBatch({ userId, batchReference, patch: { provider: 'paystack', batchName, status: 'preparing', items } });

    let submissionStarted = false;
    try {
      // Create beneficiaries first. This does not move funds.
      const prepared = [];
      for (const item of items) {
        const recipient = await request('post', '/transferrecipient', { type: 'nuban', name: item.accountName, account_number: item.accountNumber, bank_code: item.bankCode, currency: 'NGN', description: 'GiftPay bulk transfer beneficiary' });
        if (!recipient?.recipient_code) throw new Error(`Could not create transfer recipient for row ${item.index + 1}`);
        prepared.push({ ...item, recipientCode: recipient.recipient_code, status: 'reserved' });
      }
      await updateBatch({ userId, batchReference, patch: { items: prepared, status: 'submitting' } });
      const indexBatch = db.batch();
      for (const item of prepared) {
        indexBatch.set(db.collection('paystack_transfer_refs').doc(item.reference), { userId, batchReference, createdAt: admin.firestore.FieldValue.serverTimestamp() });
      }
      await indexBatch.commit();

      const accepted = [];
      for (let offset = 0; offset < prepared.length; offset += 100) {
        const chunk = prepared.slice(offset, offset + 100);
        if (offset > 0) await wait(5000);
        submissionStarted = true;
        const response = await request('post', '/transfer/bulk', {
          source: 'balance', currency: 'NGN',
          transfers: chunk.map(x => ({ amount: Math.round(x.amount * 100), recipient: x.recipientCode, reference: x.reference, reason: x.narration })),
        });
        const results = Array.isArray(response) ? response : [];
        const byReference = new Map(results.map(x => [String(x.reference || ''), x]));
        for (const item of chunk) {
          const result = byReference.get(item.reference);
          accepted.push({ ...item, status: result ? normalize(result.status) : 'processing', providerStatus: result?.status || null, transferCode: result?.transfer_code || null, providerId: result?.id || null });
        }
        await updateBatch({ userId, batchReference, patch: { items: [...accepted, ...prepared.slice(offset + chunk.length)], status: 'processing', provider: 'paystack', providerBatchReference: batchReference } });
      }
      await updateBatch({ userId, batchReference, patch: { items: accepted, status: accepted.every(x => ['success', 'failed'].includes(x.status)) ? (accepted.some(x => x.status === 'failed') ? 'partial' : 'success') : 'processing', submittedAt: admin.firestore.FieldValue.serverTimestamp() } });
      return res.status(202).json({ status: true, message: 'Bulk transfer submitted to Paystack.', batchReference, provider: 'paystack', providerStatus: 'PROCESSING', itemCount: accepted.length, totalAmount, totalFees, totalDebited });
    } catch (e) {
      const providerData = e.providerData || e.response?.data;
      const current = await db.collection('bulk_transfers').doc(batchReference).get();
      const saved = current.exists ? current.data() : {};
      const hasSubmitted = (saved.items || []).some(x => x.transferCode || ['success', 'processing'].includes(String(x.status).toLowerCase()));
      const providerHttpStatus = e.response?.status || e.httpStatus || 0;
      if (!hasSubmitted && (!submissionStarted || (providerData?.status === false && providerHttpStatus > 0 && providerHttpStatus < 500))) {
        // No transfer was accepted: release the full wallet reservation once.
        const ledgerRef = db.collection('wallet_ledger').doc(`${batchReference}_refund`);
        await db.runTransaction(async tx => {
          const [walletSnap, ledgerSnap] = await Promise.all([tx.get(db.collection('wallets').doc(userId)), tx.get(ledgerRef)]);
          if (walletSnap.exists && !ledgerSnap.exists) {
            tx.update(db.collection('wallets').doc(userId), { balance: money(Number(walletSnap.data().balance || 0) + totalDebited), updatedAt: admin.firestore.FieldValue.serverTimestamp() });
            tx.set(ledgerRef, { userId, reference: batchReference, type: 'bulk_transfer_refund', amount: totalDebited, reason: providerData.message || e.message, status: 'completed', createdAt: admin.firestore.FieldValue.serverTimestamp() });
          }
        });
        await updateBatch({ userId, batchReference, patch: { status: 'failed', refunded: true, failureReason: providerData.message || e.message } });
        return res.status(502).json({ status: false, code: 'PAYSTACK_REJECTED', message: providerData.message || 'Paystack rejected this batch. Wallet funds have been released.', batchReference });
      }
      await updateBatch({ userId, batchReference, patch: { status: 'unknown', reconciliationRequired: true, submissionError: e.message } });
      return res.status(202).json({ status: false, code: 'SUBMISSION_UNCONFIRMED', message: 'Some transfer submissions could not be confirmed. Funds remain reserved while GiftPay checks each transfer. Do not submit this batch again.', batchReference });
    }
  } catch (e) {
    const code = e.message || 'BULK_TRANSFER_FAILED';
    return res.status(code === 'INSUFFICIENT_BALANCE' ? 400 : 400).json({ status: false, code, message: code === 'INSUFFICIENT_BALANCE' ? 'Insufficient wallet balance for the amount and fees.' : code === 'BATCH_NOT_FOUND' ? 'Batch not found.' : code });
  }
}

async function getBulkTransferStatus(req, res) {
  const userId = uid(req); if (!userId) return res.status(401).json({ status: false, message: 'Authentication required.' });
  try { const batch = await refreshBatch(userId, req.params.batchReference); return res.json({ status: true, batch }); }
  catch (e) { return res.status(e.message === 'BATCH_NOT_FOUND' ? 404 : 502).json({ status: false, message: e.message === 'BATCH_NOT_FOUND' ? 'Batch not found.' : 'Unable to refresh Paystack batch status.' }); }
}

async function reconcileBulkTransfer(req, res) {
  const userId = uid(req); if (!userId) return res.status(401).json({ status: false, message: 'Authentication required.' });
  try { const batch = await refreshBatch(userId, req.params.batchReference); return res.json({ status: true, batchReference: req.params.batchReference, batchStatus: batch.status, items: batch.items }); }
  catch (e) { return res.status(502).json({ status: false, code: 'RECONCILIATION_FAILED', message: 'Could not confirm Paystack batch status. No unverified refund was made.' }); }
}

module.exports = { createBulkTransfer, getBulkTransferStatus, reconcileBulkTransfer };
