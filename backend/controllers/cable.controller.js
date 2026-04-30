// backend/controllers/cable.controller.js
const admin = require("firebase-admin");
const { sendNotification } = require("../utils/notify");
const FeeEngine = require("../core/fees/fee_engine");
const { vendCableTV } = require("../src/services/clubkonnectCable.service");

exports.walletPayCable = async (req, res) => {
  try {
    const { userId, cable, packageCode, smartcard, phone, amount } = req.body;

    if (!userId || !cable || !packageCode || !smartcard || !phone || !amount) {
      return res.status(400).json({
        status: false,
        message: "Missing required fields",
      });
    }

    const amountInt = Number(amount);
    if (isNaN(amountInt) || amountInt < 500) {
      return res.status(400).json({
        status: false,
        message: "Invalid amount (min ₦500)",
      });
    }

    // Apply cable fee
    const feeResult = FeeEngine.cable(amountInt);
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

    const reference = `CBL-${Date.now()}`;
    const requestId = reference;

    const debitTx = {
      id: reference,
      type: "debit",
      title: `Cable TV (${cable.toUpperCase()} - ${smartcard})`,
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

    await sendNotification(
      userId,
      "Wallet debited",
      `₦${userPays} debited for ${cable.toUpperCase()} subscription (${smartcard})`,
      "cable"
    );

    // Call ClubKonnect
    const vend = await vendCableTV({
      cable,
      pkg: packageCode,
      smartcard,
      phone,
      requestId,
    });

    // Log raw vend response
    console.log("===== CLUBKONNECT RAW CABLE VEND =====");
    console.log(JSON.stringify(vend, null, 2));
    console.log("======================================");

    const status =
      vend?.status ||
      vend?.statuscode ||
      vend?.orderstatus ||
      vend?.OrderStatus ||
      vend?.data?.status ||
      vend?.data?.orderstatus;

    // SUCCESS
    if (
      status === "ORDER_COMPLETED" ||
      status === "200" ||
      status === "ORDER_RECEIVED" ||
      status === "SUCCESS"
    ) {
      const cashback = FeeEngine.cashback("cable", amountInt);

      // Update the pending transaction to success
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
          title: `Cashback: Cable TV (${cable.toUpperCase()} - ${smartcard})`,
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
          type: "cable",
          cable,
          packageCode,
          smartcard,
          phone,
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
        "Cable subscription successful",
        `${cable.toUpperCase()} subscription successful for ${smartcard}`,
        "cable"
      );

      return res.json({
        status: true,
        message:
          vend?.orderremark ||
          vend?.remark ||
          vend?.message ||
          "Cable subscription successful",
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
        title: `Refund: Cable TV Failed (${cable.toUpperCase()} - ${smartcard})`,
        amount: userPays,
        timestamp: Date.now(),
        status: "refunded",
      }),
    });

    await sendNotification(
      userId,
      "Cable subscription failed",
      `₦${userPays} refunded to your wallet`,
      "cable"
    );

    return res.status(400).json({
      status: false,
      message:
        vend?.orderremark ||
        vend?.remark ||
        vend?.message ||
        "Cable subscription failed",
      raw: vend,
    });
  } catch (err) {
    console.error("Wallet pay cable error:", err);
    return res.status(500).json({
      status: false,
      message: "Server error processing cable subscription",
    });
  }
};
