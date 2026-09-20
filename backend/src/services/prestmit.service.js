const axios = require("axios");
const crypto = require("crypto");

const BASE_URL = (
  process.env.PRESTMIT_BASE_URL ||
  "https://dev-api.prestmit.io/partners/v1"
).replace(/\/+$/, "");

const API_KEY = process.env.PRESTMIT_API_KEY;
const API_SECRET = process.env.PRESTMIT_SECRET_KEY;

/*
|--------------------------------------------------------------------------
| Logging Helpers
|--------------------------------------------------------------------------
*/

function logSection(title) {
  console.log("");
  console.log("============================================================");
  console.log(`[PRESTMIT] ${title}`);
  console.log("============================================================");
}

function logEnd(title) {
  console.log("------------------------------------------------------------");
  console.log(`[PRESTMIT] END ${title}`);
  console.log("============================================================");
  console.log("");
}

/**
 * Never log sensitive Prestmit credentials.
 */
function sanitizePayload(payload = {}) {
  const safe = { ...payload };

  if (
    Object.prototype.hasOwnProperty.call(
      safe,
      "currentAccountPIN"
    )
  ) {
    safe.currentAccountPIN = "***REDACTED***";
  }

  if (
    Object.prototype.hasOwnProperty.call(
      safe,
      "2fa_code"
    )
  ) {
    safe["2fa_code"] = "***REDACTED***";
  }

  return safe;
}

function sanitizeHeaders(headers = {}) {
  return {
    Accept: headers.Accept,
    "Content-Type": headers["Content-Type"],
    "API-KEY": headers["API-KEY"]
      ? `${String(headers["API-KEY"]).substring(0, 6)}...`
      : undefined,
    "API-HASH": headers["API-HASH"]
      ? "***REDACTED***"
      : undefined,
  };
}

function logJson(label, value) {
  try {
    console.log(
      `[PRESTMIT] ${label}:`,
      JSON.stringify(value, null, 2)
    );
  } catch (_) {
    console.log(`[PRESTMIT] ${label}:`, value);
  }
}

/*
|--------------------------------------------------------------------------
| Credentials
|--------------------------------------------------------------------------
*/

function validateCredentials() {
  if (!API_KEY) {
    throw new Error("PRESTMIT_API_KEY is not configured");
  }

  if (!API_SECRET) {
    throw new Error("PRESTMIT_SECRET_KEY is not configured");
  }
}

/*
|--------------------------------------------------------------------------
| Prestmit Authentication
|--------------------------------------------------------------------------
*/

/**
 * Prestmit authentication:
 *
 * payload = API_KEY + ":" + JSON.stringify(body)
 *
 * HMAC-SHA256(payload, API_SECRET)
 */
function generateApiHash(body = {}) {
  validateCredentials();

  const bodyString = JSON.stringify(body);
  const payload = `${API_KEY}:${bodyString}`;

  return crypto
    .createHmac("sha256", API_SECRET)
    .update(payload, "utf8")
    .digest("hex");
}

function signedHeaders(body = {}) {
  return {
    Accept: "application/json",
    "Content-Type": "application/json",
    "API-KEY": API_KEY,
    "API-HASH": generateApiHash(body),
  };
}

function getHeaders() {
  if (!API_KEY) {
    throw new Error("PRESTMIT_API_KEY is not configured");
  }

  return {
    Accept: "application/json",
    "API-KEY": API_KEY,
  };
}

/*
|--------------------------------------------------------------------------
| Error Handling
|--------------------------------------------------------------------------
*/

