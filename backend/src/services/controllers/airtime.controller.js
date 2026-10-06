const admin = require("firebase-admin");

const { sendNotification } = require("../../../utils/notify");
const FeeEngine = require("../../../core/fees/fee_engine");

const monnifyBills = require("../monnifyBills.service");
const { verifyTransactionPin } = require("../transactionPin.service");

// ============================================================
// HELPERS
// ============================================================

function extractContent(result) {
  const body = result?.responseBody;

  if (Array.isArray(body)) {
    return body;
  }

  if (Array.isArray(body?.content)) {
    return body.content;
  }

  if (Array.isArray(body?.items)) {
    return body.items;
  }

  if (Array.isArray(body?.data)) {
    return body.data;
  }

  if (Array.isArray(result?.data)) {
    return result.data;
  }

  if (Array.isArray(result?.content)) {
    return result.content;
  }

  return [];
}

function normalizeName(value) {
  return String(value || "")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]/g, "");
}

function getBillerName(biller) {
  return (
    biller?.name ||
    biller?.billerName ||
    biller?.biller_name ||
    biller?.displayName ||
    biller?.providerName ||
    biller?.code ||
    biller?.billerCode ||
    ""
  )
    .toString()
    .trim();
}

function getBillerCode(biller) {
  return (
    biller?.code ||
    biller?.billerCode ||
    biller?.biller_code ||
    ""
  )
    .toString()
    .trim();
}

function getProductCode(product) {
  return (
    product?.productCode ||
    product?.product_code ||
    product?.code ||
    ""
  )
    .toString()
    .trim();
}

function getProductName(product) {
  return (
    product?.productName ||
    product?.product_name ||
    product?.name ||
    product?.description ||
    ""
  )
    .toString()
    .trim();
}

function getProductCategoryCode(product) {
  return (
    product?.category?.code ||
    product?.categoryCode ||
    product?.category_code ||
    ""
  )
    .toString()
    .trim();
}

function getProductCategoryName(product) {
  return (
    product?.category?.name ||
    product?.categoryName ||
    product?.category_name ||
    ""
  )
    .toString()
    .trim();
}

function isAirtimeProduct(product) {
  const categoryCode = normalizeName(
    getProductCategoryCode(product)
  );

  const categoryName = normalizeName(
    getProductCategoryName(product)
  );

  const productTypeName = normalizeName(
    product?.metadata?.productType?.name
  );

  const productName = normalizeName(
    getProductName(product)
  );

  // Category is authoritative.
  if (categoryCode === "airtime") {
    return true;
  }

  if (categoryName === "airtime") {
    return true;
  }

  // Some provider catalogue responses may expose the
  // Airtime type through metadata even when category fields
  // are incomplete.
  if (productTypeName === "airtime") {
    return true;
  }

  // Do NOT classify DATA_BUNDLE products as Airtime simply
  // because their name contains "topup" or similar text.
  if (
    categoryCode === "databundle" ||
    categoryName === "databundle"
  ) {
    return false;
  }

  // Only use name-based detection when category information
  // is genuinely absent.
  const hasCategoryInformation =
    Boolean(
      categoryCode ||
        categoryName
    );

  if (hasCategoryInformation) {
    return false;
  }

  return (
    productName.includes("airtime") ||
    productName.includes("recharge") ||
    productName.includes("topup")
  );
}

// ============================================================
// NETWORK ALIASES
// ============================================================

function getNetworkName(biller) {
  const raw = normalizeName(
    getBillerName(biller)
  );

  if (raw.includes("mtn")) {
    return "MTN";
  }

  if (raw.includes("airtel")) {
    return "Airtel";
  }

  if (raw.includes("glo")) {
    return "GLO";
  }

  if (
    raw.includes("9mobile") ||
    raw === "t2" ||
    raw.includes("t2telecom")
  ) {
    return "9mobile";
  }

  return null;
}

// ============================================================
// FIND AIRTIME CATEGORY
// ============================================================

async function findAirtimeCategoryCode() {
  const result =
    await monnifyBills.getCategories({
      size: 100,
      page: 0,
    });

  const categories =
    extractContent(result);

  const category =
    categories.find((item) => {
      const code = normalizeName(
        item?.code
      );

      const name = normalizeName(
        item?.name
      );

      return (
        code === "airtime" ||
        name === "airtime"
      );
    });

  if (!category) {
    throw new Error(
      "Monnify Airtime category was not found"
    );
  }

  return (
    category.code ||
    category.name
  )
    .toString()
    .trim();
}

