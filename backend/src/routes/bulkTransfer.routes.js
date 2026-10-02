const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const {
  createBulkTransfer,
  getBulkTransferStatus,
  reconcileBulkTransfer,
} = require('../controllers/bulkTransfer.controller');

router.post('/bulk-transfer', authMiddleware, createBulkTransfer);
router.get('/bulk-transfer/:batchReference', authMiddleware, getBulkTransferStatus);
router.post('/bulk-transfer/:batchReference/reconcile', authMiddleware, reconcileBulkTransfer);

module.exports = router;
