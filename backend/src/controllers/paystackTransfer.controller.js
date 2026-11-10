const admin = require('firebase-admin');
const FeeEngine = require('../../core/fees/fee_engine');
const { verifyTransactionPin } = require('../services/transactionPin.service');
const { request } = require('../services/paystack.transfer.client');

const db = admin.firestore();
const money = (n) => Number(Number(n || 0).toFixed(2));
const uid = (req) => req.user?.uid || req.auth?.uid || req.user?.id || null;
const statusOf = (s) => String(s || 'pending').trim().toLowerCase();
const refId = () => `gp-${Date.now()}-${Math.random().toString(36).slice(2, 12)}`;

function mapStatus(s) {
  const v = statusOf(s);
  if (v === 'success' || v === 'successful' || v === 'completed') return 'SUCCESS';
  if (v === 'failed' || v === 'reversed' || v === 'abandoned' || v === 'rejected' || v === 'blocked') return 'FAILED';
  if (v === 'otp') return 'PENDING_AUTHORIZATION';
  return 'PENDING';
}

exports.getBanks = async (_req, res) => {
  try {
    const banks = await request('get', '/bank', null, { country: 'nigeria', currency: 'NGN', perPage: 300 });
    return res.json({ status: true, data: (banks || []).filter(x => x.active !== false).map(x => ({ name: x.name, code: String(x.code), slug: x.slug || null })) });
  } catch (e) {
    console.error('Paystack bank list failed:', e.response?.data || e.message);
    return res.status(502).json({ status: false, message: e.response?.data?.message || e.message || 'Failed to load banks' });
  }
};

exports.resolveAccount = async (req, res) => {
  try {
    const bankCode = String(req.body?.bankCode || '').trim();
    const accountNumber = String(req.body?.accountNumber || '').trim();
    if (!bankCode || !/^\d{10}$/.test(accountNumber)) return res.status(400).json({ status: false, message: 'Enter a valid 10-digit account number and select a bank.' });
    const data = await request('get', '/bank/resolve', null, { account_number: accountNumber, bank_code: bankCode });
    return res.json({ status: true, data: { accountName: data.account_name, accountNumber: data.account_number || accountNumber, bankCode, bankName: data.bank_name || null } });
  } catch (e) {
    console.error('Paystack account resolution failed:', e.response?.data || e.message);
    return res.status(400).json({ status: false, message: e.response?.data?.message || e.message || 'Could not verify this bank account.' });
  }
};

