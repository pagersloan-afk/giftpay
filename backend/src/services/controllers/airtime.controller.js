const admin = require("firebase-admin");
const { sendNotification } = require("../../../utils/notify");
const { vendAirtime } = require("../clubkonnectAirtime.service");

// ⭐ UPDATED: Import Fee Engine
const FeeEngine = require("../../../core/fees/fee_engine");

exports.walletPayAirtime = async (req, res) => {
  try {
    const { userId, phone, network, amount } = req.body;

    if (!userId || !phone || !network || !amount) {
      return res.status(400).json({ status: false, message: "Missing fields" });
    }

    const amountInt = Number(amount);
    if (amountInt < 50) {
      return res.status(400).json({ status: false, message: "Minimum is ₦50" });
    }

    // ⭐ UPDATED: Apply airtime markup (1%)
    const feeResult = FeeEngine.airtime(amountInt);
    const userPays = feeResult.userPays; // amount + markup
    const fee = feeResult.fee;

    // ⭐ Fetch wallet
    const walletRef = admin.firestore().collection("wallets").doc(userId);
    const walletDoc = await walletRef.get();

    if (!walletDoc.exists) {
      return res.status(404).json({ status: false, message: "Wallet not found" });
    }

    const balance = Number(walletDoc.data().balance || 0);

    // ⭐ UPDATED: Check against userPays
    if (balance < userPays) {
      return res.status(400).json({ status: false, message: "Insufficient balance" });
    }

    const reference = `AIR-${Date.now()}`;
    const requestId = reference;

    // ⭐ UPDATED: Debit wallet with markup included
    const debitTx = {
      id: reference,
      type: "debit",
      title: `Airtime Purchase (${phone})`,
      amount: amountInt,       // base amount
      fee,                     // ⭐ markup stored
      totalDebited: userPays,  // ⭐ full amount user paid
      timestamp: Date.now(),
      status: "pending",
    };

    await walletRef.update({
      balance: balance - userPays,
      transactions: admin.firestore.FieldValue.arrayUnion(debitTx),
    });

    await sendNotification(
      userId,
      "Wallet debited",
      `₦${userPays} debited for airtime purchase (${phone})`,
      "airtime"
    );

    // ⭐ 2) CALL CLUBKONNECT with base amount
    const vend = await vendAirtime({
      network,
      amount: amountInt,
      phone,
      requestId,
    });

    const status = vend?.status || vend?.statuscode;

    // ⭐ SUCCESS
    if (status === "ORDER_COMPLETED") {
      // ⭐ UPDATED: Cashback (1%)
      const cashback = FeeEngine.cashback("airtime", amountInt);

      const updates = {
        transactions: admin.firestore.FieldValue.arrayUnion({
          ...debitTx,
          status: "success",
        }),
      };

      // ⭐ UPDATED: Apply cashback
      if (cashback > 0) {
        updates.balance = admin.firestore.FieldValue.increment(cashback);
        updates.transactions = admin.firestore.FieldValue.arrayUnion({
          id: `${reference}_cashback`,
          type: "credit",
          title: `Cashback: Airtime Purchase (${phone})`,
          amount: cashback,
          timestamp: Date.now(),
          status: "success",
        });
      }

      await walletRef.update(updates);

      // ⭐ Save service transaction
      await admin
        .firestore()
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .doc(reference)
        .set({
          type: "airtime",
          phone,
          amount: amountInt,
          fee,
          totalDebited: userPays,
          cashback,
          network,
          requestId,
          status: "success",
          timestamp: Date.now(),
          raw: vend,
        });

      await sendNotification(
        userId,
        "Airtime purchase successful",
        `₦${amountInt} airtime delivered to ${phone}`,
        "airtime"
      );

      return res.json({
        status: true,
        message: vend?.remark || "Airtime purchase successful",
        requestId,
        fee,
        debited: userPays,
        cashback,
      });
    }

    // ⭐ PENDING
    if (status === "ORDER_RECEIVED") {
      return res.json({
        status: true,
        pending: true,
        requestId,
        message: "Processing airtime purchase...",
      });
    }

    // ⭐ FAILED → REFUND full userPays
    await walletRef.update({
      balance,
      transactions: admin.firestore.FieldValue.arrayUnion({
        id: `${reference}_refund`,
        type: "credit",
        title: `Refund: Airtime Purchase Failed (${phone})`,
        amount: userPays, // ⭐ refund full amount user paid
        timestamp: Date.now(),
        status: "refunded",
      }),
    });

    await sendNotification(
      userId,
      "Airtime purchase failed",
      `₦${userPays} refunded to your wallet`,
      "airtime"
    );

    return res.status(400).json({
      status: false,
      message: vend?.remark || "Airtime vending failed",
    });

  } catch (err) {
    console.error("Wallet pay airtime error:", err);
    return res.status(500).json({
      status: false,
      message: "Server error processing wallet airtime payment",
    });
  }
};

/**
 * ⭐ OLD ENDPOINTS (kept for backward compatibility)
 */
exports.buyAirtimeController = (req, res) => {
  res.json({ message: "Old buy airtime endpoint not implemented" });
};

exports.queryAirtimeController = (req, res) => {
  res.json({ message: "Old query airtime endpoint not implemented" });
};

exports.cancelAirtimeController = (req, res) => {
  res.json({ message: "Old cancel airtime endpoint not implemented" });
};
