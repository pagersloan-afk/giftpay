// src/controllers/monnify.controller.js
const admin = require("firebase-admin");
const firestore = admin.firestore();
const { createReservedAccount } = require("../services/monnify.service");

const createReservedAccountController = async (req, res) => {
  try {
    const { userId, name, email } = req.body;

    const accountRef = `USER_${userId}`;

    const va = await createReservedAccount({
      accountReference: accountRef,
      accountName: name,
      customerEmail: email,
      customerName: name,
    });

    await firestore.collection("users").doc(userId).set({
      virtualAccount: {
        accountNumber: va.accountNumber,
        bankName: va.bankName,
        accountName: va.accountName,
        reference: accountRef,
      },
    }, { merge: true });

    return res.status(200).json({
      status: true,
      data: {
        accountNumber: va.accountNumber,
        bankName: va.bankName,
        accountName: va.accountName,
        reference: accountRef,
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
