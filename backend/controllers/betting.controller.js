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
      amount,
    } = req.body;

    console.log("[BETTING FUND][INCOMING]", {
      userId,
      bettingCompany,
      customerId,
      amount,
    });

    if (!userId || !bettingCompany || !customerId || amount == null) {
      return res.status(400).json({
        status: false,
        message: "Missing required fields",
      });
    }

    const amountInt = Number(amount);

    if (!Number.isFinite(amountInt) || amountInt < 100) {
      return res.status(400).json({
        status: false,
        message: "Invalid amount (minimum ₦100)",
      });
    }

    // ============================================================
    // FEE ENGINE
    // Betting is currently free to the customer.
    // FeeEngine.betting() should return:
    // userPays = amount
    // fee = 0
    // ============================================================

    const feeResult = FeeEngine.betting(amountInt);

    const userPays = Number(feeResult.userPays);
    const fee = Number(feeResult.fee || 0);

    console.log("[BETTING FUND][FEE]", {
      amount: amountInt,
      userPays,
      fee,
    });

    const walletRef = admin
      .firestore()
      .collection("wallets")
      .doc(userId);

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

    // ============================================================
    // DEBIT WALLET
    // ============================================================

    await walletRef.update({
      balance: balance - userPays,
      transactions:
        admin.firestore.FieldValue.arrayUnion(debitTx),
    });

    console.log("[BETTING FUND][DEBIT_TX]", debitTx);

    await sendNotification(
      userId,
      "Wallet debited",
      `₦${userPays} debited for ${bettingCompany.toUpperCase()} betting wallet funding (${customerId})`,
      "betting"
    );

    // ============================================================
    // CALL CLUBKONNECT
    // ============================================================

    const vend = await fundBettingWallet({
      bettingCompany,
      customerId,
      amount: amountInt,
      requestId,
      callbackUrl: "",
    });

    console.log("[BETTING FUND][CLUBKONNECT RAW]", vend);

    const status = String(
      vend?.status ||
        vend?.statuscode ||
        vend?.orderstatus ||
        vend?.OrderStatus ||
        ""
    ).toUpperCase();

    console.log("[BETTING FUND][STATUS]", status);

    // ============================================================
    // ORDER RECEIVED = PENDING
    // ============================================================
    //
    // ClubKonnect documentation says status 100 /
    // ORDER_RECEIVED means the order has been received.
    // It is NOT confirmation that the betting wallet was funded.
    //

    if (
      status === "ORDER_RECEIVED" ||
      status === "100"
    ) {
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
          providerCode: vend?.providerCode || null,
          customerId,
          amount: amountInt,
          fee,
          totalDebited: userPays,
          cashback: 0,
          requestId,
          status: "pending",
          timestamp: Date.now(),
          raw: vend,
        });

      return res.json({
        status: true,
        pending: true,
        message:
          vend?.orderremark ||
          vend?.remark ||
          "Betting wallet funding order received and is being processed.",
        requestId,
        fee,
        debited: userPays,
        cashback: 0,
        providerCode: vend?.providerCode || null,
      });
    }

    // ============================================================
    // COMPLETED
    // ============================================================

    if (
      status === "ORDER_COMPLETED" ||
      status === "200"
    ) {
      const cashback = Number(
        FeeEngine.cashback("betting", amountInt) || 0
      );

      const walletAfter = await walletRef.get();
      const data = walletAfter.data();
      const txns = data.transactions || [];

      const idx = txns.findIndex(
        (t) => t.id === reference
      );

      if (idx !== -1) {
        txns[idx].status = "success";
      }

      const updatePayload = {
        transactions: txns,
      };

      if (cashback > 0) {
        updatePayload.balance =
          admin.firestore.FieldValue.increment(cashback);

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
          providerCode: vend?.providerCode || null,
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
        pending: false,
        message:
          vend?.orderremark ||
          vend?.remark ||
          "Betting wallet funding successful",
        requestId,
        fee,
        debited: userPays,
        cashback,
        providerCode: vend?.providerCode || null,
      });
    }

    // ============================================================
    // FAILED
    // ============================================================

    if (
      status === "ORDER_FAILED" ||
      status === "FAILED" ||
      status === "400"
    ) {
      const refundAmount = userPays;

      await walletRef.update({
        balance:
          admin.firestore.FieldValue.increment(refundAmount),
        transactions:
          admin.firestore.FieldValue.arrayUnion({
            id: `${reference}_refund`,
            type: "credit",
            title: `Refund: Betting Wallet Funding Failed (${bettingCompany.toUpperCase()} - ${customerId})`,
            amount: refundAmount,
            timestamp: Date.now(),
            status: "refunded",
          }),
      });

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
          providerCode: vend?.providerCode || null,
          customerId,
          amount: amountInt,
          fee,
          totalDebited: userPays,
          cashback: 0,
          requestId,
          status: "failed",
          refunded: refundAmount,
          timestamp: Date.now(),
          raw: vend,
        });

      await sendNotification(
        userId,
        "Betting wallet funding failed",
        `₦${refundAmount} refunded to your wallet`,
        "betting"
      );

      return res.status(400).json({
        status: false,
        pending: false,
        message:
          vend?.orderremark ||
          vend?.remark ||
          "Betting wallet funding failed. Your wallet has been refunded.",
        refunded: refundAmount,
        raw: vend,
      });
    }

    // ============================================================
    // UNKNOWN / UNEXPECTED STATUS
    // ============================================================

    console.warn("[BETTING FUND][UNKNOWN STATUS]", {
      status,
      raw: vend,
    });

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
        providerCode: vend?.providerCode || null,
        customerId,
        amount: amountInt,
        fee,
        totalDebited: userPays,
        cashback: 0,
        requestId,
        status: "pending",
        timestamp: Date.now(),
        raw: vend,
      });

    return res.json({
      status: true,
      pending: true,
      message:
        "Betting transaction is being processed. Please check again shortly.",
      requestId,
      fee,
      debited: userPays,
      cashback: 0,
      raw: vend,
    });
  } catch (err) {
    console.error("[BETTING FUND][SERVER ERROR]", {
      message: err.message,
      stack: err.stack,
      response: err.response?.data,
    });

    return res.status(500).json({
      status: false,
      message: "Server error processing betting wallet funding",
    });
  }
};