// ============================================================
// FIND AN ACTUAL AIRTIME PRODUCT
// ============================================================
//
// IMPORTANT:
// We never fall back to products[0].
//
// Monnify can return DATA_BUNDLE products for a biller that
// also supports AIRTIME. The product's category must therefore
// be checked explicitly.
//

function findAirtimeProduct(products) {
  if (!Array.isArray(products)) {
    return null;
  }

  const airtimeProducts =
    products.filter(
      isAirtimeProduct
    );

  if (!airtimeProducts.length) {
    return null;
  }

  // Prefer OPEN products because they support arbitrary
  // Airtime amounts such as ₦100, ₦200, ₦500, etc.
  const openProduct =
    airtimeProducts.find(
      (product) =>
        String(
          product?.priceType || ""
        )
          .trim()
          .toUpperCase() === "OPEN"
    );

  if (openProduct) {
    return openProduct;
  }

  // If there is no OPEN product, use an Airtime product.
  // The important condition is that it MUST actually be
  // classified as AIRTIME.
  return airtimeProducts[0];
}

// ============================================================
// DISCOVER AIRTIME NETWORKS
// ============================================================
//
// Returns:
//
// {
//   Airtel: "AIRTEL",
//   MTN: "MTN"
// }
//
// These are BILLER CODES, not product codes.
//
// The actual product code is resolved separately.
//

async function discoverAirtimeNetworks() {
  const categoryCode =
    await findAirtimeCategoryCode();

  const billerResult =
    await monnifyBills.getBillers({
      category_code: categoryCode,
      size: 100,
      page: 0,
    });

  const billers =
    extractContent(billerResult);

  const networks = {};

  for (const biller of billers) {
    const networkName =
      getNetworkName(biller);

    if (!networkName) {
      continue;
    }

    const billerCode =
      getBillerCode(biller);

    if (!billerCode) {
      continue;
    }

    const productResult =
      await monnifyBills.getProducts({
        biller_code: billerCode,
        size: 100,
        page: 0,
      });

    const products =
      extractContent(productResult);

    const airtimeProduct =
      findAirtimeProduct(products);

    // Do not expose a network unless Monnify actually
    // provides an Airtime product for it.
    if (!airtimeProduct) {
      console.log(
        `[MONNIFY AIRTIME] No Airtime product available for ${networkName} (${billerCode}); network excluded`
      );

      continue;
    }

    const productCode =
      getProductCode(
        airtimeProduct
      );

    if (!productCode) {
      console.log(
        `[MONNIFY AIRTIME] Airtime product for ${networkName} has no product code; network excluded`
      );

      continue;
    }

    console.log(
      `[MONNIFY AIRTIME] ${networkName} -> biller ${billerCode} -> product ${productCode} (${getProductName(
        airtimeProduct
      )})`
    );

    // IMPORTANT:
    // Return BILLER CODE to Flutter, not product code.
    networks[networkName] =
      billerCode;
  }

  return networks;
}

// ============================================================
// RESOLVE AIRTIME PRODUCT FOR BILLER
// ============================================================

async function resolveAirtimeProduct(
  billerCode
) {
  if (!billerCode) {
    throw new Error(
      "A Monnify Airtime biller code is required"
    );
  }

  const productResult =
    await monnifyBills.getProducts({
      biller_code: billerCode,
      size: 100,
      page: 0,
    });

  const products =
    extractContent(productResult);

  const airtimeProduct =
    findAirtimeProduct(products);

  if (!airtimeProduct) {
    throw new Error(
      `No Monnify Airtime product is available for biller: ${billerCode}`
    );
  }

  const productCode =
    getProductCode(
      airtimeProduct
    );

  if (!productCode) {
    throw new Error(
      `Monnify returned an Airtime product without a product code for biller: ${billerCode}`
    );
  }

  return {
    product: airtimeProduct,
    productCode,
  };
}

// ============================================================
// RESOLVE NETWORK INPUT
// ============================================================
//
// Supports both the NEW format:
//
//   Airtel
//   MTN
//   GLO
//   9mobile
//
// and the previous product-code format:
//
//   11
//   13
//
// The product-code compatibility is kept so existing Flutter
// clients do not immediately break during deployment.
//

