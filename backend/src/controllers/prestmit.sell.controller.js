const admin = require("firebase-admin");

const PrestmitSellService = require("../services/prestmit.sell.service");

const {
  createLocalSellTransaction,
  findSellTransactionByReference,
  processPrestmitSell,
} = require("../services/prestmit.sell.processor");

const db = admin.firestore();
const FeeEngine = require("../../core/fees/fee_engine");

const COLLECTION = "prestmitSellTransactions";

// ============================================================
// HELPERS
// ============================================================

/**
 * Require an authenticated Firebase user.
 *
 * Supports:
 * 1. req.user.uid if another authentication middleware already ran.
 * 2. Authorization: Bearer <Firebase ID token>
 */
async function requireFirebaseUser(req) {
  if (req.user?.uid) {
    return req.user;
  }

  const authorization =
    req.headers.authorization || "";

  if (
    !authorization ||
    !authorization.startsWith("Bearer ")
  ) {
    const error = new Error(
      "Authentication required"
    );

    error.status = 401;

    throw error;
  }

  const idToken =
    authorization.substring(7).trim();

  if (!idToken) {
    const error = new Error(
      "Firebase ID token is missing"
    );

    error.status = 401;

    throw error;
  }

  try {
    return await admin
      .auth()
      .verifyIdToken(idToken);
  } catch (error) {
    const authError = new Error(
      "Invalid or expired authentication token"
    );

    authError.status = 401;
    authError.cause = error;

    throw authError;
  }
}

/**
 * Determine whether a Prestmit gift card form is an E-code.
 *
 * Prestmit may return:
 *
 *   Ecode
 *   E-code
 *   E Code
 *   e_code
 *   Digital
 */
function isEcodeForm(value) {
  const normalized = String(value || "")
    .trim()
    .toLowerCase()
    .replace(/[-_\s]/g, "");

  return (
    normalized === "ecode" ||
    normalized === "digital" ||
    normalized.includes("ecode")
  );
}

/**
 * Convert Firestore values into JSON-safe values.
 *
 * Flutter receives Timestamp values as ISO strings.
 */
function serializeFirestoreValue(value) {
  if (
    value === null ||
    value === undefined
  ) {
    return value;
  }

  /**
   * Firestore Timestamp.
   */
  if (
    value &&
    typeof value.toDate === "function"
  ) {
    return value
      .toDate()
      .toISOString();
  }

  /**
   * Date.
   */
  if (value instanceof Date) {
    return value.toISOString();
  }

  /**
   * Array.
   */
  if (Array.isArray(value)) {
    return value.map(
      serializeFirestoreValue
    );
  }

  /**
   * Object.
   */
  if (
    typeof value === "object"
  ) {
    const result = {};

    for (
      const [key, childValue] of Object.entries(
        value
      )
    ) {
      result[key] =
        serializeFirestoreValue(
          childValue
        );
    }

    return result;
  }

  return value;
}

/**
 * Serialize a Firestore document.
 */
function serializeTransaction(
  id,
  data
) {
  return serializeFirestoreValue({
    id,
    ...data,
  });
}

/**
 * Return a provider error status if valid.
 */
function getErrorStatus(error) {
  const status =
    Number(error?.status);

  if (
    Number.isInteger(status) &&
    status >= 400 &&
    status <= 599
  ) {
    return status;
  }

  return 500;
}


// ============================================================
// SELL CUSTOMER RATE
// ============================================================

const SELL_MARGIN_PERCENT = 5;

function addCustomerSellRates(result) {
  if (!result || typeof result !== "object" || !Array.isArray(result.sellableGiftcards)) {
    return result;
  }

  return {
    ...result,
    sellableGiftcards: result.sellableGiftcards.map((giftcard) => {
      const providerRate = Number(giftcard?.rate);
      const pricing = FeeEngine.giftCardSellRate(
        Number.isFinite(providerRate) ? providerRate : 0,
        SELL_MARGIN_PERCENT
      );

      return {
        ...giftcard,
        rate: pricing.customerRate,
        providerRate: pricing.providerRate,
        customerRate: pricing.customerRate,
        marginPercent: pricing.marginPercent,
      };
    }),
  };
}

// ============================================================
// SELL RATES
// ============================================================

/**
 * GET /rates
 */