function getErrorMessage(error) {
  if (error.response) {
    const responseData = error.response.data;

    console.error("");
    console.error("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    console.error("[PRESTMIT] AXIOS ERROR RESPONSE");
    console.error("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

    console.error(
      "[PRESTMIT] HTTP STATUS:",
      error.response.status
    );

    logJson(
      "ERROR RESPONSE DATA",
      responseData
    );

    console.error(
      "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    );
    console.error("");

    if (typeof responseData === "string") {
      return responseData;
    }

    return (
      responseData?.message ||
      `Prestmit request failed with status ${error.response.status}`
    );
  }

  console.error(
    "[PRESTMIT] NETWORK/REQUEST ERROR:",
    error.message
  );

  return error.message || "Prestmit request failed";
}

/*
|--------------------------------------------------------------------------
| Buy Input Validation
|--------------------------------------------------------------------------
*/

/**
 * Validate common buy parameters.
 */
function normalizeBuyInput({
  giftCardSKU,
  price,
  quantity = 1,
}) {
  const sku = Number(giftCardSKU);
  const amount = Number(price);
  const qty = Number(quantity);

  if (!Number.isInteger(sku) || sku <= 0) {
    throw new Error("giftCardSKU must be a positive integer");
  }

  if (!Number.isFinite(amount) || amount <= 0) {
    throw new Error("price must be greater than 0");
  }

  if (!Number.isInteger(qty) || qty <= 0) {
    throw new Error("quantity must be a positive integer");
  }

  return {
    giftCardSKU: sku,
    price: amount,
    quantity: qty,
  };
}

/*
|--------------------------------------------------------------------------
| Catalog
|--------------------------------------------------------------------------
*/

/**
 * Fetch available gift cards.
 *
 * GET:
 * /giftcard-trade/buy/fetch-buyable-giftcards
 */
async function fetchBuyableGiftCards({
  currencyCode,
  page = 1,
  perPage = 25,
} = {}) {
  const safePage = Number(page);
  const safePerPage = Number(perPage);

  if (!Number.isInteger(safePage) || safePage < 1) {
    throw new Error("page must be at least 1");
  }

  if (
    !Number.isInteger(safePerPage) ||
    safePerPage < 1 ||
    safePerPage > 25
  ) {
    throw new Error("perPage must be between 1 and 25");
  }

  const params = {
    page: safePage,
    perPage: safePerPage,
  };

  if (currencyCode) {
    const code = String(currencyCode).trim().toUpperCase();

    if (!/^[A-Z]{3}$/.test(code)) {
      throw new Error("currencyCode must be a 3-letter currency code");
    }

    params.currencyCode = code;
  }

  logSection("FETCH BUYABLE GIFT CARDS");

  console.log(
    "[PRESTMIT] URL:",
    `${BASE_URL}/giftcard-trade/buy/fetch-buyable-giftcards`
  );

  logJson("QUERY PARAMETERS", params);

  try {
    const response = await axios.get(
      `${BASE_URL}/giftcard-trade/buy/fetch-buyable-giftcards`,
      {
        params,
        headers: getHeaders(),
        timeout: 30000,
      }
    );

    console.log(
      "[PRESTMIT] HTTP STATUS:",
      response.status
    );

    logJson("RESPONSE", response.data);

    logEnd("FETCH BUYABLE GIFT CARDS");

    return response.data;
  } catch (error) {
    throw new Error(getErrorMessage(error));
  }
}

/*
|--------------------------------------------------------------------------
| Configuration
|--------------------------------------------------------------------------
*/

/**
 * Fetch Prestmit buy configuration.
 *
 * Current endpoint:
 * /giftcard-trade/buy/config/v2
 */
async function getBuyConfiguration() {
  logSection("FETCH BUY CONFIGURATION");

  const url =
    `${BASE_URL}/giftcard-trade/buy/config/v2`;

  console.log("[PRESTMIT] URL:", url);

  try {
    const response = await axios.get(
      url,
      {
        headers: getHeaders(),
        timeout: 30000,
      }
    );

    console.log(
      "[PRESTMIT] HTTP STATUS:",
      response.status
    );

    logJson("RESPONSE", response.data);

    logEnd("FETCH BUY CONFIGURATION");

    return response.data;
  } catch (error) {
    throw new Error(getErrorMessage(error));
  }
}

/*
|--------------------------------------------------------------------------
| Check Availability
|--------------------------------------------------------------------------
*/

/**
 * Check whether a specific gift card is available.
 *
 * POST:
 * /giftcard-trade/buy/check-availability
 */
async function checkAvailability({
  giftCardSKU,
  price,
  quantity = 1,
}) {
  const body = normalizeBuyInput({
    giftCardSKU,
    price,
    quantity,
  });

  logSection("CHECK GIFT CARD AVAILABILITY");

  console.log(
    "[PRESTMIT] URL:",
    `${BASE_URL}/giftcard-trade/buy/check-availability`
  );

  logJson("REQUEST BODY", body);

  try {
    const response = await axios.post(
      `${BASE_URL}/giftcard-trade/buy/check-availability`,
      body,
      {
        headers: signedHeaders(body),
        timeout: 30000,
      }
    );

    console.log(
      "[PRESTMIT] HTTP STATUS:",
      response.status
    );

    logJson("RESPONSE", response.data);

    logEnd("CHECK GIFT CARD AVAILABILITY");

    return response.data;
  } catch (error) {
    throw new Error(getErrorMessage(error));
  }
}

/*
|--------------------------------------------------------------------------
| Calculate Payment
|--------------------------------------------------------------------------
*/

/**
 * Calculate the payment amount required by Prestmit.
 *
 * POST:
 * /giftcard-trade/buy/calculate-payment
 */
async function calculatePayment({
  giftCardSKU,
  price,
  quantity = 1,
}) {
  const body = normalizeBuyInput({
    giftCardSKU,
    price,
    quantity,
  });

  logSection("CALCULATE PAYMENT");

  console.log(
    "[PRESTMIT] URL:",
    `${BASE_URL}/giftcard-trade/buy/calculate-payment`
  );

  logJson("REQUEST BODY", body);

  try {
    const response = await axios.post(
      `${BASE_URL}/giftcard-trade/buy/calculate-payment`,
      body,
      {
        headers: signedHeaders(body),
        timeout: 30000,
      }
    );

    console.log(
      "[PRESTMIT] HTTP STATUS:",
      response.status
    );

    logJson("RESPONSE", response.data);

    logEnd("CALCULATE PAYMENT");

    return response.data;
  } catch (error) {
    throw new Error(getErrorMessage(error));
  }
}

/*
|--------------------------------------------------------------------------
| CREATE BUY TRANSACTION
|--------------------------------------------------------------------------
*/

/**
 * Create a Prestmit gift-card purchase.
 *
 * POST:
 * /giftcard-trade/buy/create
 *
 * currentAccountPIN is required by Prestmit for actions
 * that debit the Prestmit account balance.
 */
async function createBuyTransaction({
  giftCardSKU,
  price,
  quantity = 1,
  paymentMethod = "NAIRA",
  uniqueIdentifier,
  currentAccountPIN,
  twoFaCode,
}) {
  const body = {
    ...normalizeBuyInput({
      giftCardSKU,
      price,
      quantity,
    }),
    paymentMethod: String(paymentMethod || "")
      .trim()
      .toUpperCase(),
  };

  if (!body.paymentMethod) {
    throw new Error("paymentMethod is required");
  }

  if (
    uniqueIdentifier !== undefined &&
    uniqueIdentifier !== null &&
    uniqueIdentifier !== ""
  ) {
    body.uniqueIdentifier = String(uniqueIdentifier);
  }

  if (
    currentAccountPIN !== undefined &&
    currentAccountPIN !== null &&
    currentAccountPIN !== ""
  ) {
    const pin = Number(currentAccountPIN);

    if (!Number.isInteger(pin)) {
      throw new Error("currentAccountPIN must be an integer");
    }

    body.currentAccountPIN = pin;
  }

  if (
    twoFaCode !== undefined &&
    twoFaCode !== null &&
    twoFaCode !== ""
  ) {
    const code = Number(twoFaCode);

    if (!Number.isInteger(code)) {
      throw new Error("twoFaCode must be an integer");
    }

    body["2fa_code"] = code;
  }

  logSection("CREATE BUY TRANSACTION");

  const url =
    `${BASE_URL}/giftcard-trade/buy/create`;

  console.log("[PRESTMIT] URL:", url);

  logJson(
    "REQUEST BODY",
    sanitizePayload(body)
  );

  let headers;

  try {
    headers = signedHeaders(body);

    console.log(
      "[PRESTMIT] REQUEST HEADERS:",
      sanitizeHeaders(headers)
    );

    const response = await axios.post(
      url,
      body,
      {
        headers,
        timeout: 60000,
      }
    );

    console.log(
      "[PRESTMIT] HTTP STATUS:",
      response.status
    );

    /*
     * This is the most important log.
     *
     * It shows EXACTLY what Prestmit returned immediately
     * after the transaction was created.
     */
    logJson(
      "RAW CREATE RESPONSE FROM PRESTMIT",
      response.data
    );

    /*
     * Explicitly inspect common transaction fields so they
     * are easy to find in PM2 logs.
     */
    const responseData = response.data;

    const transactionData =
      responseData?.data &&
      typeof responseData.data === "object"
        ? responseData.data
        : responseData;

    console.log(
      "[PRESTMIT] CREATE RESPONSE REFERENCE:",
      transactionData?.reference ??
        transactionData?.transactionReference ??
        transactionData?.transactionId ??
        "NOT FOUND"
    );

    console.log(
      "[PRESTMIT] CREATE RESPONSE STATUS:",
      transactionData?.status ??
        "NOT FOUND"
    );

    console.log(
      "[PRESTMIT] CREATE RESPONSE UNIQUE IDENTIFIER:",
      transactionData?.uniqueIdentifier ??
        body.uniqueIdentifier ??
        "NOT FOUND"
    );

    console.log(
      "[PRESTMIT] CREATE RESPONSE PAYMENT METHOD:",
      transactionData?.paymentMethod ??
        body.paymentMethod ??
        "NOT FOUND"
    );

    console.log(
      "[PRESTMIT] CREATE RESPONSE TOTAL PAYMENT:",
      transactionData?.totalPaymentAmount ??
        "NOT FOUND"
    );

    logEnd("CREATE BUY TRANSACTION");

    return response.data;
  } catch (error) {
    console.error("");
    console.error(
      "[PRESTMIT] CREATE BUY TRANSACTION FAILED"
    );

    throw new Error(getErrorMessage(error));
  }
}

/*
|--------------------------------------------------------------------------
| FETCH GIFT CARD CODES
|--------------------------------------------------------------------------
*/

/**
 * Fetch delivered gift-card codes.
 *
 * GET:
 * /giftcard-trade/buy/fetch-codes/{reference}
 */
async function fetchGiftCardCodes(reference) {
  if (!reference) {
    throw new Error(
      "Prestmit transaction reference is required"
    );
  }

  const safeReference = String(reference).trim();

  logSection("FETCH GIFT CARD CODES");

  const url =
    `${BASE_URL}/giftcard-trade/buy/fetch-codes/` +
    encodeURIComponent(safeReference);

  console.log(
    "[PRESTMIT] TRANSACTION REFERENCE:",
    safeReference
  );

  console.log(
    "[PRESTMIT] URL:",
    url
  );

  try {
    const response = await axios.get(
      url,
      {
        headers: getHeaders(),
        timeout: 30000,
      }
    );

    console.log(
      "[PRESTMIT] HTTP STATUS:",
      response.status
    );

    /*
     * This will tell us exactly what Prestmit gives us
     * when we ask for the completed gift-card code.
     */
    logJson(
      "RAW GIFT CARD CODE RESPONSE",
      response.data
    );

    const responseData = response.data;

    const codeData =
      responseData?.data &&
      typeof responseData.data === "object"
        ? responseData.data
        : responseData;

    console.log(
      "[PRESTMIT] CARD NUMBER:",
      codeData?.cardNumber
        ? "***AVAILABLE***"
        : "NOT RETURNED"
    );

    console.log(
      "[PRESTMIT] PIN CODE:",
      codeData?.pinCode
        ? "***AVAILABLE***"
        : "NOT RETURNED"
    );

    console.log(
      "[PRESTMIT] CLAIM URL:",
      codeData?.claimUrl
        ? codeData.claimUrl
        : "NOT RETURNED"
    );

    console.log(
      "[PRESTMIT] EXPIRY DATE:",
      codeData?.expireDate ??
        "NOT RETURNED"
    );

    logEnd("FETCH GIFT CARD CODES");

    return response.data;
  } catch (error) {
    console.error(
      "[PRESTMIT] FETCH GIFT CARD CODES FAILED"
    );

    throw new Error(getErrorMessage(error));
  }
}

/*
|--------------------------------------------------------------------------
| BUY HISTORY
|--------------------------------------------------------------------------
*/

/**
 * Fetch Prestmit gift-card purchase history.
 *
 * GET:
 * /giftcard-trade/buy/history
 */
async function getBuyHistory({
  page = 1,
  perPage = 10,
  referenceOrID,
  uniqueIdentifier,
} = {}) {
  const safePage = Number(page);
  const safePerPage = Number(perPage);

  if (!Number.isInteger(safePage) || safePage < 1) {
    throw new Error("page must be at least 1");
  }

  if (
    !Number.isInteger(safePerPage) ||
    safePerPage < 1 ||
    safePerPage > 25
  ) {
    throw new Error("perPage must be between 1 and 25");
  }

  const params = {
    page: safePage,
    perPage: safePerPage,
  };

  if (referenceOrID) {
    params.referenceOrID = String(referenceOrID);
  }

  if (uniqueIdentifier) {
    params.uniqueIdentifier = String(uniqueIdentifier);
  }

  logSection("FETCH BUY TRANSACTION HISTORY");

  const url =
    `${BASE_URL}/giftcard-trade/buy/history`;

  console.log("[PRESTMIT] URL:", url);

  logJson("QUERY PARAMETERS", params);

  try {
    const response = await axios.get(
      url,
      {
        params,
        headers: getHeaders(),
        timeout: 30000,
      }
    );

    console.log(
      "[PRESTMIT] HTTP STATUS:",
      response.status
    );

    /*
     * This is especially important for your current issue.
     *
     * Prestmit may initially return PENDING from /create,
     * while the transaction is already COMPLETED by the time
     * /history is queried.
     */
    logJson(
      "RAW BUY HISTORY RESPONSE FROM PRESTMIT",
      response.data
    );

    const historyData = response.data;

    const transactions =
      Array.isArray(historyData?.data)
        ? historyData.data
        : Array.isArray(historyData?.data?.data)
          ? historyData.data.data
          : Array.isArray(historyData)
            ? historyData
            : [];

    console.log(
      "[PRESTMIT] TRANSACTION COUNT:",
      transactions.length
    );

    if (transactions.length > 0) {
      transactions.forEach((transaction, index) => {
        console.log("");
        console.log(
          `[PRESTMIT] TRANSACTION #${index + 1}`
        );

        console.log(
          "[PRESTMIT] ID:",
          transaction?.id ??
            transaction?.transactionId ??
            "NOT FOUND"
        );

        console.log(
          "[PRESTMIT] REFERENCE:",
          transaction?.reference ??
            transaction?.transactionReference ??
            "NOT FOUND"
        );

        console.log(
          "[PRESTMIT] STATUS:",
          transaction?.status ??
            "NOT FOUND"
        );

        console.log(
          "[PRESTMIT] UNIQUE IDENTIFIER:",
          transaction?.uniqueIdentifier ??
            "NOT FOUND"
        );

        console.log(
          "[PRESTMIT] GIFT CARD SKU:",
          transaction?.giftCardSKU ??
            transaction?.sku ??
            "NOT FOUND"
        );

        console.log(
          "[PRESTMIT] GIFT CARD AMOUNT:",
          transaction?.price ??
            transaction?.giftCardAmount ??
            "NOT FOUND"
        );

        console.log(
          "[PRESTMIT] PAYMENT METHOD:",
          transaction?.paymentMethod ??
            "NOT FOUND"
        );

        console.log(
          "[PRESTMIT] TOTAL PAYMENT:",
          transaction?.totalPaymentAmount ??
            transaction?.payableAmount ??
            "NOT FOUND"
        );
      });
    } else {
      console.log(
        "[PRESTMIT] NO TRANSACTIONS FOUND FOR THIS QUERY."
      );
    }

    logEnd("FETCH BUY TRANSACTION HISTORY");

    return response.data;
  } catch (error) {
    console.error(
      "[PRESTMIT] FETCH BUY HISTORY FAILED"
    );

    throw new Error(getErrorMessage(error));
  }
}

/*
|--------------------------------------------------------------------------
| WEBHOOK SIGNATURE
|--------------------------------------------------------------------------
*/

/**
 * Verify Prestmit webhook signature.
 *
 * Prestmit:
 * HMAC-SHA256(raw request body, webhook secret)
 * encoded as Base64.
 */
function verifyWebhookSignature(rawBody, signature) {
  const webhookSecret =
    process.env.PRESTMIT_WEBHOOK_SECRET;

  if (!webhookSecret) {
    throw new Error(
      "PRESTMIT_WEBHOOK_SECRET is not configured"
    );
  }

  if (!signature) {
    console.warn(
      "[PRESTMIT WEBHOOK] Missing signature"
    );

    return false;
  }

  if (!rawBody) {
    console.warn(
      "[PRESTMIT WEBHOOK] Missing raw request body"
    );

    return false;
  }

  const expectedSignature = crypto
    .createHmac("sha256", webhookSecret)
    .update(rawBody)
    .digest("base64");

  const suppliedBuffer = Buffer.from(
    String(signature),
    "utf8"
  );

  const expectedBuffer = Buffer.from(
    expectedSignature,
    "utf8"
  );

  if (
    suppliedBuffer.length !==
    expectedBuffer.length
  ) {
    console.warn(
      "[PRESTMIT WEBHOOK] Signature length mismatch"
    );

    return false;
  }

  const valid = crypto.timingSafeEqual(
    suppliedBuffer,
    expectedBuffer
  );

  console.log(
    "[PRESTMIT WEBHOOK] Signature valid:",
    valid
  );

  return valid;
}

/*
|--------------------------------------------------------------------------
| Exports
|--------------------------------------------------------------------------
*/

module.exports = {
  fetchBuyableGiftCards,
  getBuyConfiguration,
  checkAvailability,
  calculatePayment,
  createBuyTransaction,
  fetchGiftCardCodes,
  getBuyHistory,
  verifyWebhookSignature,
};