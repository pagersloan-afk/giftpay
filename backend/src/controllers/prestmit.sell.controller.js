const admin = require("firebase-admin");

const PrestmitSellService = require("../services/prestmit.sell.service");

const {
  createLocalSellTransaction,
  findSellTransactionByReference,
  processPrestmitSell,
} = require("../services/prestmit.sell.processor");

const db = admin.firestore();

/**
 * Require an authenticated Firebase user.
 */
async function requireFirebaseUser(req) {
  if (req.user?.uid) {
    return req.user;
  }

  const authorization =
    req.headers.authorization || "";

  if (!authorization.startsWith("Bearer ")) {
    throw new Error(
      "Authentication required"
    );
  }

  const idToken =
    authorization.substring(7);

  return admin
    .auth()
    .verifyIdToken(idToken);
}

/**
 * GET /rates
 */
exports.getSellRates = async (req, res) => {
  try {
    await requireFirebaseUser(req);

    const result =
      await PrestmitSellService.getSellRateCalculatorData();

    return res.status(200).json({
      status: true,
      data: result,
    });
  } catch (error) {
    console.error(
      "[PRESTMIT SELL] Get rates error:",
      error.message
    );

    return res.status(
      error.status === 401 ? 401 : 500
    ).json({
      status: false,
      message:
        error.message ||
        "Unable to retrieve sell rates",
    });
  }
};

/**
 * GET /payout-methods
 */
exports.getSellPayoutMethods = async (
  req,
  res
) => {
  try {
    await requireFirebaseUser(req);

    const result =
      await PrestmitSellService.getSellPayoutMethods();

    return res.status(200).json({
      status: true,
      data: result,
    });
  } catch (error) {
    console.error(
      "[PRESTMIT SELL] Get payout methods error:",
      error.message
    );

    return res.status(500).json({
      status: false,
      message:
        error.message ||
        "Unable to retrieve payout methods",
    });
  }
};

/**
 * GET /categories
 */
exports.getSellGiftcardCategories = async (
  req,
  res
) => {
  try {
    await requireFirebaseUser(req);

    const result =
      await PrestmitSellService.getSellGiftcardCategories();

    return res.status(200).json({
      status: true,
      data: result,
    });
  } catch (error) {
    console.error(
      "[PRESTMIT SELL] Get categories error:",
      error.message
    );

    return res.status(500).json({
      status: false,
      message:
        error.message ||
        "Unable to retrieve gift card categories",
    });
  }
};

/**
 * GET /subcategories
 */