exports.getSellRates = async (
  req,
  res
) => {
  try {
    await requireFirebaseUser(req);

    const providerResult =
      await PrestmitSellService
        .getSellRateCalculatorData();

    const result =
      addCustomerSellRates(providerResult);

    return res.status(200).json({
      status: true,
      data: result,
      pricing: { sellMarginPercent: SELL_MARGIN_PERCENT },
    });
  } catch (error) {
    console.error(
      "[PRESTMIT SELL] Get rates error:",
      error.message
    );

    return res
      .status(getErrorStatus(error))
      .json({
        status: false,
        message:
          error.message ||
          "Unable to retrieve sell rates",
      });
  }
};

// ============================================================
// PAYOUT METHODS
// ============================================================

/**
 * GET /payout-methods
 */
exports.getSellPayoutMethods =
  async (req, res) => {
    try {
      await requireFirebaseUser(req);

      const result =
        await PrestmitSellService
          .getSellPayoutMethods();

      return res.status(200).json({
        status: true,
        data: result,
      });
    } catch (error) {
      console.error(
        "[PRESTMIT SELL] Get payout methods error:",
        error.message
      );

      return res
        .status(getErrorStatus(error))
        .json({
          status: false,
          message:
            error.message ||
            "Unable to retrieve payout methods",
        });
    }
  };

// ============================================================
// CATEGORIES
// ============================================================

/**
 * GET /categories
 */
exports.getSellGiftcardCategories =
  async (req, res) => {
    try {
      await requireFirebaseUser(req);

      const result =
        await PrestmitSellService
          .getSellGiftcardCategories(
            req.query
          );

      return res.status(200).json({
        status: true,
        data: result,
      });
    } catch (error) {
      console.error(
        "[PRESTMIT SELL] Get categories error:",
        error.message
      );

      return res
        .status(getErrorStatus(error))
        .json({
          status: false,
          message:
            error.message ||
            "Unable to retrieve gift card categories",
        });
    }
  };

// ============================================================
// SUBCATEGORIES
// ============================================================

/**
 * GET /subcategories
 */
exports.getSellGiftcardSubcategories =
  async (req, res) => {
    try {
      await requireFirebaseUser(req);

      const result =
        await PrestmitSellService
          .getSellGiftcardSubcategories(
            req.query
          );

      return res.status(200).json({
        status: true,
        data: result,
      });
    } catch (error) {
      console.error(
        "[PRESTMIT SELL] Get subcategories error:",
        error.message
      );

      return res
        .status(getErrorStatus(error))
        .json({
          status: false,
          message:
            error.message ||
            "Unable to retrieve gift card subcategories",
        });
    }
  };

// ============================================================
// FILTERS
// ============================================================

/**
 * GET /filters
 */
exports.getSellGiftcardFilters =
  async (req, res) => {
    try {
      await requireFirebaseUser(req);

      const result =
        await PrestmitSellService
          .getSellGiftcardFilters(
            req.query
          );

      return res.status(200).json({
        status: true,
        data: result,
      });
    } catch (error) {
      console.error(
        "[PRESTMIT SELL] Get filters error:",
        error.message
      );

      return res
        .status(getErrorStatus(error))
        .json({
          status: false,
          message:
            error.message ||
            "Unable to retrieve gift card filters",
        });
    }
  };

// ============================================================
// COUNTRIES
// ============================================================

/**
 * GET /countries
 */
exports.getSellGiftcardCountries =
  async (req, res) => {
    try {
      await requireFirebaseUser(req);

      const result =
        await PrestmitSellService
          .getSellGiftcardCountries(
            req.query
          );

      return res.status(200).json({
        status: true,
        data: result,
      });
    } catch (error) {
      console.error(
        "[PRESTMIT SELL] Get countries error:",
        error.message
      );

      return res
        .status(getErrorStatus(error))
        .json({
          status: false,
          message:
            error.message ||
            "Unable to retrieve gift card countries",
        });
    }
  };

// ============================================================
// CREATE SELL TRANSACTION
// ============================================================

/**
 * POST /create
 *
 * multipart/form-data
 *
 * Required:
 * - giftcard_id
 * - amount
 * - payoutMethod
 *
 * Physical cards:
 * - attachments[]
 *
 * E-codes:
 * - comments
 *
 * Optional:
 * - uniqueIdentifier
 * - payoutAddress
 * - promoCode
 *
 * Local metadata:
 * - giftCardName
 * - brand
 * - country
 * - cardType
 * - rate
 * - expectedPayout
 */
