const axios = require("axios");
const crypto = require("crypto");

const BASE_URL =
  process.env.PRESTMIT_BASE_URL ||
  "https://dev-api.prestmit.io/partners/v1";

const API_KEY = process.env.PRESTMIT_API_KEY;
const API_SECRET = process.env.PRESTMIT_SECRET_KEY;

function ensureCredentials() {
  if (!API_KEY) {
    throw new Error("PRESTMIT_API_KEY is not configured");
  }

  if (!API_SECRET) {
    throw new Error("PRESTMIT_SECRET_KEY is not configured");
  }
}

/**
 * Creates the Prestmit API hash.
 *
 * Prestmit documentation:
 *
 * payload = API_KEY + ":" + JSON.stringify(body)
 *
 * IMPORTANT:
 * For multipart POST requests, attachments must NOT be included
 * in the body used to generate the hash.
 */
function generateApiHash(body = {}) {
  ensureCredentials();

  const bodyString = JSON.stringify(body);

  const payload = `${API_KEY}:${bodyString}`;

  return crypto
    .createHmac("sha256", API_SECRET)
    .update(payload, "utf8")
    .digest("hex");
}

/**
 * Build headers for signed Prestmit requests.
 */
function signedHeaders(body = {}, extraHeaders = {}) {
  ensureCredentials();

  return {
    Accept: "application/json",
    "API-KEY": API_KEY,
    "API-HASH": generateApiHash(body),
    ...extraHeaders,
  };
}

/**
 * Basic headers for endpoints where Prestmit does not require
 * a signed body.
 */
function basicHeaders() {
  ensureCredentials();

  return {
    Accept: "application/json",
    "API-KEY": API_KEY,
  };
}

/**
 * Remove undefined/null optional fields while preserving
 * legitimate false / zero values.
 */
function cleanObject(object = {}) {
  return Object.fromEntries(
    Object.entries(object).filter(
      ([, value]) => value !== undefined && value !== null
    )
  );
}

/**
 * Normalize a Prestmit error into a useful Error.
 */
function normalizeAxiosError(error, operation) {
  const responseData = error?.response?.data;

  if (responseData) {
    const details =
      responseData.message ||
      responseData.details ||
      responseData.error ||
      responseData.errors ||
      JSON.stringify(responseData);

    const normalized = new Error(
      `Prestmit ${operation} failed: ${details}`
    );

    normalized.status = error?.response?.status;
    normalized.response = responseData;

    return normalized;
  }

  const normalized = new Error(
    `Prestmit ${operation} failed: ${error.message}`
  );

  normalized.status = error?.response?.status;

  return normalized;
}

/**
 * GET /giftcard-trade/sell/rate-calculator-data
 *
 * Returns:
 * - giftCardCategories
 * - sellableGiftcards
 * - sellGiftcardPayoutMethods
 * - rateConversions
 */
async function getSellRateCalculatorData() {
  try {
    const response = await axios.get(
      `${BASE_URL}/giftcard-trade/sell/rate-calculator-data`,
      {
        headers: basicHeaders(),
        timeout: 30000,
      }
    );

    return response.data;
  } catch (error) {
    throw normalizeAxiosError(
      error,
      "sell rate calculator request"
    );
  }
}

/**
 * GET /giftcard-trade/sell/payout-methods
 */
async function getSellPayoutMethods() {
  try {
    const response = await axios.get(
      `${BASE_URL}/giftcard-trade/sell/payout-methods`,
      {
        headers: basicHeaders(),
        timeout: 30000,
      }
    );

    return response.data;
  } catch (error) {
    throw normalizeAxiosError(
      error,
      "sell payout methods request"
    );
  }
}

/**
 * GET /lookup/sell-giftcard-categories
 */
async function getSellGiftcardCategories() {
  try {
    const response = await axios.get(
      `${BASE_URL}/lookup/sell-giftcard-categories`,
      {
        headers: basicHeaders(),
        timeout: 30000,
      }
    );

    return response.data;
  } catch (error) {
    throw normalizeAxiosError(
      error,
      "sell gift card categories request"
    );
  }
}

/**
 * GET /lookup/sell-giftcard-subcategories
 */
async function getSellGiftcardSubcategories(params = {}) {
  try {
    const query = cleanObject(params);

    const response = await axios.get(
      `${BASE_URL}/lookup/sell-giftcard-subcategories`,
      {
        params: query,
        headers: basicHeaders(),
        timeout: 30000,
      }
    );

    return response.data;
  } catch (error) {
    throw normalizeAxiosError(
      error,
      "sell gift card subcategories request"
    );
  }
}

/**
 * GET /lookup/sell-giftcard-filters
 */
async function getSellGiftcardFilters(params = {}) {
  try {
    const query = cleanObject(params);

    const response = await axios.get(
      `${BASE_URL}/lookup/sell-giftcard-filters`,
      {
        params: query,
        headers: basicHeaders(),
        timeout: 30000,
      }
    );

    return response.data;
  } catch (error) {
    throw normalizeAxiosError(
      error,
      "sell gift card filters request"
    );
  }
}

/**
 * GET /lookup/sell-giftcard-countries
 */
async function getSellGiftcardCountries() {
  try {
    const response = await axios.get(
      `${BASE_URL}/lookup/sell-giftcard-countries`,
      {
        headers: basicHeaders(),
        timeout: 30000,
      }
    );

    return response.data;
  } catch (error) {
    throw normalizeAxiosError(
      error,
      "sell gift card countries request"
    );
  }
}

