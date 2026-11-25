const admin = require('firebase-admin');
const FeeEngine = require('../../core/fees/fee_engine');
const { verifyTransactionPin } = require('../services/transactionPin.service');
const { request } = require('../services/flutterwave.transfer.client');
const { db, money, reserveBatch, updateBatch } = require('../services/bulkTransfer.service');

const uid = (req) => req.user?.uid || req.auth?.uid || req.user?.id || null;
const newBatchReference = () => `GPFLWB-${Date.now()}-${Math.random().toString(36).slice(2, 9).toUpperCase()}`;
const normalize = (value) => {
  const s = String(value || '').trim().toUpperCase().replace(/[.\\s-]+/g, '_');
  if (['SUCCESS', 'SUCCESSFUL', 'COMPLETED', 'TRANSFER_COMPLETED'].includes(s)) return 'success';
  if (['FAILED', 'REVERSED', 'CANCELLED', 'CANCELED', 'EXPIRED', 'TRANSFER_FAILED'].includes(s)) return 'failed';
  if (['NEW', 'PENDING', 'PROCESSING', 'QUEUED', 'AWAITING_PROCESSING'].includes(s)) return 'processing';
  return 'unknown';
};

function cleanItems(input) {
  if (!Array.isArray(input) || input.length < 1 || input.length > 5000) {
    throw new Error('ITEM_COUNT_MUST_BE_1_TO_5000');
  }
  return input.map((x, index) => {
    const amount = money(x.amount);
    const bankCode = String(x.bankCode || '').trim();
    const accountNumber = String(x.accountNumber || '').trim();
    const accountName = String(x.accountName || '').trim();
    const narration = String(x.narration || x.reason || 'GiftPay bulk transfer').trim().slice(0, 80);
    if (!Number.isFinite(amount) || amount <= 0 || !Number.isInteger(amount)) {
      throw new Error(`INVALID_WHOLE_NAIRA_AMOUNT_AT_ROW_${index + 1}`);
    }
    if (!bankCode || !/^\d{10}$/.test(accountNumber) || !accountName) {
      throw new Error(`INVALID_RECIPIENT_AT_ROW_${index + 1}`);
    }
    const feeResult = FeeEngine.withdrawal(amount);
    const fee = money(feeResult.fee || 0);
    const debitAmount = money(feeResult.debitAmount ?? amount + fee);
    return {
      index, amount, fee, debitAmount, bankCode, accountNumber, accountName,
      narration, reference: `GPFLW-${Date.now()}-${index}-${Math.random().toString(36).slice(2, 8).toUpperCase()}`,
    };
  });
}

function batchStatus(items) {
  if (!items.length) return 'unknown';
  const final = items.every((x) => ['success', 'failed'].includes(String(x.status).toLowerCase()));
  if (!final) return 'processing';
  return items.some((x) => x.status === 'failed') ? 'partial' : 'success';
}

async function getOwnedBatch(userId, batchReference) {
  const snap = await db.collection('bulk_transfers').doc(batchReference).get();
  if (!snap.exists || snap.data().userId !== userId) return null;
  return snap.data();
}