async function resolveNetworkToBiller(
  network
) {
  const requested =
    String(network || "")
      .trim();

  if (!requested) {
    throw new Error(
      "Airtime network is required"
    );
  }

  const networks =
    await discoverAirtimeNetworks();

  // ----------------------------------------------------------
  // Preferred: Flutter sends network name
  // ----------------------------------------------------------

  const directMatch =
    Object.entries(
      networks
    ).find(
      ([name, billerCode]) =>
        normalizeName(name) ===
          normalizeName(requested) ||
        String(billerCode)
          .trim()
          .toUpperCase() ===
          requested.toUpperCase()
    );

  if (directMatch) {
    return {
      networkName:
        directMatch[0],
      billerCode:
        directMatch[1],
    };
  }

  // ----------------------------------------------------------
  // Compatibility: old Flutter may still send a Monnify
  // product code such as "11" or "13".
  //
  // Resolve that product code back to its biller.
  // ----------------------------------------------------------

  for (const [
    networkName,
    billerCode,
  ] of Object.entries(networks)) {
    try {
      const resolved =
        await resolveAirtimeProduct(
          billerCode
        );

      if (
        resolved.productCode ===
        requested
      ) {
        return {
          networkName,
          billerCode,
        };
      }
    } catch (error) {
      console.error(
        `[MONNIFY AIRTIME] Failed compatibility lookup for ${networkName}:`,
        error.message
      );
    }
  }

  throw new Error(
    `No Monnify Airtime network is available for: ${requested}`
  );
}

// ============================================================
// GET AIRTIME NETWORKS
// ============================================================

exports.getAirtimeNetworks = async (
  req,
  res
) => {
  try {
    const networks =
      await discoverAirtimeNetworks();

    if (
      !networks ||
      Object.keys(networks).length === 0
    ) {
      return res.status(503).json({
        status: false,
        message:
          "No Monnify Airtime networks are currently available",
      });
    }

    return res.json({
      status: true,
      networks,
    });
  } catch (err) {
    console.error(
      "Monnify Airtime networks error:",
      err.response?.data ||
        err.message ||
        err
    );

    return res.status(502).json({
      status: false,
      message:
        err.response?.data?.responseMessage ||
        err.message ||
        "Failed to fetch Monnify Airtime networks",
    });
  }
};

// ============================================================
// WALLET PAY AIRTIME
// ============================================================

