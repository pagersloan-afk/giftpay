// src/services/monnify.service.js
const { monnifyBasic, monnifyJwtClient } = require("../clients/monnify.client");

// 1) Get JWT token
async function getJwtToken() {
  const res = await monnifyBasic.post("/api/v1/auth/login", {
    apiKey: process.env.MONNIFY_API_KEY,
    secretKey: process.env.MONNIFY_SECRET_KEY,
  });

  if (!res.data?.requestSuccessful) {
    throw new Error("Monnify auth login failed");
  }

  return res.data.responseBody.accessToken;
}

// 2) Create Reserved Account (JWT required)
async function createReservedAccount(payload) {
  const token = await getJwtToken();
  const jwtClient = monnifyJwtClient(token);

  const res = await jwtClient.post("/api/v2/bank-transfer/reserved-accounts", {
    accountReference: payload.accountReference,
    accountName: payload.accountName,
    customerEmail: payload.customerEmail,
    customerName: payload.customerName,
    customerPhoneNumber: payload.customerPhoneNumber,   // ⭐ REQUIRED
    currencyCode: "NGN",
    contractCode: process.env.MONNIFY_CONTRACT_CODE,
    getAllAvailableBanks: true
  });

  if (!res.data?.requestSuccessful) {
    throw new Error(
      `Monnify reserved account failed: ${res.data?.responseMessage || "Unknown error"}`
    );
  }

  return res.data.responseBody;
}

// 3) Get Reserved Account Details (JWT required)
async function getReservedAccountDetails(accountReference) {
  const token = await getJwtToken();
  const jwtClient = monnifyJwtClient(token);

  const res = await jwtClient.get(
    `/api/v2/bank-transfer/reserved-accounts/${accountReference}`
  );

  if (!res.data?.requestSuccessful) {
    throw new Error(
      `Monnify reserved account lookup failed: ${res.data?.responseMessage || "Unknown error"}`
    );
  }

  return res.data.responseBody;
}

// 4) Get Reserved Account Transactions (JWT required)
async function getReservedAccountTransactions(accountReference) {
  const token = await getJwtToken();
  const jwtClient = monnifyJwtClient(token);

  const res = await jwtClient.get(
    `/api/v1/bank-transfer/reserved-accounts/transactions`,
    { params: { accountReference } }
  );

  if (!res.data?.requestSuccessful) {
    throw new Error(
      `Monnify reserved account transactions failed: ${res.data?.responseMessage || "Unknown error"}`
    );
  }

  return res.data.responseBody;
}

module.exports = {
  getJwtToken,
  createReservedAccount,
  getReservedAccountDetails,
  getReservedAccountTransactions,
};