/**
 * Create a SELL transaction.
 *
 * Prestmit endpoint:
 * POST /giftcard-trade/sell/create
 *
 * Multipart fields:
 * - giftcard_id
 * - amount
 * - payoutMethod
 * - comments
 * - uniqueIdentifier
 * - attachments[]
 *
 * IMPORTANT:
 * The attachments are NOT included in the API-HASH.
 *
 * files is expected to be an array of multer memoryStorage files:
 *
 * {
 *   buffer,
 *   originalname,
 *   mimetype,
 *   size
 * }
 */
async function createSellTransaction({
  giftcard_id,
  amount,
  payoutMethod,
  comments,
  uniqueIdentifier,
  files = [],
}) {
  ensureCredentials();

  if (
    giftcard_id === undefined ||
    giftcard_id === null ||
    giftcard_id === ""
  ) {
    throw new Error("giftcard_id is required");
  }

  if (
    amount === undefined ||
    amount === null ||
    amount === ""
  ) {
    throw new Error("amount is required");
  }

  if (!payoutMethod) {
    throw new Error("payoutMethod is required");
  }

  if (!Array.isArray(files)) {
    throw new Error("files must be an array");
  }

  if (files.length > 20) {
    throw new Error(
      "A maximum of 20 gift card images can be submitted"
    );
  }

  for (const file of files) {
    if (!file?.buffer) {
      throw new Error(
        "One or more uploaded files do not contain a valid buffer"
      );
    }

    if (!["image/jpeg", "image/png"].includes(file.mimetype)) {
      throw new Error(
        "Only JPG and PNG gift card images are accepted"
      );
    }

    if (file.size > 5 * 1024 * 1024) {
      throw new Error(
        `Gift card image ${file.originalname || ""} exceeds the 5MB limit`
      );
    }
  }

  /**
   * This is the exact logical request body used for hashing.
   *
   * attachments are intentionally excluded.
   */
  const signedBody = cleanObject({
    giftcard_id: Number(giftcard_id),
    amount: Number(amount),
    payoutMethod: String(payoutMethod),
    comments:
      comments !== undefined && comments !== null
        ? String(comments)
        : undefined,
    uniqueIdentifier:
      uniqueIdentifier !== undefined &&
      uniqueIdentifier !== null
        ? String(uniqueIdentifier)
        : undefined,
  });

  /**
   * Use native FormData/Blob available in modern Node.js.
   */
  const form = new FormData();

  form.append(
    "giftcard_id",
    String(signedBody.giftcard_id)
  );

  form.append(
    "amount",
    String(signedBody.amount)
  );

  form.append(
    "payoutMethod",
    signedBody.payoutMethod
  );

  if (signedBody.comments !== undefined) {
    form.append("comments", signedBody.comments);
  }

  if (signedBody.uniqueIdentifier !== undefined) {
    form.append(
      "uniqueIdentifier",
      signedBody.uniqueIdentifier
    );
  }

  for (const file of files) {
    const blob = new Blob(
      [file.buffer],
      {
        type: file.mimetype,
      }
    );

    form.append(
      "attachments[]",
      blob,
      file.originalname || "giftcard-image"
    );
  }

  /**
   * Do NOT manually set Content-Type.
   *
   * Axios/native FormData will generate the correct
   * multipart boundary.
   */
  const headers = signedHeaders(signedBody);

  for (const [key, value] of Object.entries(headers)) {
    form.append(
      `__header_${key}`,
      ""
    );
  }

  /**
   * Convert headers separately because FormData should only
   * contain actual request fields.
   */
  const requestHeaders = {
    Accept: "application/json",
    "API-KEY": API_KEY,
    "API-HASH": generateApiHash(signedBody),
  };

  try {
    const response = await axios.post(
      `${BASE_URL}/giftcard-trade/sell/create`,
      form,
      {
        headers: requestHeaders,
        timeout: 120000,
        maxContentLength: Infinity,
        maxBodyLength: Infinity,
      }
    );

    return response.data;
  } catch (error) {
    throw normalizeAxiosError(
      error,
      "sell transaction creation"
    );
  }
}

/**
 * GET /giftcard-trade/sell/history
 */
async function getSellHistory({
  page = 1,
  perPage,
  uniqueIdentifier,
  referenceOrID,
} = {}) {
  try {
    const params = cleanObject({
      page,
      perPage,
      uniqueIdentifier,
      referenceOrID,
    });

    const response = await axios.get(
      `${BASE_URL}/giftcard-trade/sell/history`,
      {
        params,
        headers: basicHeaders(),
        timeout: 30000,
      }
    );

    return response.data;
  } catch (error) {
    throw normalizeAxiosError(
      error,
      "sell history request"
    );
  }
}

/**
 * Get a single SELL transaction through Prestmit history.
 */
async function getSellTransaction(reference) {
  if (!reference) {
    throw new Error(
      "Prestmit sell reference is required"
    );
  }

  const result = await getSellHistory({
    referenceOrID: reference,
    page: 1,
    perPage: 1,
  });

  return result;
}

module.exports = {
  BASE_URL,
  generateApiHash,
  getSellRateCalculatorData,
  getSellPayoutMethods,
  getSellGiftcardCategories,
  getSellGiftcardSubcategories,
  getSellGiftcardFilters,
  getSellGiftcardCountries,
  createSellTransaction,
  getSellHistory,
  getSellTransaction,
};