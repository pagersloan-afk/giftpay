const admin = require('firebase-admin');
const db = admin.firestore();

const money = (value) => Math.round((Number(value) + Number.EPSILON) * 100) / 100;
const refId = () => `GPB-${Date.now()}-${Math.random().toString(36).slice(2, 9).toUpperCase()}`;

function normalizeStatus(value) {
  const s = String(value || '').trim().toUpperCase();
  if (['SUCCESS', 'COMPLETED'].includes(s)) return 'success';
  if (['FAILED', 'REVERSED', 'EXPIRED', 'FAILED_ON_ACCOUNTS_VALIDATION'].includes(s)) return 'failed';
  if (s === 'PENDING_AUTHORIZATION') return 'pending_authorization';
  if (['PENDING', 'AWAITING_PROCESSING', 'IN_PROGRESS', 'PROCESSING'].includes(s)) return 'processing';
  return 'unknown';
}

async function reserveBatch({ userId, batchReference, items, totalAmount, totalFees, totalDebited }) {
  const walletRef = db.collection('wallets').doc(userId);
  const batchRef = db.collection('bulk_transfers').doc(batchReference);
  const userBatchRef = db.collection('users').doc(userId).collection('bulk_transfers').doc(batchReference);
  await db.runTransaction(async (tx) => {
    const [walletSnap, batchSnap] = await Promise.all([tx.get(walletRef), tx.get(batchRef)]);
    if (batchSnap.exists) throw new Error('DUPLICATE_BATCH_REFERENCE');
    if (!walletSnap.exists) throw new Error('WALLET_NOT_FOUND');
    const balance = money(walletSnap.data().balance || 0);
    if (balance < totalDebited) throw new Error('INSUFFICIENT_BALANCE');
    const now = admin.firestore.FieldValue.serverTimestamp();
    tx.update(walletRef, { balance: money(balance - totalDebited), updatedAt: now });
    const batchData = {
      userId, batchReference, status: 'submitting', currency: 'NGN',
      itemCount: items.length, totalAmount, totalFees, totalDebited,
      items: items.map((item) => ({ ...item, status: 'reserved' })),
      createdAt: now, updatedAt: now, refunded: false,
    };
    tx.set(batchRef, batchData);
    tx.set(userBatchRef, batchData);
    tx.set(userBatchRef.collection('items').doc('summary'), {
      batchReference, itemCount: items.length, totalAmount, totalFees, totalDebited,
      status: 'submitting', createdAt: now, updatedAt: now,
    });
    tx.set(db.collection('wallet_ledger').doc(`${batchReference}_debit`), {
      userId, reference: batchReference, type: 'bulk_transfer_debit',
      amount: totalDebited, status: 'reserved', createdAt: now,
    });
  });
  return { walletRef, batchRef, userBatchRef };
}

async function updateBatch({ userId, batchReference, patch }) {
  const batchRef = db.collection('bulk_transfers').doc(batchReference);
  const userBatchRef = db.collection('users').doc(userId).collection('bulk_transfers').doc(batchReference);
  const data = { ...patch, updatedAt: admin.firestore.FieldValue.serverTimestamp() };
  await Promise.all([batchRef.set(data, { merge: true }), userBatchRef.set(data, { merge: true })]);
}

async function refundBatchOnce({ userId, batchReference, amount, reason }) {
  const walletRef = db.collection('wallets').doc(userId);
  const batchRef = db.collection('bulk_transfers').doc(batchReference);
  const ledgerRef = db.collection('wallet_ledger').doc(`${batchReference}_refund`);
  await db.runTransaction(async (tx) => {
    const [walletSnap, batchSnap, ledgerSnap] = await Promise.all([
      tx.get(walletRef), tx.get(batchRef), tx.get(ledgerRef),
    ]);
    if (!walletSnap.exists || !batchSnap.exists) throw new Error('REFUND_RECORD_NOT_FOUND');
    if (ledgerSnap.exists || batchSnap.data().refunded === true) return;
    const balance = money(walletSnap.data().balance || 0);
    tx.update(walletRef, { balance: money(balance + amount), updatedAt: admin.firestore.FieldValue.serverTimestamp() });
    tx.set(ledgerRef, { userId, reference: batchReference, type: 'bulk_transfer_refund', amount, reason, status: 'completed', createdAt: admin.firestore.FieldValue.serverTimestamp() });
    tx.set(batchRef, { refunded: true, refundAmount: amount, refundReason: reason, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    tx.set(db.collection('users').doc(userId).collection('bulk_transfers').doc(batchReference), { refunded: true, refundAmount: amount, refundReason: reason, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  });
}

module.exports = { db, money, refId, normalizeStatus, reserveBatch, updateBatch, refundBatchOnce };
