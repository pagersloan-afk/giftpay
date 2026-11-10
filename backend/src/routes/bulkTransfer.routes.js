const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const monnify = require('../controllers/bulkTransfer.controller');
const paystack = require('../controllers/paystackBulkTransfer.controller');

const selected = String(process.env.TRANSFER_PROVIDER || 'monnify').trim().toLowerCase();
const controller = selected === 'paystack' ? paystack : monnify;
if (!['monnify', 'paystack'].includes(selected)) {
  console.warn(`Unknown TRANSFER_PROVIDER "${selected}". Falling back to Monnify.`);
}

router.post('/bulk-transfer', authMiddleware, controller.createBulkTransfer);
router.get('/bulk-transfer/:batchReference', authMiddleware, controller.getBulkTransferStatus);
router.post('/bulk-transfer/:batchReference/reconcile', authMiddleware, controller.reconcileBulkTransfer);
module.exports = router;
