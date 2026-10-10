const admin = require("firebase-admin");
const { sendNotification } = require("../utils/notify");
const {
  getBillers,
  getProducts,
  validateCustomer,
  vend,
  requery,
} = require("../src/services/monnifyBills.service");
const FeeEngine = require("../core/fees/fee_engine");

function responseBody(result) {
  return result?.responseBody || {};
}

function responseContent(result) {
  const body = responseBody(result);
  return Array.isArray(body.content) ? body.content : [];
}

function providerMessage(result, fallback) {
  return (
    result?.responseMessage ||
    result?.message ||
    result?.responseBody?.description ||
    result?.responseBody?.vendStatus ||
    fallback
  );
}

function normalizeStatus(result) {
  const body = responseBody(result);

  return String(
    body.vendStatus ||
      body.status ||
      result?.vendStatus ||
      result?.status ||
      ""
  )
    .trim()
    .toUpperCase();
}

function normalizeBiller(biller) {
  return {
    code: String(biller?.code ?? "").trim(),
    name: String(biller?.name ?? "").trim(),
  };
}

function normalizePlan(product) {
  const code = product?.code ?? product?.productCode;
  const name = product?.name ?? product?.productName;
  const price =
    product?.price === null || product?.price === undefined
      ? null
      : Number(product.price);

  return {
    id: code == null ? "" : String(code),
    code: code == null ? "" : String(code),

    // Keep the old Flutter-compatible field names as well.
    PRODUCT_CODE: code == null ? "" : String(code),
    PRODUCT_NAME: name == null ? "" : String(name),
    PRODUCT_AMOUNT: Number.isFinite(price) ? String(price) : "",

    name: name == null ? "" : String(name),
    price: Number.isFinite(price) ? String(price) : "",
    priceType: product?.priceType ?? null,
    metadata: product?.metadata ?? {},
  };
}

async function findDataBiller(billerCode) {
  const billersResult = await getBillers({
    size: 100,
    page: 0,
    category_code: "DATA",
  });

  if (!billersResult?.requestSuccessful) {
    throw new Error(
      providerMessage(billersResult, "Unable to fetch Monnify DATA billers")
    );
  }

  const billers = responseContent(billersResult).map(normalizeBiller);

  return billers.find(
    (item) => item.code.toLowerCase() === String(billerCode).trim().toLowerCase()
  );
}

async function findDataProduct(billerCode, planId) {
  const productsResult = await getProducts({
    biller_code: billerCode,
    size: 100,
    page: 0,
  });

  if (!productsResult?.requestSuccessful) {
    throw new Error(
      providerMessage(productsResult, "Unable to fetch Monnify data plans")
    );
  }

  const products = responseContent(productsResult);

  const selected = products.find(
    (product) =>
      String(product?.code ?? product?.productCode ?? "").trim() ===
      String(planId).trim()
  );

  if (!selected) {
    return null;
  }

  return {
    raw: selected,
    normalized: normalizePlan(selected),
  };
}

// ============================================================
// MONNIFY DATA BILLERS
// GET /api/data/networks
//
// Monnify is the source of truth. No MTN/GLO/Airtel/9mobile
// availability is hard-coded here.
// ============================================================
exports.fetchDataNetworksController = async (req, res) => {
  try {
    const result = await getBillers({
      size: 100,
      page: 0,
      category_code: "DATA",
    });

    if (!result?.requestSuccessful) {
      return res.status(502).json({
        status: false,
        message: providerMessage(
          result,
          "Unable to fetch DATA billers from Monnify"
        ),
      });
    }

    const networks = responseContent(result)
      .map(normalizeBiller)
      .filter((item) => item.code && item.name);

    return res.json({
      status: true,
      networks,
    });
  } catch (err) {
    console.error("[DATA] Monnify biller discovery error:", err);

    return res.status(err?.status >= 400 && err?.status < 500 ? err.status : 502).json({
      status: false,
      message: err?.message || "Unable to fetch DATA billers from Monnify",
    });
  }
};

