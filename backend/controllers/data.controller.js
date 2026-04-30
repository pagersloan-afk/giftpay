const admin = require("firebase-admin");
const axios = require("axios");
const { sendNotification } = require("../utils/notify");
const { vendData } = require("../src/services/clubkonnectData.service");

// ⭐ NEW: Import Fee Engine
const FeeEngine = require("../core/fees/fee_engine");

exports.walletPayData = async (req, res) => {
  try {
    const { userId, phone, network, planId } = req.body;

    console.log("\n================ WALLET PAY DATA DEBUG ================");
    console.log("Incoming body:", req.body);

    if (!userId || !phone || !network || !planId) {
      return res.status(400).json({
        status: false,
        message: "Missing fields",
      });
    }

    // ⭐ Fetch plan price from ClubKonnect
    const USER_ID = process.env.CLUBKONNECT_USERID;
    const plansUrl = `https://www.nellobytesystems.com/APIDatabundlePlansV2.asp?UserID=${USER_ID}`;

    const plansRes = await axios.get(plansUrl);
    const raw = plansRes.data;

    const networks = raw["MOBILE_NETWORK"];
    if (!networks) {
      return res.status(400).json({
        status: false,
        message: "Invalid provider response",
      });
    }

    const normalized = {};
    for (const key in networks) {
      normalized[key.toLowerCase()] = networks[key];
    }

    const lookupKey = Object.keys(normalized).find(
      (k) => k.toLowerCase() === network.toLowerCase()
    );

    if (!lookupKey) {
      return res.status(400).json({
        status: false,
        message: `Invalid network: ${network}`,
        availableNetworks: Object.keys(normalized),
      });
    }

    const networkArray = normalized[lookupKey];
    const products = networkArray[0]?.PRODUCT || [];

    const selectedPlan = products.find(
      (p) => p.PRODUCT_CODE.toString() === planId.toString()
    );

    console.log("Selected plan:", selectedPlan);

    if (!selectedPlan) {
      return res.status(400).json({
        status: false,
        message: "Invalid plan",
      });
    }

    // ⭐ Base CK price
    const amountInt = Number(selectedPlan.PRODUCT_AMOUNT);
    if (!amountInt || amountInt < 50) {
      return res.status(400).json({
        status: false,
        message: "Invalid plan price",
      });
    }

    // ⭐ NEW: Apply GiftPay Data Markup (2%)
    const feeResult = FeeEngine.data(amountInt);
    const userPays = feeResult.userPays; // amountInt + markup
    const fee = feeResult.fee;

    // ⭐ CK requires PRODUCT_ID
    const planCode = selectedPlan.PRODUCT_ID;

    // ⭐ Wallet lookup
    const walletRef = admin.firestore().collection("wallets").doc(userId);
    const walletDoc = await walletRef.get();

    if (!walletDoc.exists) {
      return res.status(404).json({
        status: false,
        message: "Wallet not found",
      });
    }

    const balance = Number(walletDoc.data().balance || 0);

    // ⭐ NEW: Check against userPays (not amountInt)
    if (balance < userPays) {
      return res.status(400).json({
        status: false,
        message: "Insufficient balance",
      });
    }

    const reference = `DATA-${Date.now()}`;
    const requestId = reference;

    // ⭐ NEW: Debit wallet with markup included
    await walletRef.update({
      balance: balance - userPays,
      transactions: admin.firestore.FieldValue.arrayUnion({
        id: reference,
        type: "debit",
        title: `Data Purchase (${phone})`,
        amount: amountInt,   // base amount
        fee,                 // ⭐ markup stored
        totalDebited: userPays, // ⭐ full amount user paid
        timestamp: Date.now(),
        status: "pending",
      }),
    });

    await sendNotification(
      userId,
      "Wallet debited",
      `₦${userPays} debited for data purchase (${phone})`,
      "data"
    );

    const networkCode = networkArray[0]?.ID;

    console.log("📌 Correct Network Code:", networkCode);

    // ⭐ Call ClubKonnect with base amount
    const vend = await vendData({
      network: networkCode,
      planCode,
      phone,
      requestId,
    });

    console.log("\n================ CLUBKONNECT VEND RESPONSE ================");
    console.log(JSON.stringify(vend, null, 2));
    console.log("===========================================================\n");

    const status =
      vend?.status ||
      vend?.statuscode ||
      vend?.orderstatus ||
      vend?.data?.status ||
      vend?.data?.orderstatus;

    // ⭐ SUCCESS
    if (status === "ORDER_COMPLETED" || status === "200") {
      // ⭐ NEW: Cashback (2%)
      const cashback = FeeEngine.cashback("data", amountInt);

      const updates = {
        transactions: admin.firestore.FieldValue.arrayUnion({
          id: reference,
          type: "debit",
          title: `Data Purchase (${phone})`,
          amount: amountInt,
          fee,
          totalDebited: userPays,
          timestamp: Date.now(),
          status: "success",
        }),
      };

      // ⭐ NEW: Apply cashback
      if (cashback > 0) {
        updates.balance = admin.firestore.FieldValue.increment(cashback);
        updates.transactions = admin.firestore.FieldValue.arrayUnion({
          id: `${reference}_cashback`,
          type: "credit",
          title: `Cashback: Data Purchase (${phone})`,
          amount: cashback,
          timestamp: Date.now(),
          status: "success",
        });
      }

      await walletRef.update(updates);

      await sendNotification(
        userId,
        "Data purchase successful",
        `Your data bundle has been delivered to ${phone}`,
        "data"
      );

      return res.json({
        status: true,
        message: vend?.remark || vend?.orderremark || "Data purchase successful",
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
        message: "Processing data purchase...",
      });
    }

    // ⭐ FAILED → Refund full userPays (not amountInt)
    await walletRef.update({
      balance,
      transactions: admin.firestore.FieldValue.arrayUnion({
        id: `${reference}_refund`,
        type: "credit",
        title: `Refund: Data Purchase Failed (${phone})`,
        amount: userPays, // ⭐ refund full amount user paid
        timestamp: Date.now(),
        status: "refunded",
      }),
    });

    await sendNotification(
      userId,
      "Data purchase failed",
      `₦${userPays} refunded to your wallet`,
      "data"
    );

    return res.status(400).json({
      status: false,
      message: vend?.remark || vend?.orderremark || "Data vending failed",
    });

  } catch (err) {
    console.error("Wallet pay data error:", err);
    return res.status(500).json({
      status: false,
      message: "Server error processing wallet data payment",
    });
  }
};
