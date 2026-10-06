const { monnifyBasic, monnifyJwtClient } = require("../clients/monnify.client");

async function getJwtToken() {
  const res = await monnifyBasic.post("/api/v1/auth/login", {
    apiKey: process.env.MONNIFY_API_KEY,
    secretKey: process.env.MONNIFY_SECRET_KEY,
  });
  if (!res.data?.requestSuccessful || !res.data?.responseBody?.accessToken) {
    throw new Error("Monnify auth login failed");
  }
  return res.data.responseBody.accessToken;
}

async function createReservedAccount(payload) {
  const token = await getJwtToken();
  const client = monnifyJwtClient(token);
  const res = await client.post("/api/v2/bank-transfer/reserved-accounts", {
    accountReference: payload.accountReference,
    accountName: payload.accountName,
    customerEmail: payload.customerEmail,
    customerName: payload.customerName,
    customerPhoneNumber: payload.customerPhoneNumber,
    currencyCode: "NGN",
    contractCode: process.env.MONNIFY_CONTRACT_CODE,
    getAllAvailableBanks: true,
  });
  if (!res.data?.requestSuccessful) {
    throw new Error(`Monnify reserved account failed: ${res.data?.responseMessage || "Unknown error"}`);
  }
  return res.data.responseBody;
}

async function getReservedAccountDetails(accountReference) {
  const token = await getJwtToken();
  const client = monnifyJwtClient(token);
  const res = await client.get(`/api/v2/bank-transfer/reserved-accounts/${encodeURIComponent(accountReference)}`);
  if (!res.data?.requestSuccessful) {
    throw new Error(`Monnify reserved account lookup failed: ${res.data?.responseMessage || "Unknown error"}`);
  }
  return res.data.responseBody;
}

async function getReservedAccountTransactions(accountReference, options = {}) {
  if (!accountReference) throw new Error("accountReference is required");
  const page = Number.isInteger(options.page) && options.page >= 0 ? options.page : 0;
  const size = Number.isInteger(options.size) && options.size > 0
    ? options.size : Number(process.env.MONNIFY_TRANSACTION_PAGE_SIZE || 100);
  const token = await getJwtToken();
  const client = monnifyJwtClient(token);
  const res = await client.get("/api/v1/bank-transfer/reserved-accounts/transactions", {
    params: { accountReference, page, size },
  });
  if (!res.data?.requestSuccessful) {
    throw new Error(`Monnify reserved account transactions failed: ${res.data?.responseMessage || "Unknown error"}`);
  }
  return res.data.responseBody;
}

module.exports = { getJwtToken, createReservedAccount, getReservedAccountDetails, getReservedAccountTransactions };
