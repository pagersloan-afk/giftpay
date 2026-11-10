const crypto = require('crypto');
const admin = require('firebase-admin');
const db = admin.firestore();

function validSignature(req) {
  const secret = process.env.PAYSTACK_SECRET_KEY || process.env.PAYSTACK_SECRET;
  const signature = req.headers['x-paystack-signature'];
  if (!secret || !signature || !Buffer.isBuffer(req.body)) return false;
  const expected = crypto.createHmac('sha512', secret).update(req.body).digest('hex');
  const a = Buffer.from(expected, 'utf8'); const b = Buffer.from(String(signature), 'utf8');
  return a.length === b.length && crypto.timingSafeEqual(a, b);
}

const normalize = (s) => {
  const v = String(s || '').toLowerCase();
  if (v === 'success') return 'SUCCESS';
  if (v === 'failed' || v === 'reversed') return 'FAILED';
  return 'PENDING';
};

async function handleSingle(reference, providerData, event) {
  const transferRef = db.collection('paystack_transfers').doc(reference);
  const snap = await transferRef.get();
  if (!snap.exists) return false;
  const record = snap.data(); const userId = record.userId;
  const status = normalize(providerData.status || (event === 'transfer.success' ? 'success' : event === 'transfer.failed' || event === 'transfer.reversed' ? 'failed' : 'pending'));
  await Promise.all([
    transferRef.set({ status, providerStatus: providerData.status || event, providerData, transferCode: providerData.transfer_code || record.transferCode || null, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true }),
    db.collection('users').doc(userId).collection('transactions').doc(reference).set({ status, providerStatus: providerData.status || event, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true }),
  ]);
  if (status === 'FAILED') {
    const walletRef = db.collection('wallets').doc(userId);
    const ledgerRef = db.collection('wallet_ledger').doc(`${reference}_refund`);
    await db.runTransaction(async tx => {
      const [wallet, ledger] = await Promise.all([tx.get(walletRef), tx.get(ledgerRef)]);
      if (!wallet.exists || ledger.exists) return;
      const latest = await tx.get(transferRef);
      if (!latest.exists || latest.data().refunded || latest.data().status === 'SUCCESS') return;
      const amount = Number(latest.data().totalDebited || 0);
      tx.update(walletRef, { balance: Number((Number(wallet.data().balance || 0) + amount).toFixed(2)), updatedAt: admin.firestore.FieldValue.serverTimestamp() });
      tx.set(ledgerRef, { userId, reference, type: 'bank_transfer_refund', amount, reason: providerData.failures?.message || `Paystack transfer ${event}`, status: 'completed', createdAt: admin.firestore.FieldValue.serverTimestamp() });
      tx.set(transferRef, { refunded: true, status: 'FAILED' }, { merge: true });
      tx.set(db.collection('users').doc(userId).collection('transactions').doc(reference), { refunded: true, status: 'FAILED' }, { merge: true });
    });
  }
  return true;
}

async function paystackTransferWebhook(req, res) {
  if (!validSignature(req)) return res.status(401).send('Invalid signature');
  let body;
  try { body = JSON.parse(req.body.toString('utf8')); }
  catch (_) { return res.status(400).send('Invalid JSON'); }
  const event = String(body.event || '');
  if (!['transfer.success', 'transfer.failed', 'transfer.reversed'].includes(event)) return res.sendStatus(200);
  const data = body.data || {};
  const reference = String(data.reference || '').trim();
  if (!reference) return res.sendStatus(200);
  try {
    await handleSingle(reference, data, event);
    // Bulk rows are also represented in the parent batch document. Find the
    // batch by the reference index written at submission time.
    const index = await db.collection('paystack_transfer_refs').doc(reference).get();
    if (index.exists) {
      const { userId, batchReference } = index.data();
      const batchRef = db.collection('bulk_transfers').doc(batchReference);
      const batchSnap = await batchRef.get();
      if (batchSnap.exists && batchSnap.data().userId === userId) {
        const items = Array.isArray(batchSnap.data().items) ? batchSnap.data().items : [];
        const next = items.map(item => item.reference === reference ? { ...item, status: normalize(data.status || (event === 'transfer.success' ? 'success' : 'failed')).toLowerCase(), providerStatus: data.status || event, transferCode: data.transfer_code || item.transferCode || null, failureReason: data.failures?.message || null } : item);
        await batchRef.set({ items: next, status: next.every(x => ['success', 'failed'].includes(String(x.status).toLowerCase())) ? (next.some(x => x.status === 'failed') ? 'partial' : 'success') : 'processing', updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
        await db.collection('users').doc(userId).collection('bulk_transfers').doc(batchReference).set({ items: next, status: next.every(x => ['success', 'failed'].includes(String(x.status).toLowerCase())) ? (next.some(x => x.status === 'failed') ? 'partial' : 'success') : 'processing', updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
        if (event !== 'transfer.success') {
          const item = next.find(x => x.reference === reference);
          const walletRef = db.collection('wallets').doc(userId);
          const ledgerRef = db.collection('wallet_ledger').doc(`${reference}_refund`);
          await db.runTransaction(async tx => {
            const [wallet, ledger] = await Promise.all([tx.get(walletRef), tx.get(ledgerRef)]);
            if (!wallet.exists || ledger.exists || !item) return;
            const amount = Number(item.debitAmount || 0);
            tx.update(walletRef, { balance: Number((Number(wallet.data().balance || 0) + amount).toFixed(2)), updatedAt: admin.firestore.FieldValue.serverTimestamp() });
            tx.set(ledgerRef, { userId, reference, batchReference, type: 'bulk_transfer_refund', amount, reason: data.failures?.message || `Paystack transfer ${event}`, status: 'completed', createdAt: admin.firestore.FieldValue.serverTimestamp() });
          });
        }
      }
    }
    return res.sendStatus(200);
  } catch (e) {
    console.error('Paystack transfer webhook processing failed:', e.message || e);
    return res.sendStatus(500);
  }
}

module.exports = { paystackTransferWebhook };
