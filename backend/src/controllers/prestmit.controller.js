const PrestmitService = require("../services/prestmit.service");
const {
  processPrestmitPurchase,
  adoptExistingPrestmitPurchase,
} = require("../services/prestmit.purchase.processor");
const admin = require("firebase-admin");

function getBearerToken(req) {
  const header = req.get("authorization") || "";
  if (!header.startsWith("Bearer ")) return null;
  return header.substring(7).trim();
}

async function requireFirebaseUser(req, res) {
  if (req.user?.uid) {
    return req.user;
  }

  const token = getBearerToken(req);

  if (!token) {
    res.status(401).json({
      status: false,
      message: "Authentication required.",
    });
    return null;
  }

  try {
    const decoded = await admin.auth().verifyIdToken(token);
    req.user = decoded;
    return decoded;
  } catch (error) {
    console.error(
      "Prestmit Firebase authentication error:",
      error.message
    );

    res.status(401).json({
      status: false,
      message: "Invalid or expired authentication token.",
    });
    return null;
  }
}

/**
 * GET /api/prestmit/catalog
 */
exports.getCatalog = async (req, res) => {
  try {
    const {
      currencyCode,
      page = 1,
      perPage = 25,
    } = req.query;

    const result =
      await PrestmitService.fetchBuyableGiftCards({
        currencyCode,
        page: Number(page),
        perPage: Number(perPage),
      });

    return res.status(200).json({
      status: true,
      message: "Prestmit gift-card catalog fetched successfully",
      data: result,
    });
  } catch (error) {
    console.error("Prestmit catalog error:", error.message);

    return res.status(502).json({
      status: false,
      message:
        error.message || "Unable to fetch Prestmit catalog",
    });
  }
};

/**
 * GET /api/prestmit/configuration
 */
exports.getConfiguration = async (req, res) => {
  try {
    const result =
      await PrestmitService.getBuyConfiguration();

    return res.status(200).json({
      status: true,
      message: "Prestmit configuration fetched successfully",
      data: result,
    });
  } catch (error) {
    console.error(
      "Prestmit configuration error:",
      error.message
    );

    return res.status(502).json({
      status: false,
      message:
        error.message ||
        "Unable to fetch Prestmit configuration",
    });
  }
};

/**
 * POST /api/prestmit/check-availability
 */
exports.checkAvailability = async (req, res) => {
  try {
    const result =
      await PrestmitService.checkAvailability(req.body);

    return res.status(200).json({
      status: true,
      message:
        "Prestmit gift-card availability checked successfully",
      data: result,
    });
  } catch (error) {
    console.error(
      "Prestmit availability error:",
      error.message
    );

    return res.status(502).json({
      status: false,
      message:
        error.message ||
        "Unable to check gift-card availability",
    });
  }
};

/**
 * POST /api/prestmit/calculate-payment
 */
exports.calculatePayment = async (req, res) => {
  try {
    const result =
      await PrestmitService.calculatePayment(req.body);

    return res.status(200).json({
      status: true,
      message:
        "Prestmit gift-card payment calculated successfully",
      data: result,
    });
  } catch (error) {
    console.error(
      "Prestmit payment calculation error:",
      error.message
    );

    return res.status(502).json({
      status: false,
      message:
        error.message ||
        "Unable to calculate gift-card payment",
    });
  }
};

/**
 * POST /api/prestmit/buy
 *
 * Creates the provider transaction and immediately creates the
 * GiftPay-side purchase record linked to the authenticated user.
 *
 * The wallet is NOT debited here.
 */