exports.walletPayAirtime = async (
  req,
  res
) => {
  let debitCreated = false;
  let walletRef = null;
  let debitTx = null;

  try {
    // --------------------------------------------------------
    // AUTHENTICATED USER
    // --------------------------------------------------------

    const authenticatedUserId =
      req.user?.uid;

    if (!authenticatedUserId) {
      return res.status(401).json({
        status: false,
        message: "Unauthorized",
      });
    }

    const {
      phone,
      network,
      amount,
      transactionPin,
    } = req.body;

    // --------------------------------------------------------
    // TRANSACTION PIN
    // --------------------------------------------------------

    if (
      !transactionPin ||
      !/^\d{4}$/.test(String(transactionPin))
    ) {
      return res.status(401).json({
        status: false,
        message: "Transaction PIN is required",
        code: "PIN_REQUIRED",
      });
    }

    const pinResult =
      await verifyTransactionPin(
        authenticatedUserId,
        String(transactionPin)
      );

    if (!pinResult.ok) {
      return res.status(401).json({
        status: false,
        message:
          pinResult.code === "PIN_LOCKED"
            ? "Transaction PIN temporarily locked after too many failed attempts"
            : "Incorrect transaction PIN",
        code: pinResult.code,
        lockedUntil:
          pinResult.lockedUntil || null,
      });
    }

    // --------------------------------------------------------
    // INPUT VALIDATION
    // --------------------------------------------------------

    if (
      !phone ||
      !network ||
      amount === undefined ||
      amount === null
    ) {
      return res.status(400).json({
        status: false,
        message:
          "Missing phone, network, or amount",
      });
    }

    const cleanedPhone =
      String(phone).trim();

    const amountInt =
      Number(amount);

    if (
      !Number.isInteger(amountInt) ||
      amountInt < 50
    ) {
      return res.status(400).json({
        status: false,
        message:
          "Minimum Airtime amount is ₦50",
      });
    }

    // --------------------------------------------------------
    // EMAIL REQUIRED BY MONNIFY
    // --------------------------------------------------------

    const emailAddress =
      req.user?.email;

    if (!emailAddress) {
      return res.status(400).json({
        status: false,
        message:
          "Your account does not have an email address. Please update your profile before purchasing Airtime.",
      });
    }

    // --------------------------------------------------------
    // FEE ENGINE
    // --------------------------------------------------------

    const feeResult =
      FeeEngine.airtime(
        amountInt
      );

    const userPays =
      Number(
        feeResult.userPays
      );

    const fee =
      Number(
        feeResult.fee
      );

    // --------------------------------------------------------
    // WALLET
    // --------------------------------------------------------

    walletRef =
      admin
        .firestore()
        .collection("wallets")
        .doc(
          authenticatedUserId
        );

    const walletDoc =
      await walletRef.get();

    if (!walletDoc.exists) {
      return res.status(404).json({
        status: false,
        message:
          "Wallet not found",
      });
    }

    const balance =
      Number(
        walletDoc.data()?.balance ||
          0
      );

    if (
      balance <
      userPays
    ) {
      return res.status(400).json({
        status: false,
        message:
          "Insufficient balance",
      });
    }

    // --------------------------------------------------------
    // REFERENCE
    // --------------------------------------------------------

    const reference =
      `AIR-${Date.now()}-${Math.random()
        .toString(36)
        .slice(2, 8)
        .toUpperCase()}`;

    // --------------------------------------------------------
    // PENDING WALLET TRANSACTION
    // --------------------------------------------------------

    debitTx = {
      id: reference,
      type: "debit",
      title: `Airtime Purchase (${cleanedPhone})`,
      amount: amountInt,
      fee,
      totalDebited: userPays,
      timestamp: Date.now(),
      status: "pending",
      provider: "monnify",
      network,
      phone: cleanedPhone,
    };

    await walletRef.update({
      balance:
        balance -
        userPays,
      transactions:
        admin.firestore
          .FieldValue
          .arrayUnion(
            debitTx
          ),
    });

    debitCreated = true;

    await sendNotification(
      authenticatedUserId,
      "Wallet debited",
      `₦${userPays} debited for Airtime purchase (${cleanedPhone})`,
      "airtime"
    );

    // --------------------------------------------------------
    // RESOLVE BILLER
    // --------------------------------------------------------

    const resolvedNetwork =
      await resolveNetworkToBiller(
        network
      );

    const networkName =
      resolvedNetwork.networkName;

    const billerCode =
      resolvedNetwork.billerCode;

    console.log(
      `[MONNIFY AIRTIME] Payment resolved: ${network} -> ${networkName} -> biller ${billerCode}`
    );

    // --------------------------------------------------------
    // RESOLVE ACTUAL AIRTIME PRODUCT
    // --------------------------------------------------------

    const airtime =
      await resolveAirtimeProduct(
        billerCode
      );

    const productCode =
      airtime.productCode;

    console.log(
      `[MONNIFY AIRTIME] Using product ${productCode} (${getProductName(
        airtime.product
      )}) for ${networkName}`
    );

    // --------------------------------------------------------
    // MONNIFY CUSTOMER VALIDATION
    // --------------------------------------------------------

    const validation =
      await monnifyBills.validateCustomer(
        {
          productCode,
          customerId:
            cleanedPhone,
        }
      );

    if (
      validation?.requestSuccessful ===
      false
    ) {
      throw new Error(
        validation?.responseMessage ||
          "Airtime customer validation failed"
      );
    }

    const validationBody =
      validation?.responseBody ||
      validation?.data ||
      {};

    const vendInstruction =
      validationBody?.vendInstruction ||
      validation?.vendInstruction ||
      {};

    const requiresValidationReference =
      vendInstruction
        ?.requireValidationRef ===
      true;

    const validationReference =
      vendInstruction
        ?.validationReference ||
      validationBody?.validationReference ||
      validation?.validationReference ||
      null;

    if (
      requiresValidationReference &&
      !validationReference
    ) {
      throw new Error(
        "Monnify requires a validation reference, but none was returned"
      );
    }

    // --------------------------------------------------------
    // MONNIFY VEND
    // --------------------------------------------------------

    let vend;

    try {
      vend =
        await monnifyBills.vend({
          amount: amountInt,
          customerId:
            cleanedPhone,
          productCode,
          reference,
          emailAddress,
          phoneNumber:
            cleanedPhone,
          ...(requiresValidationReference
            ? {
                validationReference,
              }
            : {}),
        });
    } catch (vendError) {
      // IMPORTANT:
      // A timeout/network failure after a vend request may mean
      // Monnify accepted the transaction but the response was
      // lost. Do NOT automatically refund the customer here.

      const message =
        vendError?.response?.data
          ?.responseMessage ||
        vendError?.message ||
        "";

      const isLikelyProviderUncertainty =
        vendError?.code ===
          "ECONNABORTED" ||
        vendError?.code ===
          "ETIMEDOUT" ||
        !vendError?.response;

      if (
        isLikelyProviderUncertainty
      ) {
        return res.json({
          status: true,
          pending: true,
          reference,
          message:
            "Airtime purchase is being processed. Please wait while we confirm the transaction.",
        });
      }

      throw new Error(
        message ||
          "Monnify Airtime vending failed"
      );
    }

    // --------------------------------------------------------
    // VEND RESPONSE
    // --------------------------------------------------------

    const vendBody =
      vend?.responseBody ||
      vend?.data ||
      vend ||
      {};

    const vendStatus =
      String(
        vendBody?.vendStatus ||
          vend?.vendStatus ||
          vend?.status ||
          ""
      ).toUpperCase();

    const transactionReference =
      vendBody?.transactionReference ||
      vend?.transactionReference ||
      null;

    const vendReference =
      vendBody?.vendReference ||
      vend?.vendReference ||
      reference;

    // --------------------------------------------------------
    // SUCCESS
    // --------------------------------------------------------

    if (
      vendStatus === "SUCCESS" ||
      vendStatus === "COMPLETED"
    ) {
      const cashback =
        Number(
          FeeEngine.cashback(
            "airtime",
            amountInt
          ) || 0
        );

      const firestore =
        admin.firestore();

      await firestore.runTransaction(
        async (transaction) => {
          const currentWallet =
            await transaction.get(
              walletRef
            );

          const data =
            currentWallet.data() ||
            {};

          const transactions =
            Array.isArray(
              data.transactions
            )
              ? data.transactions
              : [];

          const updatedTransactions =
            transactions.map(
              (txn) =>
                txn.id ===
                reference
                  ? {
                      ...txn,
                      status:
                        "success",
                      provider:
                        "monnify",
                      transactionReference,
                      vendReference,
                    }
                  : txn
            );

          if (
            cashback > 0
          ) {
            updatedTransactions.push(
              {
                id: `${reference}_cashback`,
                type: "credit",
                title: `Cashback: Airtime Purchase (${cleanedPhone})`,
                amount:
                  cashback,
                timestamp:
                  Date.now(),
                status:
                  "success",
              }
            );
          }

          const currentBalance =
            Number(
              data.balance ||
                0
            );

          transaction.update(
            walletRef,
            {
              balance:
                currentBalance +
                cashback,
              transactions:
                updatedTransactions,
            }
          );
        }
      );

      await admin
        .firestore()
        .collection("users")
        .doc(
          authenticatedUserId
        )
        .collection("transactions")
        .doc(reference)
        .set({
          type: "airtime",
          provider: "monnify",
          phone:
            cleanedPhone,
          network:
            networkName,
          billerCode,
          amount:
            amountInt,
          fee,
          totalDebited:
            userPays,
          cashback,
          productCode,
          requestReference:
            reference,
          vendReference,
          transactionReference,
          status:
            "success",
          timestamp:
            Date.now(),
          raw: vend,
        });

      await sendNotification(
        authenticatedUserId,
        "Airtime purchase successful",
        `₦${amountInt} Airtime delivered to ${cleanedPhone}`,
        "airtime"
      );

      return res.json({
        status: true,
        pending: false,
        reference,
        transactionReference,
        vendReference,
        message:
          vend?.responseMessage ||
          "Airtime purchase successful",
        fee,
        debited:
          userPays,
        cashback,
      });
    }

    // --------------------------------------------------------
    // IN PROGRESS
    // --------------------------------------------------------

    if (
      vendStatus ===
        "IN_PROGRESS" ||
      vendStatus ===
        "PENDING" ||
      vendStatus ===
        "PROCESSING"
    ) {
      return res.json({
        status: true,
        pending: true,
        reference:
          transactionReference ||
          vendReference ||
          reference,
        transactionReference,
        vendReference,
        message:
          "Processing Airtime purchase...",
      });
    }

    // --------------------------------------------------------
    // FAILED
    // --------------------------------------------------------

    await refundAirtimeWallet({
      walletRef,
      reference,
      userId:
        authenticatedUserId,
      amount:
        userPays,
      phone:
        cleanedPhone,
      reason:
        vend?.responseMessage ||
        "Monnify Airtime vending failed",
    });

    return res.status(400).json({
      status: false,
      pending: false,
      reference,
      message:
        vend?.responseMessage ||
        vend?.message ||
        "Airtime vending failed",
    });
  } catch (err) {
    console.error(
      "Monnify wallet Airtime error:",
      err.response?.data ||
        err.message ||
        err
    );

    // --------------------------------------------------------
    // REFUND ONLY WHEN WE KNOW THE TRANSACTION FAILED
    // --------------------------------------------------------

    if (
      debitCreated &&
      walletRef &&
      debitTx
    ) {
      try {
        await refundAirtimeWallet({
          walletRef,
          reference:
            debitTx.id,
          userId:
            req.user?.uid,
          amount:
            debitTx.totalDebited,
          phone:
            debitTx.phone,
          reason:
            err.message ||
            "Airtime transaction failed",
        });
      } catch (refundError) {
        console.error(
          "Airtime refund error:",
          refundError
        );
      }
    }

    return res.status(400).json({
      status: false,
      message:
        err.message ||
        "Unable to process Airtime purchase",
    });
  }
};