exports.getSellGiftcardSubcategories =
  async (req, res) => {
    try {
      await requireFirebaseUser(req);

      const result =
        await PrestmitSellService.getSellGiftcardSubcategories(
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

      return res.status(500).json({
        status: false,
        message:
          error.message ||
          "Unable to retrieve gift card subcategories",
      });
    }
  };

/**
 * GET /filters
 */
exports.getSellGiftcardFilters =
  async (req, res) => {
    try {
      await requireFirebaseUser(req);

      const result =
        await PrestmitSellService.getSellGiftcardFilters(
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

      return res.status(500).json({
        status: false,
        message:
          error.message ||
          "Unable to retrieve gift card filters",
      });
    }
  };

/**
 * GET /countries
 */
exports.getSellGiftcardCountries =
  async (req, res) => {
    try {
      await requireFirebaseUser(req);

      const result =
        await PrestmitSellService.getSellGiftcardCountries();

      return res.status(200).json({
        status: true,
        data: result,
      });
    } catch (error) {
      console.error(
        "[PRESTMIT SELL] Get countries error:",
        error.message
      );

      return res.status(500).json({
        status: false,
        message:
          error.message ||
          "Unable to retrieve gift card countries",
      });
    }
  };

/**
 * POST /create
 *
 * multipart/form-data
 *
 * Fields:
 * - giftcard_id
 * - amount
 * - payoutMethod
 * - comments
 * - uniqueIdentifier
 *
 * Files:
 * - attachments[]
 */
exports.createSell = async (req, res) => {
  try {
    const user =
      await requireFirebaseUser(req);

    const {
      giftcard_id,
      amount,
      payoutMethod,
      comments,
      uniqueIdentifier,
      giftCardName,
      brand,
      country,
      cardType,
      rate,
      expectedPayout,
    } = req.body;

    if (
      giftcard_id === undefined ||
      giftcard_id === null ||
      giftcard_id === ""
    ) {
      return res.status(400).json({
        status: false,
        message: "giftcard_id is required",
      });
    }

    if (
      amount === undefined ||
      amount === null ||
      amount === ""
    ) {
      return res.status(400).json({
        status: false,
        message: "amount is required",
      });
    }

    if (!Number.isFinite(Number(amount))) {
      return res.status(400).json({
        status: false,
        message: "amount must be a valid number",
      });
    }

    if (!payoutMethod) {
      return res.status(400).json({
        status: false,
        message: "payoutMethod is required",
      });
    }

    const files =
      Array.isArray(req.files)
        ? req.files
        : [];

    /**
     * Physical cards require attachments.
     *
     * E-code cards can submit without attachments
     * and place the code in comments.
     */
    const normalizedCardType =
      String(cardType || "")
        .trim()
        .toLowerCase();

    const isEcode =
      normalizedCardType === "ecode" ||
      normalizedCardType === "e-code" ||
      normalizedCardType === "digital";

    if (!isEcode && files.length === 0) {
      return res.status(400).json({
        status: false,
        message:
          "At least one gift card image is required for physical cards",
      });
    }

    if (
      isEcode &&
      (!comments ||
        String(comments).trim().length === 0)
    ) {
      return res.status(400).json({
        status: false,
        message:
          "Gift card code must be provided in comments for e-code cards",
      });
    }

    /**
     * Submit directly to Prestmit.
     */
    const providerResponse =
      await PrestmitSellService.createSellTransaction(
        {
          giftcard_id,
          amount,
          payoutMethod,
          comments,
          uniqueIdentifier,
          files,
        }
      );

    const trade =
      providerResponse?.trade ||
      providerResponse?.data?.trade ||
      providerResponse?.data;

    if (!trade?.reference) {
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

    /**
     * Store the local transaction immediately as PENDING.
     */
    const localTransaction =
      await createLocalSellTransaction({
        userId: user.uid,

        providerTrade: trade,

        giftcardId: giftcard_id,

        giftCardName:
          giftCardName ||
          trade.giftcard?.name,

        brand:
          brand ||
          trade.category?.name,

        country,

        cardType:
          cardType ||
          trade.giftcard?.form,

        amount,

        rate:
          rate ||
          trade.rate ||
          trade.giftcard?.rate,

        expectedPayout:
          expectedPayout ||
          trade.totalAmount,

        payoutMethod,

        comments,

        uniqueIdentifier,
      });

    return res.status(201).json({
      status: true,
      message:
        "Gift card sell trade successfully started.",
      transaction: {
        id: localTransaction.id,
        reference:
          localTransaction.providerReference,
        status:
          localTransaction.status,
        providerStatus:
          localTransaction.providerStatus,
        amount:
          localTransaction.amount,
        rate:
          localTransaction.rate,
        expectedPayout:
          localTransaction.expectedPayout,
        payoutMethod:
          localTransaction.payoutMethod,
        createdAt:
          localTransaction.createdAt,
      },
      provider: providerResponse,
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

    return res.status(
      error.status &&
        Number(error.status) >= 400 &&
        Number(error.status) < 600
        ? Number(error.status)
        : 500
    ).json({
      status: false,
      message:
        error.message ||
        "Unable to create gift card sell transaction",
    });
  }
};

/**
 * GET /history
 */
exports.getSellHistory = async (
  req,
  res
) => {
  try {
    const user =
      await requireFirebaseUser(req);

    const snapshot =
      await db
        .collection("prestmitSellTransactions")
        .where("userId", "==", user.uid)
        .orderBy("createdAt", "desc")
        .limit(100)
        .get();

    const transactions =
      snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

    return res.status(200).json({
      status: true,
      transactions,
    });
  } catch (error) {
    console.error(
      "[PRESTMIT SELL] History error:",
      error.message
    );

    return res.status(500).json({
      status: false,
      message:
        error.message ||
        "Unable to retrieve sell history",
    });
  }
};

/**
 * GET /:reference
 */
exports.getSellTransaction = async (
  req,
  res
) => {
  try {
    const user =
      await requireFirebaseUser(req);

    const reference =
      req.params.reference;

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
      localTransaction.data.userId !==
      user.uid
    ) {
      return res.status(403).json({
        status: false,
        message:
          "You are not authorized to view this transaction",
      });
    }

    return res.status(200).json({
      status: true,
      transaction: {
        id: localTransaction.ref.id,
        ...localTransaction.data,
      },
    });
  } catch (error) {
    console.error(
      "[PRESTMIT SELL] Get transaction error:",
      error.message
    );

    return res.status(500).json({
      status: false,
      message:
        error.message ||
        "Unable to retrieve sell transaction",
    });
  }
};

/**
 * POST /requery/:reference
 */
exports.requerySell = async (
  req,
  res
) => {
  try {
    const user =
      await requireFirebaseUser(req);

    const reference =
      req.params.reference;

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
      localTransaction.data.userId !==
      user.uid
    ) {
      return res.status(403).json({
        status: false,
        message:
          "You are not authorized to requery this transaction",
      });
    }

    const result =
      await processPrestmitSell(
        reference
      );

    return res.status(200).json({
      status: true,
      message:
        "Sell transaction status refreshed",
      result,
    });
  } catch (error) {
    console.error(
      "[PRESTMIT SELL] Requery error:",
      error.message
    );

    return res.status(500).json({
      status: false,
      message:
        error.message ||
        "Unable to requery sell transaction",
    });
  }
};