exports.createBuyTransaction = async (req, res) => {
  try {
    const user = await requireFirebaseUser(req, res);
    if (!user) return;

    const {
      giftCardSKU,
      price,
      quantity,
      paymentMethod,
      uniqueIdentifier,
      ["2fa_code"]: twoFactorCode,
    } = req.body;

    if (
      giftCardSKU === undefined ||
      price === undefined ||
      quantity === undefined ||
      paymentMethod === undefined ||
      uniqueIdentifier === undefined
    ) {
      return res.status(400).json({
        status: false,
        message:
          "giftCardSKU, price, quantity, paymentMethod and uniqueIdentifier are required",
      });
    }

    const currentAccountPIN =
      process.env.PRESTMIT_SANDBOX_PIN;

    if (
      !currentAccountPIN ||
      !currentAccountPIN.trim()
    ) {
      console.error(
        "Prestmit account PIN is not configured."
      );

      return res.status(500).json({
        status: false,
        message:
          "Prestmit account configuration is incomplete.",
      });
    }

    const payload = {
      giftCardSKU,
      price,
      quantity,
      paymentMethod,
      uniqueIdentifier,
      currentAccountPIN: currentAccountPIN.trim(),
    };

    if (
      twoFactorCode !== undefined &&
      twoFactorCode !== null &&
      String(twoFactorCode).trim() !== ""
    ) {
      payload["2fa_code"] =
        String(twoFactorCode).trim();
    }

    const result =
      await PrestmitService.createBuyTransaction(payload);

    const providerData =
      result?.data &&
      typeof result.data === "object"
        ? result.data
        : result;

    const reference =
      providerData?.reference ||
      providerData?.transactionReference ||
      providerData?.transactionId;

    if (!reference) {
      throw new Error(
        "Prestmit did not return a transaction reference."
      );
    }

    const db = admin.firestore();
    const purchaseRef = db
      .collection("prestmitPurchases")
      .doc(String(reference));

    const giftCard = providerData?.giftCard || {};

    await purchaseRef.set(
      {
        userId: user.uid,
        reference: String(reference),
        giftCardSKU:
          giftCard.sku !== undefined
            ? Number(giftCard.sku)
            : Number(giftCardSKU),
        giftCardTitle:
          giftCard.title || "Gift Card",
        price: Number(price),
        quantity: Number(quantity),
        paymentMethod:
          providerData?.paymentMethod ||
          String(paymentMethod).toUpperCase(),
        uniqueIdentifier:
          providerData?.partnersApiIdentifier ||
          String(uniqueIdentifier),
        totalPaymentAmount: Number(
          providerData?.totalPaymentAmount || 0
        ),
        walletDebitAmount: Number(
          providerData?.totalPaymentAmount || 0
        ),
        providerStatus:
          providerData?.status || "PENDING",
        status: "PENDING",
        walletDebited: false,
        createdAt:
          admin.firestore.FieldValue.serverTimestamp(),
        updatedAt:
          admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    // IMPORTANT:
    // Do not wait only for a COMPLETED /create response.
    // Prestmit may return PENDING while the provider transaction
    // has already moved to COMPLETED in /history.
    let processing = null;

    try {
      processing =
        await processPrestmitPurchase(reference);
    } catch (processingError) {
      // The purchase record already exists, so the authenticated
      // requery endpoint can safely finish the transaction later.
      console.error(
        `Prestmit initial processing error for ${reference}:`,
        processingError.message
      );
    }

    const localPurchase =
      await purchaseRef.get();

    const localData =
      localPurchase.exists
        ? localPurchase.data()
        : {};

    return res.status(200).json({
      status: true,
      message:
        "Prestmit gift-card purchase created successfully",
      data: result,
      giftPayPurchase: {
        reference: String(reference),
        status:
          localData?.status ||
          processing?.status ||
          providerData?.status ||
          "PENDING",
        walletDebited:
          localData?.walletDebited === true,
      },
    });
  } catch (error) {
    console.error(
      "Prestmit create purchase error:",
      error.message
    );

    return res.status(502).json({
      status: false,
      message:
        error.message ||
        "Unable to create Prestmit gift-card purchase",
    });
  }
};

/**
 * POST /api/prestmit/requery/:reference
 *
 * Authenticated customer-facing status refresh.
 *
 * This is the Prestmit equivalent of the electricity requery flow.
 * It asks the existing processor to query Prestmit history and update
 * the GiftPay purchase record when Prestmit has completed the trade.
 */
exports.requeryPurchase = async (req, res) => {
  try {
    const user = await requireFirebaseUser(req, res);
    if (!user) return;

    const reference =
      String(req.params.reference || "").trim();

    if (!reference) {
      return res.status(400).json({
        status: false,
        message: "Reference is required.",
      });
    }

    const db = admin.firestore();

    const purchaseRef = db
      .collection("prestmitPurchases")
      .doc(reference);

    const purchaseSnap =
      await purchaseRef.get();

    if (
      !purchaseSnap.exists ||
      purchaseSnap.data()?.userId !== user.uid
    ) {
      return res.status(404).json({
        status: false,
        message: "Gift-card purchase not found.",
      });
    }

    const processed =
      await processPrestmitPurchase(reference);

    const latestSnap =
      await purchaseRef.get();

    const latest =
      latestSnap.exists
        ? latestSnap.data()
        : {};

    return res.status(200).json({
      status: true,
      message:
        "Prestmit purchase status refreshed successfully",
      data: {
        reference,
        status:
          latest.status ||
          processed?.status ||
          "PENDING",
        providerStatus:
          latest.providerStatus ||
          null,
        walletDebited:
          latest.walletDebited === true,
        cards:
          latest.cards || [],
      },
    });
  } catch (error) {
    console.error(
      "Prestmit purchase requery error:",
      error.message
    );

    return res.status(502).json({
      status: false,
      message:
        error.message ||
        "Unable to refresh Prestmit purchase status",
    });
  }
};

/**
 * GET /api/prestmit/codes/:reference
 *
 * Customer-facing route. It verifies that the reference belongs to
 * the authenticated Firebase user before returning provider data.
 */
exports.fetchGiftCardCodes = async (req, res) => {
  try {
    const user = await requireFirebaseUser(req, res);
    if (!user) return;

    const reference = String(req.params.reference || "").trim();

    const db = admin.firestore();
    const purchaseRef = db
      .collection("prestmitPurchases")
      .doc(reference);

    const purchaseSnap = await purchaseRef.get();

    if (
      !purchaseSnap.exists ||
      purchaseSnap.data()?.userId !== user.uid
    ) {
      return res.status(404).json({
        status: false,
        message: "Gift-card purchase not found.",
      });
    }

    const purchase = purchaseSnap.data() || {};

    if (purchase.status !== "COMPLETED") {
      return res.status(409).json({
        status: false,
        message: "Gift-card purchase is not completed yet.",
        data: {
          reference,
          status: purchase.status || "PENDING",
        },
      });
    }

    const result =
      await PrestmitService.fetchGiftCardCodes(reference);

    return res.status(200).json({
      status: true,
      message:
        "Prestmit gift-card codes fetched successfully",
      data: result,
    });
  } catch (error) {
    console.error(
      "Prestmit fetch codes error:",
      error.message
    );

    return res.status(502).json({
      status: false,
      message:
        error.message ||
        "Unable to fetch gift-card codes",
    });
  }
};

/**
 * GET /api/prestmit/history
 *
 * Customer-facing history is restricted to the authenticated user's
 * GiftPay purchase records.
 */
exports.getBuyHistory = async (req, res) => {
  try {
    const user = await requireFirebaseUser(req, res);
    if (!user) return;

    const {
      page = 1,
      perPage = 10,
      referenceOrID,
    } = req.query;

    const db = admin.firestore();

    if (referenceOrID) {
      const reference = String(referenceOrID).trim();
      const purchaseSnap = await db
        .collection("prestmitPurchases")
        .doc(reference)
        .get();

      if (
        !purchaseSnap.exists ||
        purchaseSnap.data()?.userId !== user.uid
      ) {
        return res.status(404).json({
          status: false,
          message: "Gift-card purchase not found.",
        });
      }

      const result =
        await PrestmitService.getBuyHistory({
          page: Number(page),
          perPage: Number(perPage),
          referenceOrID: reference,
        });

      return res.status(200).json({
        status: true,
        message:
          "Prestmit purchase history fetched successfully",
        data: result,
      });
    }

    const snapshot = await db
      .collection("prestmitPurchases")
      .where("userId", "==", user.uid)
      .get();

    const purchases = snapshot.docs
      .map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }))
      .sort((a, b) => {
        const aTime =
          a.createdAt?.toMillis?.() || 0;
        const bTime =
          b.createdAt?.toMillis?.() || 0;
        return bTime - aTime;
      });

    return res.status(200).json({
      status: true,
      message:
        "GiftPay gift-card purchase history fetched successfully",
      data: {
        data: purchases,
        meta: {
          current_page: 1,
          per_page: purchases.length,
          total: purchases.length,
        },
      },
    });
  } catch (error) {
    console.error(
      "Prestmit purchase history error:",
      error.message
    );

    return res.status(502).json({
      status: false,
      message:
        error.message ||
        "Unable to fetch Prestmit purchase history",
    });
  }
};

