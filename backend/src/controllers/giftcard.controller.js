const admin = require("firebase-admin");
const db = admin.firestore();
const FXEngine = require("../../core/fx/fx_engine");

/**
 * BUY GIFT CARD
 * Body: { userId, brand, cardType, usdAmount }
 */
exports.buyGiftCard = async (req, res) => {
  try {
    const { userId, brand, cardType, usdAmount } = req.body;

    if (!userId || !brand || !cardType || !usdAmount) {
      return res.status(400).json({
        status: false,
        message: "Missing required fields",
      });
    }

    const usd = Number(usdAmount);

    // ⭐ FETCH LIVE FX RATE
    const fxRate = await FXEngine.getUsdToNgnRate();
    const nairaToCharge = Math.round(usd * fxRate);

    // ⭐ FETCH WALLET
    const walletRef = db.collection("wallets").doc(userId);
    const walletDoc = await walletRef.get();

    if (!walletDoc.exists) {
      return res.status(404).json({
        status: false,
        message: "Wallet not found",
      });
    }

    const balance = Number(walletDoc.data().balance || 0);

    if (balance < nairaToCharge) {
      return res.status(400).json({
        status: false,
        message: "Insufficient wallet balance",
      });
    }

    // ⭐ DEBIT WALLET IN NAIRA
    await walletRef.update({
      balance: balance - nairaToCharge,
    });

    // ⭐ MOCK VENDOR API
    const generatedCode = "GC-" + Date.now();

    // ⭐ SAVE TRANSACTION (UI‑friendly fields)
    const txRef = await db
      .collection("users")
      .doc(userId)
      .collection("transactions")
      .add({
        type: "giftcard",
        title: `${brand} Gift Card`,
        amount: nairaToCharge,
        amountUsd: usd,
        fxRate,
        code: generatedCode,
        brand,
        cardType,
        status: "success",

        // ⭐ IMPORTANT: Flutter reads this
        date: new Date().toISOString(),

        // ⭐ For sorting
        timestamp: Date.now(),
      });

    // ⭐ SEND NOTIFICATION
    try {
      const { sendNotification } = require("../utils/notify");
      await sendNotification(
        userId,
        "Gift Card Delivered",
        `${brand} (${cardType}) - Code: ${generatedCode}`
      );
    } catch (err) {
      console.log("Notification error:", err.message);
    }

    return res.json({
      status: true,
      code: generatedCode,
      transactionId: txRef.id,
      usdAmount: usd,
      fxRate,
      nairaCharged: nairaToCharge,
    });
  } catch (err) {
    console.error("Gift card purchase error:", err);
    return res.status(500).json({
      status: false,
      message: "Server error processing gift card purchase",
    });
  }
};

/**
 * QUOTE GIFT CARD PRICE (NGN PREVIEW)
 * Body: { usdAmount }
 */
exports.quoteGiftCard = async (req, res) => {
  try {
    const { usdAmount } = req.body;

    if (!usdAmount) {
      return res.status(400).json({
        status: false,
        message: "usdAmount is required",
      });
    }

    const usd = Number(usdAmount);

    // ⭐ LIVE FX RATE
    const fxRate = await FXEngine.getUsdToNgnRate();
    const nairaToCharge = Math.round(usd * fxRate);

    return res.json({
      status: true,
      fxRate,
      nairaToCharge,
    });
  } catch (err) {
    console.error("Quote error:", err);
    return res.status(500).json({
      status: false,
      message: "Failed to fetch quote",
    });
  }
};