// ============================================================
// MONNIFY DATA PLANS
// GET /api/data/plans/:billerCode
// ============================================================
exports.fetchDataPlansController = async (req, res) => {
  try {
    const billerCode = String(req.params.billerCode || "").trim();

    if (!billerCode) {
      return res.status(400).json({
        status: false,
        message: "billerCode is required",
      });
    }

    const biller = await findDataBiller(billerCode);

    if (!biller) {
      return res.status(404).json({
        status: false,
        message: `Monnify DATA biller not found: ${billerCode}`,
      });
    }

    const productsResult = await getProducts({
      biller_code: biller.code,
      size: 100,
      page: 0,
    });

    if (!productsResult?.requestSuccessful) {
      return res.status(502).json({
        status: false,
        message: providerMessage(
          productsResult,
          "Unable to fetch DATA plans from Monnify"
        ),
      });
    }

    const plans = responseContent(productsResult)
      .map(normalizePlan)
      .filter((plan) => plan.id && plan.name);

    return res.json({
      status: true,
      biller: {
        code: biller.code,
        name: biller.name,
      },
      plans,
    });
  } catch (err) {
    console.error("[DATA] Monnify plans error:", err);

    return res.status(err?.status >= 400 && err?.status < 500 ? err.status : 502).json({
      status: false,
      message: err?.message || "Unable to fetch DATA plans from Monnify",
    });
  }
};

