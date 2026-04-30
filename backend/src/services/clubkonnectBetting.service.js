// backend/src/services/clubkonnectBetting.service.js
const axios = require("axios");

const USER_ID = process.env.CLUBKONNECT_USERID;
const API_KEY = process.env.CLUBKONNECT_APIKEY;

// Verify betting customer ID
async function verifyBettingCustomer({ bettingCompany, customerId }) {
  const url =
    `https://www.nellobytesystems.com/APIVerifyBettingV1.asp?UserID=${USER_ID}` +
    `&APIKey=${API_KEY}` +
    `&BettingCompany=${bettingCompany}` +
    `&CustomerID=${customerId}`;

  console.log("[BETTING VERIFY][REQUEST]", url);

  const res = await axios.get(url);
  console.log("[BETTING VERIFY][RESPONSE]", res.data);

  return res.data;
}

// Fund betting wallet
async function fundBettingWallet({
  bettingCompany,
  customerId,
  amount,
  requestId,
  callbackUrl,
}) {
  const url =
    `https://www.nellobytesystems.com/APIBettingV1.asp?UserID=${USER_ID}` +
    `&APIKey=${API_KEY}` +
    `&BettingCompany=${bettingCompany}` +
    `&CustomerID=${customerId}` +
    `&Amount=${amount}` +
    `&RequestID=${requestId}` +
    (callbackUrl ? `&CallBackURL=${encodeURIComponent(callbackUrl)}` : "");

  console.log("[BETTING FUND][REQUEST]", url);

  const res = await axios.get(url);
  console.log("[BETTING FUND][RESPONSE]", res.data);

  return res.data;
}

module.exports = {
  verifyBettingCustomer,
  fundBettingWallet,
};
