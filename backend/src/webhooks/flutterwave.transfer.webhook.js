const admin = require('firebase-admin');
const crypto = require('crypto');
const { reconcileFoodMerchantPayoutStatus } = require('../services/foodMerchantPayout.service');
const { applyFlutterwaveTransferStatus } = require('../services/flutterwaveTransferStatus.service');

function validSecret(req) {
  const expected = String(process.env.FLUTTERWAVE_WEBHOOK_SECRET_HASH || process.env.FLW_WEBHOOK_SECRET_HASH || '');
  const received = String(req.headers['verif-hash'] || '');
  if (!expected || !received) return false;
  const a = Buffer.from(expected);
  const b = Buffer.from(received);
  return a.length === b.length && crypto.timingSafeEqual(a, b);
}

function normalizeBulkStatus(value) {
  const s = String(value || '').trim().toUpperCase().replace(/[.\\s-]+/g, '_');
  if (['SUCCESS', 'SUCCESSFUL', 'COMPLETED', 'TRANSFER_COMPLETED'].includes(s)) return 'success';
  if (['FAILED', 'REVERSED', 'CANCELLED', 'CANCELED', 'EXPIRED', 'TRANSFER_FAILED'].includes(s)) return 'failed';
  return 'processing';
}

async function applyFlutterwaveBulkItemStatus({ reference, providerData, event }) {
  const db = admin.firestore();
  const indexSnap = await db.collection('flutterwave_bulk_transfer_refs').doc(reference).get();
  if (!indexSnap.exists) return false;
  const { userId, batchReference } = indexSnap.data() || {};
  if (!userId || !batchReference) return false;

  const batchRef = db.collection('bulk_transfers').doc(batchReference);
  const userBatchRef = db.collection('users').doc(userId).collection('bulk_transfers').doc(batchReference);
  const walletRef = db.collection('wallets').doc(userId);
  const ledgerRef = db.collection('wallet_ledger').doc(`${reference}_refund`);
  const incoming = normalizeBulkStatus(providerData.status || event);
  let handled = false;

  await db.runTransaction(async (tx) => {
    const [batchSnap, walletSnap, ledgerSnap] = await Promise.all([
      tx.get(batchRef), tx.get(walletRef), tx.get(ledgerRef),
    ]);
    if (!batchSnap.exists || batchSnap.data().userId !== userId) return;
    const batch = batchSnap.data() || {};
    const oldItems = Array.isArray(batch.items) ? batch.items : [];
    const target = oldItems.find((item) => String(item.reference) === reference);
    if (!target) return;

    const current = String(target.status || '').toLowerCase();
    if (['success', 'failed'].includes(current) && current !== incoming) {
      handled = true; // Keep final state; conflicting provider signals need manual review.
      return;
    }

    const items = oldItems.map((item) => item.reference === reference ? {
      ...item,
      status: incoming,
      providerStatus: providerData.status || event || null,
      providerTransferId: providerData.id || item.providerTransferId || null,
      providerData,
      failureReason: incoming === 'failed' ? (providerData.complete_message || providerData.message || 'Flutterwave transfer failed') : null,
      updatedAt: new Date().toISOString(),
    } : item);

    if (incoming === 'failed' && !ledgerSnap.exists) {
      if (!walletSnap.exists) throw new Error('BULK_REFUND_WALLET_NOT_FOUND');
      const amount = Number(target.debitAmount || 0);
      if (Number.isFinite(amount) && amount > 0) {
        tx.update(walletRef, {
          balance: Number((Number(walletSnap.data().balance || 0) + amount).toFixed(2)),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        tx.create(ledgerRef, {
          userId, reference, batchReference, type: 'bulk_transfer_refund', amount,
          reason: providerData.complete_message || providerData.message || 'Flutterwave bulk transfer failed',
          status: 'completed', createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }

    const final = items.every((item) => ['success', 'failed'].includes(String(item.status).toLowerCase()));
    const status = !final ? 'processing' : (items.some((item) => item.status === 'failed') ? 'partial' : 'success');
    const patch = { items, status, provider: 'flutterwave', updatedAt: admin.firestore.FieldValue.serverTimestamp() };
    tx.set(batchRef, patch, { merge: true });
    tx.set(userBatchRef, patch, { merge: true });
    handled = true;
  });
  return handled;
}

async function handle(req, res) {
  if (!validSecret(req)) return res.status(401).send('Invalid Flutterwave webhook signature');
  const body = req.body || {};
  const event = String(body.event || '');
  const data = body.data || {};
  if (!event.toLowerCase().includes('transfer')) return res.sendStatus(200);

  const reference = String(data.reference || '').trim();
  if (!reference) return res.sendStatus(200);

  try {
    const db = admin.firestore();
    const foodRef = db.collection('monnify_transfers').doc(reference);
    const foodSnap = await foodRef.get();
    if (foodSnap.exists && foodSnap.data()?.type === 'food_merchant_payout') {
      const foodRecord = foodSnap.data() || {};
      if (String(foodRecord.provider || '').toLowerCase() !== 'flutterwave') return res.sendStatus(200);
      await reconcileFoodMerchantPayoutStatus({ reference, status: data.status || event, providerData: data, provider: 'flutterwave' });
      return res.sendStatus(200);
    }

    const bulkHandled = await applyFlutterwaveBulkItemStatus({ reference, providerData: data, event });
    if (bulkHandled) return res.sendStatus(200);

    await applyFlutterwaveTransferStatus({ reference, providerData: data, event });
    return res.sendStatus(200);
  } catch (e) {
    console.error('Flutterwave transfer webhook processing failed:', e.message || e);
    return res.sendStatus(500);
  }
}

module.exports = { flutterwaveTransferWebhook: handle, applyFlutterwaveBulkItemStatus };