// ============================================================
// REFUND
// ============================================================

async function refundAirtimeWallet({
  walletRef,
  reference,
  userId,
  amount,
  phone,
  reason,
}) {
  const firestore =
    admin.firestore();

  await firestore.runTransaction(
    async (transaction) => {
      const walletDoc =
        await transaction.get(
          walletRef
        );

      const data =
        walletDoc.data() ||
        {};

      const transactions =
        Array.isArray(
          data.transactions
        )
          ? data.transactions
          : [];

      const alreadyRefunded =
        transactions.some(
          (txn) =>
            txn.id ===
            `${reference}_refund`
        );

      if (
        alreadyRefunded
      ) {
        return;
      }

      const updatedTransactions =
        transactions.map(
          (txn) =>
            txn.id ===
            reference
              ? {
                  ...txn,
                  status:
                    "failed",
                }
              : txn
        );

      updatedTransactions.push({
        id: `${reference}_refund`,
        type: "credit",
        title: `Refund: Airtime Purchase Failed (${phone || ""})`,
        amount:
          Number(amount),
        timestamp:
          Date.now(),
        status:
          "refunded",
        provider:
          "monnify",
        reference,
      });

      transaction.update(
        walletRef,
        {
          balance:
            Number(
              data.balance ||
                0
            ) +
            Number(amount),
          transactions:
            updatedTransactions,
        }
      );
    }
  );

  await sendNotification(
    userId,
    "Airtime purchase failed",
    `₦${amount} has been refunded to your wallet.`,
    "airtime"
  );

  await firestoreTransactionRecord(
    userId,
    reference,
    {
      status:
        "refunded",
      refundAmount:
        Number(amount),
      refundReason:
        reason,
      timestamp:
        Date.now(),
    }
  );
}

// ============================================================
// TRANSACTION RECORD HELPER
// ============================================================

async function firestoreTransactionRecord(
  userId,
  reference,
  data
) {
  if (
    !userId ||
    !reference
  ) {
    return;
  }

  await admin
    .firestore()
    .collection("users")
    .doc(userId)
    .collection("transactions")
    .doc(reference)
    .set(
      {
        type: "airtime",
        provider:
          "monnify",
        reference,
        ...data,
      },
      {
        merge: true,
      }
    );
}

// ============================================================
// LEGACY CONTROLLERS
// ============================================================

exports.buyAirtimeController = (
  req,
  res
) => {
  res.json({
    message:
      "Legacy Airtime purchase endpoint is not used. Use wallet/pay-airtime.",
  });
};

exports.queryAirtimeController = (
  req,
  res
) => {
  res.json({
    message:
      "Legacy Airtime query endpoint is not used. Use Monnify Bills requery.",
  });
};

exports.cancelAirtimeController = (
  req,
  res
) => {
  res.json({
    message:
      "Legacy Airtime cancellation endpoint is not supported.",
  });
};