async function refundFailedItems(userId, batchReference, items) {
  const walletRef = db.collection('wallets').doc(userId);
  for (const item of items.filter((x) => x.status === 'failed')) {
    const ledgerRef = db.collection('wallet_ledger').doc(`${item.reference}_refund`);
    await db.runTransaction(async (tx) => {
      const [walletSnap, ledgerSnap] = await Promise.all([tx.get(walletRef), tx.get(ledgerRef)]);
      if (!walletSnap.exists || ledgerSnap.exists) return;
      const amount = money(item.debitAmount || 0);
      if (!(amount > 0)) return;
      tx.update(walletRef, {
        balance: money(Number(walletSnap.data().balance || 0) + amount),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      tx.create(ledgerRef, {
        userId, reference: item.reference, batchReference,
        type: 'bulk_transfer_refund', amount,
        reason: item.failureReason || 'Flutterwave bulk transfer failed',
        status: 'completed', createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });
  }
}

async function fetchBatchTransfers(batchId) {
  const all = [];
  // The shared Flutterwave client returns response.data (not the full envelope),
  // so page until Flutterwave returns an empty page. Keep a hard safety limit.
  for (let page = 1; page <= 100; page += 1) {
    const result = await request('get', '/transfers', null, { batch_id: batchId, page });
    const rows = Array.isArray(result) ? result : (result?.data || []);
    if (!rows.length) break;
    all.push(...rows);
    if (rows.length < 10) break;
  }
  return all;
}

async function refreshBatch(userId, batchReference) {
  const batch = await getOwnedBatch(userId, batchReference);
  if (!batch) throw new Error('BATCH_NOT_FOUND');
  if (!batch.providerBatchId) return batch;
  const providerRows = await fetchBatchTransfers(batch.providerBatchId);
  const byReference = new Map(providerRows.map((row) => [String(row.reference || ''), row]));
  const items = (batch.items || []).map((item) => {
    const row = byReference.get(String(item.reference));
    if (!row) return item;
    const status = normalize(row.status);
    return {
      ...item,
      status,
      providerStatus: row.status || null,
      providerTransferId: row.id || item.providerTransferId || null,
      providerReference: row.reference || item.providerReference || null,
      failureReason: status === 'failed' ? (row.complete_message || row.message || 'Flutterwave transfer failed') : null,
    };
  });
  await updateBatch({ userId, batchReference, patch: {
    provider: 'flutterwave', items, status: batchStatus(items),
    providerBatchResponse: { count: providerRows.length },
    reconciledAt: admin.firestore.FieldValue.serverTimestamp(),
  }});
  await refundFailedItems(userId, batchReference, items);
  return { ...batch, items, status: batchStatus(items) };
}

async function createBulkTransfer(req, res) {
  const userId = uid(req);
  if (!userId) return res.status(401).json({ status: false, code: 'AUTH_REQUIRED', message: 'Authentication required.' });
  const { recipients, transactionPin, batchName = 'GiftPay bulk transfer' } = req.body || {};
  if (!/^\d{4}$/.test(String(transactionPin || ''))) {
    return res.status(401).json({ status: false, code: 'PIN_REQUIRED', message: 'A valid 4-digit transaction PIN is required.' });
  }

  let items;
  try {
    const pin = await verifyTransactionPin(userId, String(transactionPin));
    if (!pin?.ok) return res.status(401).json({ status: false, code: pin?.code || 'INVALID_PIN', message: pin?.code === 'PIN_LOCKED' ? 'Transaction PIN temporarily locked.' : 'Incorrect transaction PIN.', lockedUntil: pin?.lockedUntil || null });
    items = cleanItems(recipients);
  } catch (e) {
    const code = e.message || 'BULK_TRANSFER_VALIDATION_FAILED';
    return res.status(400).json({ status: false, code, message: code === 'INSUFFICIENT_BALANCE' ? 'Insufficient wallet balance.' : code });
  }

  const batchReference = newBatchReference();
  const totalAmount = money(items.reduce((sum, x) => sum + x.amount, 0));
  const totalFees = money(items.reduce((sum, x) => sum + x.fee, 0));
  const totalDebited = money(items.reduce((sum, x) => sum + x.debitAmount, 0));

  try {
    await reserveBatch({ userId, batchReference, items, totalAmount, totalFees, totalDebited });
    await updateBatch({ userId, batchReference, patch: { provider: 'flutterwave', batchName: String(batchName).slice(0, 80), status: 'submitting', items } });
  } catch (e) {
    const code = e.message || 'BATCH_RESERVATION_FAILED';
    return res.status(code === 'INSUFFICIENT_BALANCE' ? 400 : 409).json({ status: false, code, message: code === 'INSUFFICIENT_BALANCE' ? 'Insufficient wallet balance for amount and fees.' : 'Could not reserve this batch.' });
  }

  // Index merchant references before contacting Flutterwave so webhook events can be matched.
  try {
    const indexBatch = db.batch();
    for (const item of items) {
      indexBatch.set(db.collection('flutterwave_bulk_transfer_refs').doc(item.reference), {
        userId, batchReference, createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    await indexBatch.commit();
  } catch (e) {
    await updateBatch({ userId, batchReference, patch: { status: 'unknown', reconciliationRequired: true, submissionError: 'Could not save transfer reference index.' } });
    return res.status(202).json({ status: false, code: 'SUBMISSION_UNCONFIRMED', message: 'Batch is reserved but could not be safely submitted. Contact support; do not retry this batch.', batchReference });
  }

  try {
    const response = await request('post', '/bulk-transfers', {
      currency: 'NGN',
      title: String(batchName).slice(0, 50),
      error_reporting: true,
      bulk_data: items.map((item) => ({
        bank_code: item.bankCode,
        account_number: item.accountNumber,
        beneficiary_name: item.accountName,
        amount: item.amount,
        currency: 'NGN',
        narration: item.narration,
        reference: item.reference,
      })),
    });

    const providerBatchId = response?.id;
    if (providerBatchId === undefined || providerBatchId === null) {
      await updateBatch({ userId, batchReference, patch: { status: 'unknown', reconciliationRequired: true, provider: 'flutterwave', providerResponse: response || null } });
      return res.status(202).json({ status: false, code: 'SUBMISSION_UNCONFIRMED', message: 'Flutterwave did not return a batch ID. Funds remain reserved pending reconciliation; do not submit again.', batchReference });
    }

    const submittedItems = items.map((item) => ({ ...item, status: 'processing' }));
    await updateBatch({ userId, batchReference, patch: {
      provider: 'flutterwave', providerBatchId: String(providerBatchId),
      providerBatchReference: String(providerBatchId), providerResponse: response,
      items: submittedItems, status: 'processing',
      submittedAt: admin.firestore.FieldValue.serverTimestamp(),
    }});

    return res.status(202).json({
      status: true, message: 'Bulk transfer submitted to Flutterwave.',
      batchReference, provider: 'flutterwave', providerBatchId,
      providerStatus: 'PROCESSING', itemCount: items.length,
      totalAmount, totalFees, totalDebited,
    });
  } catch (e) {
    const httpStatus = Number(e.httpStatus || e.response?.status || 0);
    const clearReject = Boolean(e.providerRejected || (httpStatus >= 400 && httpStatus < 500));
    if (clearReject) {
      // A definitive API rejection means Flutterwave did not queue the batch.
      await refundFailedItems(userId, batchReference, items.map((x) => ({ ...x, status: 'failed', failureReason: e.message })));
      await updateBatch({ userId, batchReference, patch: { status: 'failed', provider: 'flutterwave', refunded: true, failureReason: e.message, providerResponse: e.providerData || e.response?.data || null } });
      return res.status(502).json({ status: false, code: 'FLUTTERWAVE_REJECTED', message: e.providerData?.message || e.message || 'Flutterwave rejected the batch.', batchReference });
    }
    await updateBatch({ userId, batchReference, patch: { status: 'unknown', provider: 'flutterwave', reconciliationRequired: true, submissionError: e.message } });
    return res.status(202).json({ status: false, code: 'SUBMISSION_UNCONFIRMED', message: 'Flutterwave submission could not be confirmed. Funds remain reserved while GiftPay checks the batch. Do not submit it again.', batchReference });
  }
}

async function getBulkTransferStatus(req, res) {
  const userId = uid(req);
  if (!userId) return res.status(401).json({ status: false, message: 'Authentication required.' });
  try {
    const batch = await refreshBatch(userId, req.params.batchReference);
    return res.json({ status: true, batch });
  } catch (e) {
    return res.status(e.message === 'BATCH_NOT_FOUND' ? 404 : 502).json({ status: false, message: e.message === 'BATCH_NOT_FOUND' ? 'Batch not found.' : 'Unable to refresh Flutterwave batch status.' });
  }
}

async function reconcileBulkTransfer(req, res) {
  const userId = uid(req);
  if (!userId) return res.status(401).json({ status: false, message: 'Authentication required.' });
  try {
    const batch = await refreshBatch(userId, req.params.batchReference);
    return res.json({ status: true, batchReference: req.params.batchReference, batchStatus: batch.status, items: batch.items || [] });
  } catch (e) {
    return res.status(502).json({ status: false, code: 'RECONCILIATION_FAILED', message: 'Could not confirm Flutterwave batch status. No unverified refund was made.' });
  }
}

module.exports = { createBulkTransfer, getBulkTransferStatus, reconcileBulkTransfer };
