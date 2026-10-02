const axios = require('axios');
const admin = require('firebase-admin');
const FeeEngine = require('../../core/fees/fee_engine');
const { verifyTransactionPin } = require('../services/transactionPin.service');
const {
  db,
  money,
  refId,
  normalizeStatus,
  reserveBatch,
  updateBatch,
  refundBatchOnce,
} = require('../services/bulkTransfer.service');

const BASE_URL =
  process.env.MONNIFY_BASE_URL || 'https://sandbox.monnify.com';
const API_KEY = process.env.MONNIFY_API_KEY;
const SECRET = process.env.MONNIFY_SECRET_KEY;
const MERCHANT_CODE = process.env.MONNIFY_MERCHANT_CODE;
const WALLET_ACCOUNT = process.env.MONNIFY_WALLET_ACCOUNT_NUMBER;

let tokenCache = null;
let tokenExpiry = 0;

async function token() {
  if (tokenCache && Date.now() < tokenExpiry - 60000) {
    return tokenCache;
  }

  if (!API_KEY || !SECRET) {
    throw new Error('MONNIFY_CREDENTIALS_MISSING');
  }

  const basic = Buffer.from(`${API_KEY}:${SECRET}`).toString('base64');

  const { data } = await axios.post(
    `${BASE_URL}/api/v1/auth/login`,
    {},
    {
      headers: {
        Authorization: `Basic ${basic}`,
        'Content-Type': 'application/json',
      },
      timeout: 15000,
    },
  );

  if (
    !data?.requestSuccessful ||
    !data?.responseBody?.accessToken
  ) {
    throw new Error(
      data?.responseMessage || 'MONNIFY_AUTH_FAILED',
    );
  }

  tokenCache = data.responseBody.accessToken;
  tokenExpiry =
    Date.now() +
    (Number(data.responseBody.expiresIn) || 3600) * 1000;

  return tokenCache;
}

async function monnify(method, path, data) {
  const accessToken = await token();

  const response = await axios({
    method,
    url: `${BASE_URL}${path}`,
    data,
    timeout: 30000,
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
  });

  if (response.data?.requestSuccessful === false) {
    const error = new Error(
      response.data.responseMessage ||
        'MONNIFY_REQUEST_REJECTED',
    );

    error.providerData = response.data;
    throw error;
  }

  return response.data;
}

function uid(req) {
  return req.user?.uid || req.user?.id || null;
}

function cleanItems(input) {
  if (
    !Array.isArray(input) ||
    input.length < 1 ||
    input.length > 5000
  ) {
    throw new Error('ITEM_COUNT_MUST_BE_1_TO_5000');
  }

  return input.map((x, i) => {
    const amount = money(x.amount);
    const bankCode = String(x.bankCode || '').trim();
    const accountNumber = String(
      x.accountNumber || '',
    ).trim();
    const accountName = String(
      x.accountName || '',
    ).trim();

    const narration = String(
      x.narration ||
        x.reason ||
        'GiftPay bulk transfer',
    )
      .trim()
      .slice(0, 80);

    if (!Number.isFinite(amount) || amount <= 0) {
      throw new Error(`INVALID_AMOUNT_AT_ROW_${i + 1}`);
    }

    if (
      !bankCode ||
      !/^\d{10}$/.test(accountNumber) ||
      !accountName
    ) {
      throw new Error(
        `INVALID_RECIPIENT_AT_ROW_${i + 1}`,
      );
    }

    const feeResult = FeeEngine.withdrawal(amount);
    const fee = money(feeResult.fee || 0);
    const debitAmount = money(
      feeResult.debitAmount ?? amount + fee,
    );

    return {
      index: i,
      amount,
      fee,
      debitAmount,
      bankCode,
      accountNumber,
      accountName,
      narration,
      reference: refId(),
    };
  });
}

