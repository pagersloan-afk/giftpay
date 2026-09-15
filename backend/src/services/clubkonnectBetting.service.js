// backend/src/services/clubkonnectBetting.service.js

const axios = require("axios");

const USER_ID = process.env.CLUBKONNECT_USERID;
const API_KEY = process.env.CLUBKONNECT_APIKEY;

// ============================================================
// CLUBKONNECT BETTING PROVIDER CODES
// ============================================================
//
// The Flutter app may send the human-readable provider name.
// We convert it here to the actual ClubKonnect provider code.
//
// Based on the ClubKonnect API documentation:
//   Nairabet  -> product-nairabet
//   BangBet   -> product-bang-bet
//   BetWay    -> product-bet-way
//   BetLand   -> product-bet-land
//   BetKing   -> product-bet-king
//   1xBet     -> product-1x-bet
//   NaijaBet  -> product-naija-bet
//   SportyBet -> prd-sporty-bet
//   MerryBet  -> product-merry-bet
//
// ============================================================

const BETTING_PROVIDER_CODES = {
  NAIRABET: "product-nairabet",
  BANGBET: "product-bang-bet",
  BETWAY: "product-bet-way",
  BETLAND: "product-bet-land",
  BETKING: "product-bet-king",
  "1XBET": "product-1x-bet",
  BET9JA: "product-naija-bet",
  NAIJABET: "product-naija-bet",
  SPORTYBET: "prd-sporty-bet",
  SPORTYBET: "prd-sporty-bet",
  MERRYBET: "product-merry-bet",
};

// Convert UI/display provider to ClubKonnect provider code.
function getBettingProviderCode(bettingCompany) {
  if (!bettingCompany) {
    throw new Error("Betting company is required");
  }

  const normalized = String(bettingCompany)
    .trim()
    .toUpperCase()
    .replace(/[\s_-]+/g, "");

  // Already a documented ClubKonnect code?
  const documentedCodes = Object.values(BETTING_PROVIDER_CODES);

  if (documentedCodes.includes(String(bettingCompany).trim())) {
    return String(bettingCompany).trim();
  }

  const code = BETTING_PROVIDER_CODES[normalized];

  if (!code) {
    throw new Error(
      `Unsupported betting provider: ${bettingCompany}`
    );
  }

  return code;
}

// ============================================================
// VERIFY BETTING CUSTOMER ID
// ============================================================

async function verifyBettingCustomer({
  bettingCompany,
  customerId,
}) {
  const providerCode = getBettingProviderCode(bettingCompany);

  const url =
    `https://www.nellobytesystems.com/APIVerifyBettingV1.asp?UserID=${encodeURIComponent(USER_ID)}` +
    `&APIKey=${encodeURIComponent(API_KEY)}` +
    `&BettingCompany=${encodeURIComponent(providerCode)}` +
    `&CustomerID=${encodeURIComponent(customerId)}`;

  console.log("[BETTING VERIFY][REQUEST]", {
    requestedProvider: bettingCompany,
    providerCode,
    customerId,
    hasUserId: !!USER_ID,
    hasApiKey: !!API_KEY,
  });

  try {
    const res = await axios.get(url, {
      timeout: 30000,
      validateStatus: () => true,
    });

    console.log("[BETTING VERIFY][HTTP STATUS]", res.status);
    console.log("[BETTING VERIFY][RESPONSE]", res.data);

    return {
      ...res.data,
      bettingCompany,
      providerCode,
    };
  } catch (error) {
    console.error("[BETTING VERIFY][AXIOS ERROR]", {
      message: error.message,
      code: error.code,
      status: error.response?.status,
      response: error.response?.data,
    });

    throw error;
  }
}

// ============================================================
// FUND BETTING WALLET
// ============================================================

async function fundBettingWallet({
  bettingCompany,
  customerId,
  amount,
  requestId,
  callbackUrl,
}) {
  const providerCode = getBettingProviderCode(bettingCompany);

  const url =
    `https://www.nellobytesystems.com/APIBettingV1.asp?UserID=${encodeURIComponent(USER_ID)}` +
    `&APIKey=${encodeURIComponent(API_KEY)}` +
    `&BettingCompany=${encodeURIComponent(providerCode)}` +
    `&CustomerID=${encodeURIComponent(customerId)}` +
    `&Amount=${encodeURIComponent(amount)}` +
    `&RequestID=${encodeURIComponent(requestId)}` +
    (callbackUrl
      ? `&CallBackURL=${encodeURIComponent(callbackUrl)}`
      : "");

  console.log("[BETTING FUND][REQUEST]", {
    requestedProvider: bettingCompany,
    providerCode,
    customerId,
    amount,
    requestId,
    hasUserId: !!USER_ID,
    hasApiKey: !!API_KEY,
    hasCallbackUrl: !!callbackUrl,
  });

  try {
    const res = await axios.get(url, {
      timeout: 30000,
      validateStatus: () => true,
    });

    console.log("[BETTING FUND][HTTP STATUS]", res.status);
    console.log("[BETTING FUND][RESPONSE]", res.data);

    return {
      ...res.data,
      bettingCompany,
      providerCode,
    };
  } catch (error) {
    console.error("[BETTING FUND][AXIOS ERROR]", {
      message: error.message,
      code: error.code,
      status: error.response?.status,
      response: error.response?.data,
    });

    throw error;
  }
}

module.exports = {
  verifyBettingCustomer,
  fundBettingWallet,
  getBettingProviderCode,
};