/**
 * POST /api/prestmit/reconcile/:reference
 *
 * ONE-TIME SANDBOX TEST HELPER.
 *
 * It adopts an already-completed Prestmit reference into the currently
 * authenticated GiftPay user and runs the same processor used by the
 * webhook. Disabled when NODE_ENV=production.
 */
exports.reconcileExistingPurchase = async (req, res) => {
  if (process.env.NODE_ENV === "production") {
    return res.status(404).json({
      status: false,
      message: "Not found",
    });
  }

  try {
    const user = await requireFirebaseUser(req, res);
    if (!user) return;

    const reference =
      String(req.params.reference || "").trim();

    if (!reference) {
      return res.status(400).json({
        status: false,
        message: "Reference is required.",
      });
    }

    const adopted =
      await adoptExistingPrestmitPurchase(
        reference,
        user.uid
      );

    const processed =
      await processPrestmitPurchase(reference);

    return res.status(200).json({
      status: true,
      message:
        "Existing Prestmit transaction reconciled successfully.",
      data: {
        adopted,
        processed,
      },
    });
  } catch (error) {
    console.error(
      "Prestmit reconciliation error:",
      error.message
    );

    return res.status(502).json({
      status: false,
      message:
        error.message ||
        "Unable to reconcile Prestmit transaction",
    });
  }
};