async function createBulkTransfer(req, res) {
  const userId = uid(req);

  if (!userId) {
    return res.status(401).json({
      status: false,
      code: 'AUTH_REQUIRED',
      message: 'Authentication required',
    });
  }

  const {
    recipients,
    transactionPin,
    batchName = 'GiftPay bulk transfer',
  } = req.body || {};

  if (!/^\d{4}$/.test(String(transactionPin || ''))) {
    return res.status(401).json({
      status: false,
      code: 'PIN_REQUIRED',
      message:
        'A valid 4-digit transaction PIN is required',
    });
  }

  let pinResult;

  try {
    pinResult = await verifyTransactionPin(
      userId,
      String(transactionPin),
    );
  } catch (e) {
    return res.status(401).json({
      status: false,
      code: 'PIN_VERIFICATION_FAILED',
      message: e.message,
    });
  }

  if (!pinResult?.ok) {
    return res.status(401).json({
      status: false,
      code: pinResult?.code || 'INVALID_PIN',
      message:
        pinResult?.code === 'PIN_LOCKED'
          ? 'Transaction PIN temporarily locked'
          : 'Incorrect transaction PIN',
      lockedUntil: pinResult?.lockedUntil || null,
    });
  }

  let items;

  try {
    items = cleanItems(recipients);
  } catch (e) {
    return res.status(400).json({
      status: false,
      code: 'INVALID_RECIPIENTS',
      message: e.message,
    });
  }

  const batchReference =
    `GPB-${Date.now()}-` +
    Math.random().toString(36).slice(2, 8).toUpperCase();

  const totalAmount = money(
    items.reduce((s, x) => s + x.amount, 0),
  );

  const totalFees = money(
    items.reduce((s, x) => s + x.fee, 0),
  );

  const totalDebited = money(
    items.reduce((s, x) => s + x.debitAmount, 0),
  );

  try {
    await reserveBatch({
      userId,
      batchReference,
      items,
      totalAmount,
      totalFees,
      totalDebited,
    });
  } catch (e) {
    const code =
      e.message === 'INSUFFICIENT_BALANCE'
        ? 'INSUFFICIENT_BALANCE'
        : e.message;

    const status =
      code === 'INSUFFICIENT_BALANCE' ? 400 : 409;

    return res.status(status).json({
      status: false,
      code,
      message:
        code === 'INSUFFICIENT_BALANCE'
          ? 'Insufficient wallet balance for amount and fees'
          : 'Could not reserve this batch',
    });
  }

  if (!WALLET_ACCOUNT || !MERCHANT_CODE) {
    await refundBatchOnce({
      userId,
      batchReference,
      amount: totalDebited,
      reason: 'Monnify configuration missing',
    });

    await updateBatch({
      userId,
      batchReference,
      patch: {
        status: 'failed',
        failureReason: 'Monnify configuration missing',
      },
    });

    return res.status(500).json({
      status: false,
      code: 'MONNIFY_NOT_CONFIGURED',
      message:
        'Monnify payout wallet or merchant code is not configured',
    });
  }

  // Monnify bulk-disbursement payload.
  const payload = {
    batchReference,
    title: String(batchName).slice(0, 50),
    narration: 'GiftPay bulk transfer',
    sourceAccountNumber: WALLET_ACCOUNT,
    onValidationFailure: 'CONTINUE',
    transactionList: items.map((x) => ({
      amount: x.amount,
      reference: x.reference,
      narration: x.narration,
      destinationBankCode: x.bankCode,
      destinationAccountNumber: x.accountNumber,
      destinationAccountName: x.accountName,
      currency: 'NGN',
    })),
  };

  try {
    const data = await monnify(
      'post',
      '/api/v2/disbursements/batch',
      payload,
    );

    const body = data.responseBody || {};

    const providerStatus = String(
      body.status || body.batchStatus || 'PENDING',
    ).toUpperCase();

    await updateBatch({
      userId,
      batchReference,
      patch: {
        status: normalizeStatus(providerStatus),
        providerStatus,
        providerBatchReference:
          body.batchReference || batchReference,
        providerResponse: body,
        items: items.map((x) => ({
          ...x,
          status: 'processing',
        })),
        submittedAt:
          admin.firestore.FieldValue.serverTimestamp(),
      },
    });

    return res.status(202).json({
      status: true,
      message: 'Bulk transfer submitted',
      batchReference,
      providerStatus,
      itemCount: items.length,
      totalAmount,
      totalFees,
      totalDebited,
    });
  } catch (e) {
    const providerData =
      e.providerData || e.response?.data || null;

    // Only a clear provider rejection is marked failed.
    // Unknown/transport errors remain reserved for reconciliation.
    const clearReject = Boolean(
      providerData &&
        providerData.requestSuccessful === false,
    );

    if (clearReject) {
      await refundBatchOnce({
        userId,
        batchReference,
        amount: totalDebited,
        reason:
          providerData.responseMessage || e.message,
      });

      await updateBatch({
        userId,
        batchReference,
        patch: {
          status: 'failed',
          failureReason:
            providerData.responseMessage || e.message,
          providerResponse: providerData,
        },
      });

      return res.status(502).json({
        status: false,
        code: 'MONNIFY_REJECTED',
        message:
          providerData.responseMessage ||
          'Monnify rejected the batch',
        batchReference,
      });
    }

    await updateBatch({
      userId,
      batchReference,
      patch: {
        status: 'unknown',
        reconciliationRequired: true,
        submissionError: e.message,
      },
    });

    return res.status(202).json({
      status: false,
      code: 'SUBMISSION_UNCONFIRMED',
      message:
        'Submission could not be confirmed. Funds remain reserved while status is checked; do not submit this batch again.',
      batchReference,
    });
  }
}

