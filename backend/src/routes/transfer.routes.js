const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const monnify = require('../controllers/transfer.controller');
const paystack = require('../controllers/paystackTransfer.controller');
const flutterwave = require('../controllers/flutterwaveTransfer.controller');

// Switch providers without changing Flutter API paths.
const selected = String(process.env.TRANSFER_PROVIDER || 'monnify').trim().toLowerCase();
const controller = selected === 'paystack' ? paystack : selected === 'flutterwave' ? flutterwave : monnify;
if (!['monnify', 'paystack', 'flutterwave'].includes(selected)) {
  console.warn(`Unknown TRANSFER_PROVIDER "${selected}". Falling back to Monnify.`);
}

router.get('/banks', controller.getBanks);
router.post('/resolve-account', controller.resolveAccount);
router.post('/transfer-to-bank', authMiddleware, controller.transferToBank);
router.post('/transfer-authorize', authMiddleware, controller.authorizeTransfer);
router.post('/transfer-resend-otp', authMiddleware, controller.resendTransferOtp);
// Keep this explicitly Monnify-specific endpoint available for existing operations.
router.get('/monnify-wallet-balance', authMiddleware, monnify.getMonnifyWalletBalance);
router.get('/transfer-status/:reference', authMiddleware, controller.getTransferStatus);

module.exports = router;
