// src/controllers/monnify.controller.js
const admin = require("firebase-admin");
const firestore = admin.firestore();
const { createReservedAccount } = require("../services/monnify.service");

const createReservedAccountController = async (req, res) => {
  try {
    const { userId, name, email, phone } = req.body;

    const accountRef = `USER_${userId}`;

    const va = await createReservedAccount({
      accountReference: accountRef,
      accountName: name,
      customerEmail: email,
      customerName: name,
      customerPhoneNumber: phone,   // ⭐ REQUIRED
    });

    console.log("MONNIFY RESPONSE:", JSON.stringify(va, null, 2));

    // ⭐ Extract primary bank account
    const primaryAccount = va.accounts?.[0];
    if (!primaryAccount) {
      throw new Error("Monnify returned no accounts array");
    }

    await firestore.collection("users").doc(userId).set({
      virtualAccount: {
        accountNumber: primaryAccount.accountNumber,
        bankName: primaryAccount.bankName,
        accountName: primaryAccount.accountName,
        reference: accountRef,
        allAccounts: va.accounts,   // ⭐ Optional: store all banks
      },
    }, { merge: true });

    return res.status(200).json({
      status: true,
      data: {
        accountNumber: primaryAccount.accountNumber,
        bankName: primaryAccount.bankName,
        accountName: primaryAccount.accountName,
        reference: accountRef,
        allAccounts: va.accounts,
      },
    });
  } catch (err) {
    console.error("Monnify VA error:", err.response?.data || err.message);
    return res.status(400).json({
      status: false,
      error: err.response?.data || err.message,
    });
  }
};

module.exports = {
  createReservedAccount: createReservedAccountController,
};