async function refundOnce(userId, reference, reason, finalStatus = 'FAILED') {
  const walletRef = db.collection('wallets').doc(userId);
  const transferRef = db.collection('paystack_transfers').doc(reference);
  const ledgerRef = db.collection('wallet_ledger').doc(`${reference}_refund`);
  await db.runTransaction(async tx => {
    const [walletSnap, transferSnap, ledgerSnap] = await Promise.all([tx.get(walletRef), tx.get(transferRef), tx.get(ledgerRef)]);
    if (!transferSnap.exists || !walletSnap.exists || ledgerSnap.exists) return;
    const transfer = transferSnap.data();
    if (transfer.refunded || ['SUCCESS', 'COMPLETED'].includes(String(transfer.status).toUpperCase())) return;
    const refund = money(transfer.totalDebited);
    tx.update(walletRef, { balance: money(Number(walletSnap.data().balance || 0) + refund), updatedAt: admin.firestore.FieldValue.serverTimestamp() });
    tx.set(ledgerRef, { userId, reference, type: 'bank_transfer_refund', amount: refund, reason, status: 'completed', createdAt: admin.firestore.FieldValue.serverTimestamp() });
    tx.set(transferRef, { status: finalStatus, refunded: true, failureReason: reason, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    tx.set(db.collection('users').doc(userId).collection('transactions').doc(reference), { status: finalStatus, refunded: true, failureReason: reason, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  });
}

async function persistStatus(userId, reference, providerData) {
  const status = mapStatus(providerData?.status);
  const patch = {
    status,
    providerStatus: providerData?.status || null,
    transferCode: providerData?.transfer_code || null,
    providerId: providerData?.id || null,
    providerData: providerData || null,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  await Promise.all([
    db.collection('paystack_transfers').doc(reference).set(patch, { merge: true }),
    db.collection('users').doc(userId).collection('transactions').doc(reference).set(patch, { merge: true }),
  ]);
  if (status === 'FAILED') await refundOnce(userId, reference, providerData?.failures?.message || providerData?.reason || 'Paystack transfer failed or was reversed.');
  return status;
}

exports.transferToBank = async (req, res) => {
  const userId = uid(req);
  if (!userId) return res.status(401).json({ status: false, code: 'AUTH_REQUIRED', message: 'Authentication required.' });
  const { amount, bankCode, accountNumber, accountName, reason = 'GiftPay wallet transfer', transactionPin } = req.body || {};
  if (!/^\d{4}$/.test(String(transactionPin || ''))) return res.status(401).json({ status: false, code: 'PIN_REQUIRED', message: 'A valid 4-digit transaction PIN is required.' });
  try {
    const pin = await verifyTransactionPin(userId, String(transactionPin));
    if (!pin?.ok) return res.status(401).json({ status: false, code: pin?.code || 'PIN_INVALID', message: pin?.code === 'PIN_LOCKED' ? 'Transaction PIN temporarily locked.' : 'Incorrect transaction PIN.', lockedUntil: pin?.lockedUntil || null });

    const withdrawalAmount = money(amount);
    const bank = String(bankCode || '').trim();
    const account = String(accountNumber || '').trim();
    const name = String(accountName || '').trim();
    if (!Number.isFinite(withdrawalAmount) || withdrawalAmount <= 0 || !bank || !/^\d{10}$/.test(account) || !name) return res.status(400).json({ status: false, message: 'Enter a valid amount and verified destination bank account.' });

    // Create/retrieve the Paystack beneficiary before reserving wallet funds.
    const recipient = await request('post', '/transferrecipient', {
      type: 'nuban', name, account_number: account, bank_code: bank, currency: 'NGN',
      description: 'GiftPay bank transfer beneficiary',
    });
    if (!recipient?.recipient_code) throw new Error('Paystack did not return a transfer recipient code.');

    const feeResult = FeeEngine.withdrawal(withdrawalAmount);
    const fee = money(feeResult.fee || 0);
    const totalDebited = money(feeResult.debitAmount ?? withdrawalAmount + fee);
    const reference = refId();
    const walletRef = db.collection('wallets').doc(userId);
    const transferRef = db.collection('paystack_transfers').doc(reference);
    const userTxRef = db.collection('users').doc(userId).collection('transactions').doc(reference);
    let newBalance;

    await db.runTransaction(async tx => {
      const [walletSnap, existing] = await Promise.all([tx.get(walletRef), tx.get(transferRef)]);
      if (!walletSnap.exists) throw new Error('WALLET_NOT_FOUND');
      if (existing.exists) throw new Error('DUPLICATE_REFERENCE');
      const balance = money(walletSnap.data().balance || 0);
      if (balance < totalDebited) throw new Error('INSUFFICIENT_BALANCE');
      newBalance = money(balance - totalDebited);
      const record = {
        id: reference, reference, userId, type: 'bank_transfer', title: `Transfer to ${name}`,
        amount: withdrawalAmount, fee, totalDebited, bankCode: bank, accountNumber: account,
        accountName: name, reason: String(reason || 'GiftPay wallet transfer').slice(0, 80),
        status: 'SUBMITTING', provider: 'paystack', recipientCode: recipient.recipient_code,
        createdAt: admin.firestore.FieldValue.serverTimestamp(), timestamp: Date.now(),
      };
      tx.update(walletRef, { balance: newBalance, updatedAt: admin.firestore.FieldValue.serverTimestamp() });
      tx.set(transferRef, record);
      tx.set(userTxRef, record);
      tx.set(db.collection('wallet_ledger').doc(`${reference}_debit`), { userId, reference, type: 'bank_transfer_debit', amount: totalDebited, status: 'reserved', createdAt: admin.firestore.FieldValue.serverTimestamp() });
    });

    try {
      const data = await request('post', '/transfer', {
        source: 'balance', amount: Math.round(withdrawalAmount * 100), recipient: recipient.recipient_code,
        reference, reason: String(reason || 'GiftPay wallet transfer').slice(0, 80), currency: 'NGN',
      });
      const transferStatus = mapStatus(data?.status);
      await persistStatus(userId, reference, data || {});
      return res.status(transferStatus === 'PENDING' || transferStatus === 'PENDING_AUTHORIZATION' ? 202 : 200).json({
        status: true, message: transferStatus === 'PENDING_AUTHORIZATION' ? 'Transfer initiated and awaiting Paystack OTP authorization.' : 'Transfer submitted to Paystack.',
        requestId: reference, newBalance, amount: withdrawalAmount, fee, debited: totalDebited,
        provider: 'paystack', providerReference: reference, transferCode: data?.transfer_code || null,
        transferStatus,
      });
    } catch (e) {
      const providerData = e.providerData || e.response?.data;
      const providerHttpStatus = e.response?.status || e.httpStatus || 0;
      if (providerData && providerData.status === false && providerHttpStatus > 0 && providerHttpStatus < 500) {
        await refundOnce(userId, reference, providerData.message || e.message);
        return res.status(400).json({ status: false, code: 'PAYSTACK_REJECTED', message: providerData.message || 'Paystack rejected this transfer.', requestId: reference });
      }
      await transferRef.set({ status: 'PENDING', reconciliationRequired: true, submissionError: e.message, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
      return res.status(202).json({ status: false, code: 'SUBMISSION_UNCONFIRMED', message: 'Transfer submission could not be confirmed. Your funds remain reserved while GiftPay checks its status. Do not submit again.', requestId: reference, transferStatus: 'PENDING_RECONCILIATION' });
    }
  } catch (e) {
    console.error('Paystack single transfer error:', e.response?.data || e.message);
    const message = e.message === 'INSUFFICIENT_BALANCE' ? 'Insufficient wallet balance for the amount and fees.' : e.message === 'WALLET_NOT_FOUND' ? 'GiftPay wallet was not found.' : e.response?.data?.message || e.message || 'Unable to initiate transfer.';
    return res.status(e.message === 'INSUFFICIENT_BALANCE' ? 400 : 400).json({ status: false, code: e.message, message });
  }
};

exports.authorizeTransfer = async (req, res) => {
  const userId = uid(req); const reference = String(req.body?.reference || '').trim(); const otp = String(req.body?.authorizationCode || '').trim();
  if (!userId || !reference || !/^\d{4,8}$/.test(otp)) return res.status(400).json({ status: false, message: 'Enter the transfer reference and valid OTP.' });
  try {
    const ref = db.collection('paystack_transfers').doc(reference); const snap = await ref.get();
    if (!snap.exists || snap.data().userId !== userId) return res.status(404).json({ status: false, message: 'Transfer not found.' });
    const transfer = snap.data(); if (!transfer.transferCode) return res.status(409).json({ status: false, message: 'Paystack transfer code is not available yet. Check the transfer status.' });
    const data = await request('post', '/transfer/finalize_transfer', { transfer_code: transfer.transferCode, otp });
    const status = await persistStatus(userId, reference, data || {});
    return res.json({ status: true, message: 'Transfer authorization submitted.', data, transferStatus: status });
  } catch (e) {
    return res.status(400).json({ status: false, message: e.response?.data?.message || e.message || 'Unable to authorize transfer.' });
  }
};

exports.resendTransferOtp = async (req, res) => {
  const userId = uid(req); const reference = String(req.body?.reference || '').trim();
  try {
    const snap = await db.collection('paystack_transfers').doc(reference).get();
    if (!userId || !snap.exists || snap.data().userId !== userId) return res.status(404).json({ status: false, message: 'Transfer not found.' });
    const code = snap.data().transferCode;
    if (!code) return res.status(409).json({ status: false, message: 'Paystack transfer code is not available yet.' });
    const data = await request('post', '/transfer/resend_otp', { transfer_code: code, reason: 'resend_otp' });
    return res.json({ status: true, message: 'Paystack transfer OTP resend requested.', data });
  } catch (e) { return res.status(400).json({ status: false, message: e.response?.data?.message || e.message || 'Unable to resend transfer OTP.' }); }
};

exports.getTransferStatus = async (req, res) => {
  const userId = uid(req); const reference = String(req.params.reference || '').trim();
  try {
    const snap = await db.collection('paystack_transfers').doc(reference).get();
    if (!userId || !snap.exists || snap.data().userId !== userId) return res.status(404).json({ status: false, message: 'Transfer not found.' });
    const data = await request('get', `/transfer/verify/${encodeURIComponent(reference)}`);
    const transferStatus = await persistStatus(userId, reference, data || {});
    return res.json({ status: true, data: { ...data, status: transferStatus }, transferStatus });
  } catch (e) {
    return res.status(502).json({ status: false, message: e.response?.data?.message || 'Could not confirm the transfer status. Your transfer remains under review.' });
  }
};
