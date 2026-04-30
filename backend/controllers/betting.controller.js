// backend/controllers/betting.controller.js
const admin = require("firebase-admin");
const { sendNotification } = require("../utils/notify");
const FeeEngine = require("../core/fees/fee_engine");
const {
  fundBettingWallet,
} = require("../src/services/clubkonnectBetting.service");

exports.walletFundBetting = async (req, res) => {
  try {
    const {
      userId,
      bettingCompany,
      customerId,
      amount, // plain amount user wants to fund
    } = req.body;

    if (!userId || !bettingCompany || !customerId || !amount) {
      return res.status(400).json({
        status: false,
        message: "Missing required fields",
      });
    }

    const amountInt = Number(amount);
    if (isNaN(amountInt) || amountInt < 100) {
      return res.status(400).json({
        status: false,
        message: "Invalid amount (min ₦100)",
      });
    }

    // Apply betting fee (you define FeeEngine.betting)
    const feeResult = FeeEngine.betting(amountInt);
    const userPays = feeResult.userPays;
    const fee = feeResult.fee;

    const walletRef = admin.firestore().collection("wallets").doc(userId);
    const walletDoc = await walletRef.get();

    if (!walletDoc.exists) {
      return res.status(404).json({
        status: false,
        message: "Wallet not found",
      });
    }

    const balance = Number(walletDoc.data().balance || 0);
    if (balance < userPays) {
      return res.status(400).json({
        status: false,
        message: "Insufficient wallet balance",
      });
    }

    const reference = `BET-${Date.now()}`;
    const requestId = reference;

    const debitTx = {
      id: reference,
      type: "debit",
      title: `Betting Wallet Funding (${bettingCompany.toUpperCase()} - ${customerId})`,
      amount: amountInt,
      fee,
      totalDebited: userPays,
      timestamp: Date.now(),
      status: "pending",
      requestId,
    };

    // Deduct wallet + add pending transaction
    await walletRef.update({
      balance: balance - userPays,
      transactions: admin.firestore.FieldValue.arrayUnion(debitTx),
    });

    console.log("[BETTING FUND][DEBIT_TX]", debitTx);

    await sendNotification(
      userId,
      "Wallet debited",
      `₦${userPays} debited for ${bettingCompany.toUpperCase()} betting wallet funding (${customerId})`,
      "betting"
    );

    // Call ClubKonnect
    const vend = await fundBettingWallet({
      bettingCompany,
      customerId,
      amount: amountInt,
      requestId,
      callbackUrl: "", // optional, you can plug your callback later
    });

    console.log("[BETTING FUND][CLUBKONNECT RAW]", vend);

    const status =
      vend?.status ||
      vend?.statuscode ||
      vend?.orderstatus ||
      vend?.OrderStatus;

    // SUCCESS (ORDER_COMPLETED or 200 or ORDER_RECEIVED)
    if (
      status === "ORDER_COMPLETED" ||
      status === "200" ||
      status === "ORDER_RECEIVED"
    ) {
      const cashback = FeeEngine.cashback("betting", amountInt);

      // Update pending transaction to success
      const walletAfter = await walletRef.get();
      const data = walletAfter.data();
      const txns = data.transactions || [];

      const idx = txns.findIndex((t) => t.id === reference);
      if (idx !== -1) {
        txns[idx].status = "success";
      }

      const updatePayload = { transactions: txns };

      if (cashback > 0) {
        updatePayload.balance = admin.firestore.FieldValue.increment(cashback);
        txns.push({
          id: `${reference}_cashback`,
          type: "credit",
          title: `Cashback: Betting Wallet Funding (${bettingCompany.toUpperCase()} - ${customerId})`,
          amount: cashback,
          timestamp: Date.now(),
          status: "success",
        });
      }

      await walletRef.update(updatePayload);

      // Save transaction record
      await admin
        .firestore()
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .doc(reference)
        .set({
          id: reference,
          type: "betting",
          bettingCompany,
          customerId,
          amount: amountInt,
          fee,
          totalDebited: userPays,
          cashback,
          requestId,
          status: "success",
          timestamp: Date.now(),
          raw: vend,
        });

      await sendNotification(
        userId,
        "Betting wallet funded",
        `${bettingCompany.toUpperCase()} wallet funded for ${customerId}`,
        "betting"
      );

      return res.json({
        status: true,
        message:
          vend?.orderremark || vend?.remark || "Betting wallet funding successful",
        requestId,
        fee,
        debited: userPays,
        cashback,
      });
    }

    // FAILED → Refund full userPays
    await walletRef.update({
      balance,
      transactions: admin.firestore.FieldValue.arrayUnion({
        id: `${reference}_refund`,
        type: "credit",
        title: `Refund: Betting Wallet Funding Failed (${bettingCompany.toUpperCase()} - ${customerId})`,
        amount: userPays,
        timestamp: Date.now(),
        status: "refunded",
      }),
    });

    await sendNotification(
      userId,
      "Betting wallet funding failed",
      `₦${userPays} refunded to your wallet`,
      "betting"
    );

    return res.status(400).json({
      status: false,
      message:
        vend?.orderremark || vend?.remark || "Betting wallet funding failed",
      raw: vend,
    });
  } catch (err) {
    console.error("Wallet fund betting error:", err);
    return res.status(500).json({
      status: false,
      message: "Server error processing betting wallet funding",
    });
  }
};