// ============================================================
// WALLET DATA PURCHASE
// POST /api/data/wallet/pay-data
//
// Body:
// {
//   userId,
//   phone,
//   network, // Monnify biller code
//   planId   // Monnify product code
// }
// ============================================================
exports.walletPayData = async (req, res) => {
  const { userId, phone, network, planId } = req.body || {};

  console.log("\n================ MONNIFY WALLET PAY DATA ================");
  console.log("Incoming data purchase:", {
    userId,
    phone,
    network,
    planId,
  });

  if (!userId || !phone || !network || !planId) {
    return res.status(400).json({
      status: false,
      message: "Missing userId, phone, network, or planId",
    });
  }

  const cleanPhone = String(phone).trim();
  const billerCode = String(network).trim();
  const cleanPlanId = String(planId).trim();

  if (!cleanPhone) {
    return res.status(400).json({
      status: false,
      message: "Phone number is required",
    });
  }

  try {
    // --------------------------------------------------------
    // 1. Verify the selected biller is actually a Monnify DATA
    //    biller, and obtain the selected product from Monnify.
    // --------------------------------------------------------
    const biller = await findDataBiller(billerCode);

    if (!biller) {
      return res.status(400).json({
        status: false,
        message: `Invalid Monnify DATA biller: ${billerCode}`,
      });
    }

    const selected = await findDataProduct(biller.code, cleanPlanId);

    if (!selected) {
      return res.status(400).json({
        status: false,
        message: "Selected data plan is no longer available on Monnify",
      });
    }

    const product = selected.normalized;
    const amountInt = Math.round(Number(product.price));

    // The current wallet data screen selects a fixed-price bundle.
    // Do not invent an amount for an OPEN product.
    if (!Number.isFinite(amountInt) || amountInt <= 0) {
      return res.status(400).json({
        status: false,
        message:
          "This Monnify data product does not have a fixed price and cannot be purchased from the current data screen.",
      });
    }

    // --------------------------------------------------------
    // 2. Validate the customer BEFORE debiting the wallet.
    //    Monnify decides whether a validation reference is needed.
    // --------------------------------------------------------
    const validation = await validateCustomer({
      productCode: product.code,
      customerId: cleanPhone,
    });

    if (!validation?.requestSuccessful) {
      return res.status(400).json({
        status: false,
        message: providerMessage(
          validation,
          "Monnify customer validation failed"
        ),
      });
    }

    const validationBody = responseBody(validation);
    const vendInstruction = validationBody?.vendInstruction || {};
    const requireValidationRef =
      vendInstruction?.requireValidationRef === true;

    const validationReference =
      validationBody?.validationReference ||
      vendInstruction?.validationReference ||
      null;

    if (requireValidationRef && !validationReference) {
      return res.status(502).json({
        status: false,
        message:
          "Monnify requires a validation reference for this product, but did not return one.",
      });
    }

    // --------------------------------------------------------
    // 3. Calculate the same GiftPay data fee/cashback model
    //    already used by the existing ClubKonnect data flow.
    // --------------------------------------------------------
    const feeResult = FeeEngine.data(amountInt);
    const userPays = Number(feeResult.userPays);
    const fee = Number(feeResult.fee);

    if (!Number.isFinite(userPays) || userPays <= 0) {
      return res.status(500).json({
        status: false,
        message: "Invalid wallet charge calculated for this data plan",
      });
    }

    // --------------------------------------------------------
    // 4. Get wallet + customer email.
    //    Monnify requires emailAddress for Vend.
    // --------------------------------------------------------
    const walletRef = admin.firestore().collection("wallets").doc(userId);
    const walletDoc = await walletRef.get();

    if (!walletDoc.exists) {
      return res.status(404).json({
        status: false,
        message: "Wallet not found",
      });
    }

    const walletData = walletDoc.data() || {};
    const balance = Number(walletData.balance || 0);

    if (balance < userPays) {
      return res.status(400).json({
        status: false,
        message: "Insufficient balance",
      });
    }

    const authUser = await admin.auth().getUser(userId);
    const emailAddress = String(authUser?.email || "").trim();

    if (!emailAddress) {
      return res.status(400).json({
        status: false,
        message:
          "Your account does not have an email address required for Monnify bills payment.",
      });
    }

    // --------------------------------------------------------
    // 5. Debit wallet and create a single pending transaction.
    // --------------------------------------------------------
    const reference = `DATA-${Date.now()}`;
    const timestamp = Date.now();

    const pendingTransaction = {
      id: reference,
      type: "debit",
      title: `Data Purchase (${cleanPhone})`,
      amount: amountInt,
      fee,
      totalDebited: userPays,
      timestamp,
      status: "pending",
      provider: "monnify",
      reference,
      billerCode: biller.code,
      billerName: biller.name,
      productCode: product.code,
      productName: product.name,
      phone: cleanPhone,
    };

    await walletRef.update({
      balance: balance - userPays,
      transactions: admin.firestore.FieldValue.arrayUnion(
        pendingTransaction
      ),
    });

    await sendNotification(
      userId,
      "Wallet debited",
      `₦${userPays} debited for data purchase (${cleanPhone})`,
      "data"
    );

    // --------------------------------------------------------
    // 6. Vend.
    //
    // If Monnify throws after the wallet has been debited, we
    // deliberately leave this transaction PENDING. A provider
    // timeout/error can be ambiguous; automatically refunding
    // at that point could refund a transaction Monnify actually
    // accepted. Requery will resolve it.
    // --------------------------------------------------------
    let vendResult;

    try {
      vendResult = await vend({
        amount: amountInt,
        customerId: cleanPhone,
        productCode: product.code,
        reference,
        emailAddress,
        phoneNumber: cleanPhone,
        ...(requireValidationRef
          ? { validationReference: String(validationReference) }
          : {}),
      });
    } catch (vendError) {
      console.error(
        "[DATA] Monnify vend request error; transaction left pending:",
        vendError?.message || vendError
      );

      return res.json({
        status: true,
        pending: true,
        requestId: reference,
        message:
          "Your data purchase is processing. We are checking the Monnify transaction status.",
      });
    }

    const status = normalizeStatus(vendResult);
    const remark = providerMessage(
      vendResult,
      "Data purchase is processing"
    );

    // --------------------------------------------------------
    // 7. Immediate SUCCESS.
    // --------------------------------------------------------
    if (status === "SUCCESS" || status === "SUCCESSFUL") {
      const cashback = Number(
        FeeEngine.cashback("data", amountInt)
      );

      const walletSnapshot = await walletRef.get();
      const currentWallet = walletSnapshot.data() || {};
      const transactions = Array.isArray(currentWallet.transactions)
        ? [...currentWallet.transactions]
        : [];

      const index = transactions.findIndex(
        (transaction) => transaction?.id === reference
      );

      const successTransaction = {
        ...pendingTransaction,
        status: "success",
        timestamp: pendingTransaction.timestamp,
        providerStatus: status,
        providerResponse: responseBody(vendResult),
      };

      if (index >= 0) {
        transactions[index] = successTransaction;
      } else {
        transactions.push(successTransaction);
      }

      const updates = { transactions };

      if (cashback > 0) {
        updates.balance = admin.firestore.FieldValue.increment(
          cashback
        );
        transactions.push({
          id: `${reference}_cashback`,
          type: "credit",
          title: `Cashback: Data Purchase (${cleanPhone})`,
          amount: cashback,
          timestamp: Date.now(),
          status: "success",
          provider: "monnify",
          reference,
        });
      }

      await walletRef.update(updates);

      await sendNotification(
        userId,
        "Data purchase successful",
        `Your data bundle has been delivered to ${cleanPhone}`,
        "data"
      );

      return res.json({
        status: true,
        message: remark || "Data purchase successful",
        requestId: reference,
        reference,
        fee,
        debited: userPays,
        cashback,
      });
    }

    // --------------------------------------------------------
    // 8. Known failure.
    // --------------------------------------------------------
    if (
      status === "FAILED" ||
      status === "FAILURE" ||
      status === "DECLINED" ||
      status === "REVERSED"
    ) {
      const walletSnapshot = await walletRef.get();
      const currentWallet = walletSnapshot.data() || {};
      const transactions = Array.isArray(currentWallet.transactions)
        ? [...currentWallet.transactions]
        : [];

      const index = transactions.findIndex(
        (transaction) => transaction?.id === reference
      );

      const failedTransaction = {
        ...pendingTransaction,
        status: "failed",
        providerStatus: status,
        providerResponse: responseBody(vendResult),
      };

      if (index >= 0) {
        transactions[index] = failedTransaction;
      } else {
        transactions.push(failedTransaction);
      }

      const refundId = `${reference}_refund`;
      const refundAlreadyRecorded = transactions.some(
        (transaction) => transaction?.id === refundId
      );

      if (!refundAlreadyRecorded) {
        transactions.push({
          id: refundId,
          type: "credit",
          title: `Refund: Data Purchase Failed (${cleanPhone})`,
          amount: userPays,
          timestamp: Date.now(),
          status: "refunded",
          provider: "monnify",
          reference,
        });
      }

      await walletRef.update({
        balance: admin.firestore.FieldValue.increment(userPays),
        transactions,
      });

      await sendNotification(
        userId,
        "Data purchase failed",
        `₦${userPays} has been refunded to your wallet`,
        "data"
      );

      return res.status(400).json({
        status: false,
        message: remark || "Data purchase failed",
        requestId: reference,
        reference,
      });
    }

    // --------------------------------------------------------
    // 9. Any other Monnify status is pending.
    // --------------------------------------------------------
    return res.json({
      status: true,
      pending: true,
      requestId: reference,
      reference,
      message: remark || "Processing data purchase...",
    });
  } catch (err) {
    console.error(
      "[DATA] Wallet payment error:",
      err?.provider || err?.message || err
    );

    return res.status(500).json({
      status: false,
      message:
        err?.message || "Server error processing wallet data payment",
    });
  }
};

