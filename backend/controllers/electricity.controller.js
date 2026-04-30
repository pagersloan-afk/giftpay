const admin = require("firebase-admin");
const { sendNotification } = require("../utils/notify");
const { vendElectricity } = require("../src/services/clubkonnectElectricity.service");

// ⭐ UPDATED: Import Fee Engine
const FeeEngine = require("../core/fees/fee_engine");

exports.walletPayElectricity = async (req, res) => {
  try {
    const { userId, meterNumber, disco, amount, phone, meterType } = req.body;

    if (!userId || !meterNumber || !disco || !amount || !phone || !meterType) {
      return res.status(400).json({
        status: false,
        message: "Missing required fields",
      });
    }

    const amountInt = Number(amount);
    if (isNaN(amountInt) || amountInt < 200) {
      return res.status(400).json({
        status: false,
        message: "Invalid amount (min ₦200)",
      });
    }

    // ⭐ UPDATED: Apply electricity fee (₦15)
    const feeResult = FeeEngine.electricity(amountInt);
    const userPays = feeResult.userPays; // amount + ₦15
    const fee = feeResult.fee;

    // ⭐ Fetch wallet
    const walletRef = admin.firestore().collection("wallets").doc(userId);
    const walletDoc = await walletRef.get();

    if (!walletDoc.exists) {
      return res.status(404).json({
        status: false,
        message: "Wallet not found",
      });
    }

    const currentBalance = Number(walletDoc.data().balance || 0);

    // ⭐ UPDATED: Check against userPays (not amountInt)
    if (currentBalance < userPays) {
      return res.status(400).json({
        status: false,
        message: "Insufficient wallet balance",
      });
    }

    // ⭐ Generate reference
    const reference = `WL-${Date.now()}`;

    // ⭐ UPDATED: Debit wallet with fee included
    const debitTx = {
      id: reference,
      type: "debit",
      title: `Electricity Purchase (${meterNumber})`,
      amount: amountInt,       // base amount
      fee,                     // ⭐ store fee
      totalDebited: userPays,  // ⭐ store full amount user paid
      timestamp: Date.now(),
      status: "pending",
    };

    await walletRef.update({
      balance: currentBalance - userPays,
      transactions: admin.firestore.FieldValue.arrayUnion(debitTx),
    });

    await sendNotification(
      userId,
      "Wallet debited",
      `₦${userPays} debited for electricity purchase (${meterNumber})`,
      "electricity"
    );

    // ⭐ CALL CLUBKONNECT (WITH POLLING)
    const { requestId, response: vend } = await vendElectricity({
      disco,
      meterNumber,
      meterType,
      amount: amountInt, // CK receives base amount only
      phone,
    });

    console.log("⚡ FINAL CK RESPONSE:", JSON.stringify(vend, null, 2));

    // ⭐ Extract token
    const token =
      vend?.metertoken ||
      vend?.Token ||
      vend?.token ||
      vend?.orderremark ||
      "";

    const hasToken = token && token.toString().trim() !== "";

    // ⭐ Extract orderId
    const orderId =
      vend?.orderid ||
      vend?.OrderID ||
      vend?.transactionid ||
      "";

    // ⭐ Extract status
    const rawStatus =
      vend?.transactionstatus ||
      vend?.orderstatus ||
      vend?.status ||
      vend?.Status ||
      "";

    const status = (rawStatus || "").toString().trim().toUpperCase();

    const isFailed =
      status === "ORDER_FAILED" ||
      status === "FAILED" ||
      status === "ERROR";

    // ⭐ SUCCESS — token ALWAYS exists because CK polling waits for it
    if (hasToken && !isFailed) {
      // ⭐ UPDATED: Cashback (₦5)
      const cashback = FeeEngine.cashback("electricity", amountInt);

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
          title: `Cashback: Electricity Purchase (${meterNumber})`,
          amount: cashback,
          timestamp: Date.now(),
          status: "success",
        });
      }

      await walletRef.update(updates);

      // ⭐ Save transaction record
      await admin
        .firestore()
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .doc(reference)
        .set({
          type: "electricity",
          meterNumber,
          disco,
          meterType,
          amount: amountInt,
          fee,
          totalDebited: userPays,
          phone,
          token,
          reference,
          requestId,
          orderId,
          cashback,
          status: "success",
          timestamp: Date.now(),
          raw: vend,
        });

      await sendNotification(
        userId,
        "Electricity purchase successful",
        `Token generated for meter ${meterNumber}`,
        "electricity"
      );

      const units =
        vend?.units || vend?.unit || vend?.Units || vend?.unitvalue || "";

      return res.json({
        status: true,
        token,
        units,
        amount: amountInt,
        fee,
        debited: userPays,
        cashback,
        meterNumber,
        disco,
        requestId,
        orderId,
      });
    }

    // ⭐ FAILED → REFUND full userPays
    await walletRef.update({
      balance: currentBalance,
      transactions: admin.firestore.FieldValue.arrayUnion({
        id: `${reference}_refund`,
        type: "credit",
        title: `Refund: Electricity Purchase Failed (${meterNumber})`,
        amount: userPays, // ⭐ refund full amount user paid
        timestamp: Date.now(),
        status: "refunded",
      }),
    });

    await sendNotification(
      userId,
      "Electricity purchase failed",
      `₦${userPays} refunded to your wallet`,
      "electricity"
    );

    return res.status(400).json({
      status: false,
      message: vend?.orderremark || vend?.message || "Electricity vending failed",
      raw: vend,
    });

  } catch (err) {
    console.error("Wallet pay electricity error:", err);
    return res.status(500).json({
      status: false,
      message: "Server error processing wallet electricity payment",
    });
  }
};