exports.createSell = async (
  req,
  res
) => {
  try {
    const user =
      await requireFirebaseUser(req);

    const {
      giftcard_id,
      amount,
      payoutMethod,
      comments,
      uniqueIdentifier,

      payoutAddress,
      promoCode,

      // Local/UI metadata only.
      giftCardName,
      brand,
      country,
      cardType,
      rate,
      expectedPayout,
    } = req.body || {};

    // ==========================================================
    // GIFTCARD ID
    // ==========================================================

    if (
      giftcard_id === undefined ||
      giftcard_id === null ||
      giftcard_id === ""
    ) {
      return res.status(400).json({
        status: false,
        message:
          "giftcard_id is required",
      });
    }

    const normalizedGiftcardId =
      Number(giftcard_id);

    if (
      !Number.isInteger(
        normalizedGiftcardId
      ) ||
      normalizedGiftcardId <= 0
    ) {
      return res.status(400).json({
        status: false,
        message:
          "giftcard_id must be a valid positive integer",
      });
    }

    // ==========================================================
    // AMOUNT
    // ==========================================================

    if (
      amount === undefined ||
      amount === null ||
      amount === ""
    ) {
      return res.status(400).json({
        status: false,
        message:
          "amount is required",
      });
    }

    const normalizedAmount =
      Number(amount);

    if (
      !Number.isFinite(
        normalizedAmount
      ) ||
      normalizedAmount <= 0
    ) {
      return res.status(400).json({
        status: false,
        message:
          "amount must be a valid positive number",
      });
    }

    // ==========================================================
    // PAYOUT METHOD
    // ==========================================================

    if (
      payoutMethod === undefined ||
      payoutMethod === null ||
      String(payoutMethod).trim() === ""
    ) {
      return res.status(400).json({
        status: false,
        message:
          "payoutMethod is required",
      });
    }

    const normalizedPayoutMethod =
      String(
        payoutMethod
      ).trim();

    // ==========================================================
    // FILES
    // ==========================================================

    const files =
      Array.isArray(req.files)
        ? req.files
        : [];

    // ==========================================================
    // E-CODE / PHYSICAL DETECTION
    // ==========================================================

    const normalizedCardType =
      String(cardType || "").trim();

    const isEcode =
      isEcodeForm(
        normalizedCardType
      );

    // ==========================================================
    // PHYSICAL CARD VALIDATION
    // ==========================================================

    if (
      !isEcode &&
      files.length === 0
    ) {
      return res.status(400).json({
        status: false,
        message:
          "At least one gift card image is required for physical cards",
      });
    }

    // ==========================================================
    // E-CODE VALIDATION
    // ==========================================================

    const normalizedComments =
      comments !== undefined &&
      comments !== null
        ? String(comments).trim()
        : "";

    if (
      isEcode &&
      !normalizedComments
    ) {
      return res.status(400).json({
        status: false,
        message:
          "Gift card code must be provided in comments for e-code cards",
      });
    }

    // ==========================================================
    // E-CODE MUST NOT CONTAIN ATTACHMENTS
    // ==========================================================

    if (
      isEcode &&
      files.length > 0
    ) {
      return res.status(400).json({
        status: false,
        message:
          "E-code gift cards must be submitted as a code in comments and must not include images",
      });
    }

    // ==========================================================
    // SUBMIT TO PRESTMIT
    // ==========================================================

    /**
     * IMPORTANT:
     *
     * Only actual Prestmit SELL API fields are passed here.
     *
     * The following Flutter/UI fields are NOT forwarded:
     *
     * - brand
     * - country
     * - cardType
     * - rate
     * - expectedPayout
     *
     * They are only stored locally.
     */
    const providerResponse =
      await PrestmitSellService
        .createSellTransaction({
          giftcard_id:
            normalizedGiftcardId,

          amount:
            normalizedAmount,

          payoutMethod:
            normalizedPayoutMethod,

          comments:
            normalizedComments
              ? normalizedComments
              : undefined,

          uniqueIdentifier:
            uniqueIdentifier !==
              undefined &&
            uniqueIdentifier !== null
              ? String(
                  uniqueIdentifier
                )
              : undefined,

          payoutAddress:
            payoutAddress !==
              undefined &&
            payoutAddress !== null
              ? String(
                  payoutAddress
                )
              : undefined,

          promoCode:
            promoCode !== undefined &&
            promoCode !== null
              ? String(
                  promoCode
                )
              : undefined,

          files,
        });

    // ==========================================================
    // EXTRACT PROVIDER TRADE
    // ==========================================================

    const trade =
      providerResponse?.trade ||
      providerResponse?.data?.trade ||
      providerResponse?.data;

    if (
      !trade?.reference
    ) {
      console.error(
        "[PRESTMIT SELL] Invalid Prestmit create response:",
        JSON.stringify(
          providerResponse,
          null,
          2
        )
      );

      return res.status(502).json({
        status: false,
        message:
          "Prestmit did not return a valid sell transaction reference",
      });
    }

    // ==========================================================
    // CREATE LOCAL TRANSACTION
    // ==========================================================

    /**
     * The transaction starts as PENDING.
     *
     * Wallet settlement must NOT happen here.
     *
     * Wallet credit only occurs after Prestmit reports
     * the SELL transaction as COMPLETED.
     */
    // Prestmit's actual payout is authoritative. Do not trust the Flutter estimate.
    const providerExpectedPayout =
      Number(
        trade.totalAmount ??
        trade.payoutTotal ??
        trade.payoutAmount ??
        expectedPayout ??
        0
      );

    const sellPricing =
      Number.isFinite(providerExpectedPayout) && providerExpectedPayout > 0
        ? FeeEngine.giftCardSell(providerExpectedPayout)
        : {
            providerPayout: 0,
            giftPayMargin: 0,
            customerPayout: 0,
          };

    const localTransaction =
      await createLocalSellTransaction({
        userId:
          user.uid,

        providerTrade:
          trade,

        giftcardId:
          normalizedGiftcardId,

        giftCardName:
          giftCardName ||
          trade.giftcard?.name,

        brand:
          brand ||
          trade.category?.name,

        country:
          country || null,

        cardType:
          cardType ||
          trade.giftcard?.form,

        amount:
          normalizedAmount,

        rate:
          normalizedAmount > 0 && sellPricing.customerPayout > 0
            ? Math.round((sellPricing.customerPayout / normalizedAmount) * 100) / 100
            : Number(rate || trade.rate || trade.giftcard?.rate || 0),

        expectedPayout:
          sellPricing.customerPayout,

        providerExpectedPayout:
          sellPricing.providerPayout,

        payoutMethod:
          normalizedPayoutMethod,

        comments:
          normalizedComments ||
          null,

        uniqueIdentifier:
          uniqueIdentifier ||
          null,
      });

    // ==========================================================
    // SERIALIZE TRANSACTION
    // ==========================================================

    const transaction =
      serializeTransaction(
        localTransaction.id,
        localTransaction
      );

    return res.status(201).json({
      status: true,

      message:
        "Gift card sell trade successfully started.",

      transaction: {
        id:
          transaction.id,

        reference:
          transaction.providerReference,

        status:
          transaction.status,

        providerStatus:
          transaction.providerStatus,

        amount:
          transaction.amount,

        rate:
          transaction.rate,

        expectedPayout:
          transaction.expectedPayout,

        payoutMethod:
          transaction.payoutMethod,

        createdAt:
          transaction.createdAt,
      },

      pricing: {
        providerPayout: sellPricing.providerPayout,
        giftPayMargin: sellPricing.giftPayMargin,
        customerPayout: sellPricing.customerPayout,
      },

      provider:
        providerResponse,
    });
  } catch (error) {
    console.error(
      "[PRESTMIT SELL] Create sell error:",
      error.message
    );

    if (error.response) {
      console.error(
        "[PRESTMIT SELL] Provider response:",
        JSON.stringify(
          error.response,
          null,
          2
        )
      );
    }

    return res
      .status(
        getErrorStatus(error)
      )
      .json({
        status: false,
        message:
          error.message ||
          "Unable to create gift card sell transaction",
      });
  }
};