async function getOwnedBatch(userId, batchReference) {
  const snap = await db
    .collection('bulk_transfers')
    .doc(batchReference)
    .get();

  if (
    !snap.exists ||
    snap.data().userId !== userId
  ) {
    return null;
  }

  return snap.data();
}

async function fetchProviderSummary(batchReference) {
  return monnify(
    'get',
    `/api/v2/disbursements/bulk/summary?batchReference=${encodeURIComponent(
      batchReference,
    )}`,
  );
}

async function syncSummary(
  userId,
  batchReference,
  summaryData,
) {
  const body = summaryData.responseBody || {};

  const providerStatus = String(
    body.status || body.batchStatus || '',
  ).toUpperCase();

  const txs = Array.isArray(body.transactions)
    ? body.transactions
    : [];

  const batch = await getOwnedBatch(
    userId,
    batchReference,
  );

  if (!batch) {
    throw new Error('BATCH_NOT_FOUND');
  }

  const oldItems = Array.isArray(batch.items)
    ? batch.items
    : [];

  const byRef = new Map(
    txs.map((t) => [
      String(
        t.reference || t.transactionReference || '',
      ),
      t,
    ]),
  );

  const items = oldItems.map((item) => {
    const provider = byRef.get(item.reference);

    if (!provider) {
      return item;
    }

    const status = normalizeStatus(
      provider.status || provider.transactionStatus,
    );

    return {
      ...item,
      status,
      providerStatus:
        provider.status ||
        provider.transactionStatus ||
        null,
      providerReference:
        provider.transactionReference ||
        provider.reference ||
        null,
      failureReason:
        provider.failureReason ||
        provider.message ||
        null,
    };
  });

  await updateBatch({
    userId,
    batchReference,
    patch: {
      status: normalizeStatus(providerStatus),
      providerStatus,
      providerSummary: body,
      items,
      reconciledAt:
        admin.firestore.FieldValue.serverTimestamp(),
    },
  });

  return {
    ...batch,
    status: normalizeStatus(providerStatus),
    providerStatus,
    items,
  };
}

async function getBulkTransferStatus(req, res) {
  const userId = uid(req);

  if (!userId) {
    return res.status(401).json({
      status: false,
      message: 'Authentication required',
    });
  }

  const { batchReference } = req.params;

  try {
    const batch = await getOwnedBatch(
      userId,
      batchReference,
    );

    if (!batch) {
      return res.status(404).json({
        status: false,
        code: 'BATCH_NOT_FOUND',
        message: 'Batch not found',
      });
    }

    try {
      const summary = await fetchProviderSummary(
        batch.providerBatchReference ||
          batchReference,
      );

      const updated = await syncSummary(
        userId,
        batchReference,
        summary,
      );

      return res.json({
        status: true,
        batch: updated,
      });
    } catch (providerError) {
      return res.json({
        status: true,
        batch,
        reconciliationPending: true,
        message:
          'Showing last saved status; provider status could not be refreshed',
      });
    }
  } catch (e) {
    return res.status(500).json({
      status: false,
      message: 'Unable to retrieve batch status',
    });
  }
}

async function reconcileBulkTransfer(req, res) {
  const userId = uid(req);

  if (!userId) {
    return res.status(401).json({
      status: false,
      message: 'Authentication required',
    });
  }

  const { batchReference } = req.params;

  try {
    const batch = await getOwnedBatch(
      userId,
      batchReference,
    );

    if (!batch) {
      return res.status(404).json({
        status: false,
        code: 'BATCH_NOT_FOUND',
        message: 'Batch not found',
      });
    }

    const summary = await fetchProviderSummary(
      batch.providerBatchReference ||
        batchReference,
    );

    const updated = await syncSummary(
      userId,
      batchReference,
      summary,
    );

    const items = updated.items || [];

    const allFinal =
      items.length > 0 &&
      items.every((x) =>
        ['success', 'failed'].includes(x.status),
      );

    const failedAmount = money(
      items
        .filter((x) => x.status === 'failed')
        .reduce(
          (s, x) =>
            s + Number(x.debitAmount || 0),
          0,
        ),
    );

    if (
      allFinal &&
      failedAmount > 0 &&
      !updated.refunded
    ) {
      await refundBatchOnce({
        userId,
        batchReference,
        amount: failedAmount,
        reason:
          'Refund for failed recipient transfers',
      });

      await updateBatch({
        userId,
        batchReference,
        patch: {
          partialRefunded: true,
          partialRefundAmount: failedAmount,
        },
      });
    }

    return res.json({
      status: true,
      batchReference,
      batchStatus: updated.status,
      items,
      partialRefundAmount: failedAmount,
    });
  } catch (e) {
    return res.status(502).json({
      status: false,
      code: 'RECONCILIATION_FAILED',
      message:
        'Could not confirm batch status. No automatic refund was made.',
    });
  }
}

module.exports = {
  createBulkTransfer,
  getBulkTransferStatus,
  reconcileBulkTransfer,
};