// ============================================================
// MONNIFY DATA REQUERY
// GET /api/data/requery/:requestId
//
// The Flutter processing screen already calls this endpoint.
// The response is normalized to the old Flutter status names:
// ORDER_COMPLETED / ORDER_FAILED / PENDING.
// ============================================================
exports.requeryDataController = async (req, res) => {
  const requestId = String(req.params.requestId || "").trim();

  if (!requestId) {
    return res.status(400).json({
      status: false,
      message: "requestId is required",
    });
  }

  try {
    const result = await requery(requestId);
    const providerStatus = normalizeStatus(result);
    const remark = providerMessage(
      result,
      "Data purchase is still processing"
    );

    // Find the wallet transaction belonging to this request.
    // The existing Flutter contract only sends requestId, so this
    // preserves that contract without inventing a new client field.
    const walletsSnapshot = await admin
      .firestore()
      .collection("wallets")
      .get();

    let userId = null;
    let walletRef = null;

    for (const doc of walletsSnapshot.docs) {
      const transactions = Array.isArray(doc.data()?.transactions)
        ? doc.data().transactions
        : [];

      if (transactions.some((transaction) => transaction?.id === requestId)) {
        userId = doc.id;
        walletRef = admin.firestore().collection("wallets").doc(userId);
        break;
      }
    }

    // Always return provider status to Flutter, even if the wallet
    // transaction cannot be found.
    if (!walletRef) {
      return res.json({
        status: true,
        data: {
          status:
            providerStatus === "SUCCESS" || providerStatus === "SUCCESSFUL"
              ? "ORDER_COMPLETED"
              : providerStatus === "FAILED" ||
                  providerStatus === "FAILURE" ||
                  providerStatus === "DECLINED" ||
                  providerStatus === "REVERSED"
                ? "ORDER_FAILED"
                : providerStatus || "PENDING",
          remark,
        },
      });
    }

    const walletDoc = await walletRef.get();
    const walletData = walletDoc.data() || {};
    const transactions = Array.isArray(walletData.transactions)
      ? [...walletData.transactions]
      : [];

    const index = transactions.findIndex(
      (transaction) => transaction?.id === requestId
    );

    if (index < 0) {
      return res.json({
        status: true,
        data: {
          status: providerStatus || "PENDING",
          remark,
        },
      });
    }

    const txn = { ...transactions[index] };

    // ----------------------------------------------------------
    // SUCCESS
    // ----------------------------------------------------------
    if (providerStatus === "SUCCESS" || providerStatus === "SUCCESSFUL") {
      if (txn.status !== "success") {
        txn.status = "success";
        txn.providerStatus = providerStatus;
        txn.providerResponse = responseBody(result);
        transactions[index] = txn;

        const updates = {
          transactions,
        };

        const baseAmount = Number(txn.amount || 0);
        const cashback = Number(
          FeeEngine.cashback("data", baseAmount)
        );

        const cashbackId = `${requestId}_cashback`;
        const cashbackExists = transactions.some(
          (transaction) => transaction?.id === cashbackId
        );

        if (cashback > 0 && !cashbackExists) {
          updates.balance = admin.firestore.FieldValue.increment(
            cashback
          );
          transactions.push({
            id: cashbackId,
            type: "credit",
            title: `Cashback: Data Purchase (${txn.phone || ""})`,
            amount: cashback,
            timestamp: Date.now(),
            status: "success",
            provider: "monnify",
            reference: requestId,
          });
        }

        await walletRef.update(updates);

        await sendNotification(
          userId,
          "Data purchase successful",
          `Your data bundle has been delivered to ${txn.phone || "the requested number"}`,
          "data"
        );
      }

      return res.json({
        status: true,
        data: {
          status: "ORDER_COMPLETED",
          remark,
        },
      });
    }

    // ----------------------------------------------------------
    // FAILURE + REFUND ONCE
    // ----------------------------------------------------------
    if (
      providerStatus === "FAILED" ||
      providerStatus === "FAILURE" ||
      providerStatus === "DECLINED" ||
      providerStatus === "REVERSED"
    ) {
      const refundId = `${requestId}_refund`;
      const refundExists = transactions.some(
        (transaction) => transaction?.id === refundId
      );

      txn.status = "failed";
      txn.providerStatus = providerStatus;
      txn.providerResponse = responseBody(result);
      transactions[index] = txn;

      const updates = {
        transactions,
      };

      if (!refundExists) {
        const refundAmount = Number(
          txn.totalDebited ?? txn.amount ?? 0
        );

        updates.balance = admin.firestore.FieldValue.increment(
          refundAmount
        );

        transactions.push({
          id: refundId,
          type: "credit",
          title: `Refund: Data Purchase Failed (${txn.phone || ""})`,
          amount: refundAmount,
          timestamp: Date.now(),
          status: "refunded",
          provider: "monnify",
          reference: requestId,
        });
      }

      await walletRef.update(updates);

      if (!refundExists) {
        await sendNotification(
          userId,
          "Data purchase failed",
          `Your wallet has been refunded for the failed data purchase`,
          "data"
        );
      }

      return res.json({
        status: true,
        data: {
          status: "ORDER_FAILED",
          remark,
        },
      });
    }

    // ----------------------------------------------------------
    // STILL PENDING
    // ----------------------------------------------------------
    return res.json({
      status: true,
      data: {
        status: providerStatus || "PENDING",
        remark,
      },
    });
  } catch (err) {
    console.error(
      "[DATA] Monnify requery error:",
      err?.provider || err?.message || err
    );

    return res.json({
      status: false,
      data: {
        status: "PENDING",
        remark:
          err?.message || "Unable to confirm data purchase status yet",
      },
    });
  }
};