// ============================================================
// HISTORY
// ============================================================

/**
 * GET /history
 *
 * Returns only the authenticated user's SELL transactions.
 */
exports.getSellHistory =
  async (req, res) => {
    try {
      const user =
        await requireFirebaseUser(
          req
        );

      const snapshot =
        await db
          .collection(COLLECTION)
          .where(
            "userId",
            "==",
            user.uid
          )
          .limit(500)
          .get();

      const transactions =
        snapshot.docs
          .map((doc) =>
            serializeTransaction(
              doc.id,
              doc.data()
            )
          )
          .sort(
            (a, b) => {
              const aTime =
                a.createdAt
                  ? new Date(
                      a.createdAt
                    ).getTime()
                  : 0;

              const bTime =
                b.createdAt
                  ? new Date(
                      b.createdAt
                    ).getTime()
                  : 0;

              return bTime - aTime;
            }
          )
          .slice(0, 100);

      return res.status(200).json({
        status: true,
        transactions,
      });
    } catch (error) {
      console.error(
        "[PRESTMIT SELL] History error:",
        error.message
      );

      return res
        .status(
          getErrorStatus(error)
        )
        .json({
          status: false,
          message:
            error.message ||
            "Unable to retrieve sell history",
        });
    }
  };

// ============================================================
// SINGLE TRANSACTION
// ============================================================

/**
 * GET /:reference
 *
 * Retrieve one local SELL transaction.
 */
exports.getSellTransaction =
  async (req, res) => {
    try {
      const user =
        await requireFirebaseUser(
          req
        );

      const reference =
        String(
          req.params.reference ||
            ""
        ).trim();

      if (!reference) {
        return res.status(400).json({
          status: false,
          message:
            "Sell transaction reference is required",
        });
      }

      const localTransaction =
        await findSellTransactionByReference(
          reference
        );

      if (!localTransaction) {
        return res.status(404).json({
          status: false,
          message:
            "Sell transaction not found",
        });
      }

      if (
        localTransaction.data
          ?.userId !== user.uid
      ) {
        return res.status(403).json({
          status: false,
          message:
            "You are not authorized to view this transaction",
        });
      }

      return res.status(200).json({
        status: true,

        transaction:
          serializeTransaction(
            localTransaction.id,
            localTransaction.data
          ),
      });
    } catch (error) {
      console.error(
        "[PRESTMIT SELL] Get transaction error:",
        error.message
      );

      return res
        .status(
          getErrorStatus(error)
        )
        .json({
          status: false,
          message:
            error.message ||
            "Unable to retrieve sell transaction",
        });
    }
  };

// ============================================================
// REQUERY
// ============================================================

/**
 * POST /requery/:reference
 *
 * Manually refresh the transaction from Prestmit.
 */
exports.requerySell =
  async (req, res) => {
    try {
      const user =
        await requireFirebaseUser(
          req
        );

      const reference =
        String(
          req.params.reference ||
            ""
        ).trim();

      if (!reference) {
        return res.status(400).json({
          status: false,
          message:
            "Sell transaction reference is required",
        });
      }

      // ========================================================
      // VERIFY OWNERSHIP
      // ========================================================

      const localTransaction =
        await findSellTransactionByReference(
          reference
        );

      if (!localTransaction) {
        return res.status(404).json({
          status: false,
          message:
            "Sell transaction not found",
        });
      }

      if (
        localTransaction.data
          ?.userId !== user.uid
      ) {
        return res.status(403).json({
          status: false,
          message:
            "You are not authorized to requery this transaction",
        });
      }

      // ========================================================
      // PROCESS LATEST PROVIDER STATE
      // ========================================================

      const result =
        await processPrestmitSell(
          reference
        );

      // ========================================================
      // READ UPDATED TRANSACTION
      // ========================================================

      const updatedTransaction =
        await findSellTransactionByReference(
          reference
        );

      return res.status(200).json({
        status: true,

        message:
          "Sell transaction status refreshed",

        result,

        transaction:
          updatedTransaction
            ? serializeTransaction(
                updatedTransaction.id,
                updatedTransaction.data
              )
            : null,
      });
    } catch (error) {
      console.error(
        "[PRESTMIT SELL] Requery error:",
        error.message
      );

      return res
        .status(
          getErrorStatus(error)
        )
        .json({
          status: false,
          message:
            error.message ||
            "Unable to requery sell transaction",
        });
    }
  };

// ============================================================
// EXPORTS
// ============================================================
//
// Keep this at the end. It preserves all exports above.
// Do not replace it with a new object containing only helper
// functions, otherwise Express will receive undefined handlers.
// ============================================================

module.exports = exports;
