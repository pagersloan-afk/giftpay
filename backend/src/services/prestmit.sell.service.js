const axios = require("axios");
const crypto = require("crypto");

const BASE_URL =
  process.env.PRESTMIT_BASE_URL ||
  "https://dev-api.prestmit.io/partners/v1";

const API_KEY = process.env.PRESTMIT_API_KEY;
const API_SECRET = process.env.PRESTMIT_SECRET_KEY;

/**
 * ============================================================
 * PRESTMIT SELL DEBUG LOGGING
 * ============================================================
 *
 * These logs are intentionally detailed so we can see exactly
 * what Prestmit returns to GiftPay.
 *
 * IMPORTANT:
 * - API keys are never logged.
 * - API hashes are never logged.
 * - Secrets are never logged.
 * - Firebase/Bearer tokens are never logged.
 * - Gift card codes/comments are redacted from logs.
 */

const DEBUG_SELL_RESPONSES =
  process.env.PRESTMIT_SELL_DEBUG !== "false";

function sellLog(label, data = null) {
  if (!DEBUG_SELL_RESPONSES) {
    return;
  }

  console.log(
    "\n============================================================"
  );

  console.log(
    `[PRESTMIT SELL] ${label}`
  );

  console.log(
    "============================================================"
  );

  if (
    data !== null &&
    data !== undefined
  ) {
    try {
      console.log(
        JSON.stringify(
          data,
          null,
          2
        )
      );
    } catch (error) {
      console.log(
        "[PRESTMIT SELL] Unable to stringify log data:",
        error.message
      );
    }
  }

  console.log(
    "============================================================\n"
  );
}

/**
 * ============================================================
 * SANITIZE PROVIDER DATA FOR LOGGING
 * ============================================================
 *
 * Never allow an E-code or sensitive trade comment to appear
 * in application logs, even if Prestmit echoes it back inside
 * an error or response object.
 */
function sanitizeForLog(
  value,
  key = ""
) {
  if (
    value === null ||
    value === undefined
  ) {
    return value;
  }

  const normalizedKey =
    String(key)
      .toLowerCase()
      .replace(/[_-]/g, "");

  const sensitiveKeys = new Set([
    "comments",
    "comment",
    "ecode",
    "giftcardcode",
    "giftcardcodes",
    "code",
    "authorization",
    "apikey",
    "apihash",
    "secret",
    "token",
    "accesstoken",
    "refreshtoken",
    "cookie",
    "setcookie",
  ]);

  if (
    sensitiveKeys.has(
      normalizedKey
    )
  ) {
    return "[REDACTED]";
  }

  if (Buffer.isBuffer(value)) {
    return "[BUFFER REDACTED]";
  }

  if (Array.isArray(value)) {
    return value.map(
      (item) =>
        sanitizeForLog(
          item
        )
    );
  }

  if (
    typeof value ===
    "object"
  ) {
    const result = {};

    for (
      const [childKey, childValue] of Object.entries(
        value
      )
    ) {
      result[childKey] =
        sanitizeForLog(
          childValue,
          childKey
        );
    }

    return result;
  }

  return value;
}

/**
 * ============================================================
 * LOG COMPLETE PRESTMIT RESPONSE
 * ============================================================
 */
function logPrestmitResponse(
  operation,
  response
) {
  if (!DEBUG_SELL_RESPONSES) {
    return;
  }

  const safeHeaders = {};

  if (response?.headers) {
    for (
      const [key, value] of Object.entries(
        response.headers
      )
    ) {
      const normalizedKey =
        String(key).toLowerCase();

      if (
        normalizedKey ===
          "authorization" ||
        normalizedKey ===
          "api-key" ||
        normalizedKey ===
          "api-hash" ||
        normalizedKey ===
          "cookie" ||
        normalizedKey ===
          "set-cookie"
      ) {
        continue;
      }

      safeHeaders[key] =
        value;
    }
  }

  const responseBody =
    sanitizeForLog(
      response?.data
    );

  let serializedBody;

  try {
    serializedBody =
      JSON.stringify(
        responseBody,
        null,
        2
      );
  } catch (_) {
    serializedBody =
      String(responseBody);
  }

  sellLog(
    `${operation} RESPONSE`,
    {
      timestamp:
        new Date().toISOString(),

      operation,

      status:
        response?.status,

      statusText:
        response?.statusText,

      contentType:
        response?.headers?.[
          "content-type"
        ] || null,

      contentLength:
        response?.headers?.[
          "content-length"
        ] ||
        Buffer.byteLength(
          serializedBody || "",
          "utf8"
        ),

      url:
        response?.config?.url ||
        null,

      method:
        response?.config?.method ||
        null,

      headers:
        safeHeaders,

      data:
        responseBody,
    }
  );
}

/**
 * ============================================================
 * LOG PRESTMIT ERROR
 * ============================================================
 */
function logPrestmitError(
  operation,
  error
) {
  if (!DEBUG_SELL_RESPONSES) {
    return;
  }

  const response =
    error?.response;

  const responseData =
    sanitizeForLog(
      response?.data
    );

  const safeHeaders = {};

  if (response?.headers) {
    for (
      const [key, value] of Object.entries(
        response.headers
      )
    ) {
      const normalizedKey =
        String(key).toLowerCase();

      if (
        normalizedKey ===
          "authorization" ||
        normalizedKey ===
          "api-key" ||
        normalizedKey ===
          "api-hash" ||
        normalizedKey ===
          "cookie" ||
        normalizedKey ===
          "set-cookie"
      ) {
        continue;
      }

      safeHeaders[key] =
        value;
    }
  }

  sellLog(
    `${operation} ERROR RESPONSE`,
    {
      timestamp:
        new Date().toISOString(),

      operation,

      message:
        error?.message || null,

      code:
        error?.code || null,

      status:
        response?.status || null,

      statusText:
        response?.statusText || null,

      url:
        response?.config?.url ||
        null,

      method:
        response?.config?.method ||
        null,

      headers:
        safeHeaders,

      data:
        responseData,
    }
  );
}

/**
 * ============================================================
 * CREDENTIALS
 * ============================================================
 */
function ensureCredentials() {
  if (!API_KEY) {
    throw new Error(
      "PRESTMIT_API_KEY is not configured"
    );
  }

  if (!API_SECRET) {
    throw new Error(
      "PRESTMIT_SECRET_KEY is not configured"
    );
  }
}

/**
 * ============================================================
 * CLEAN OBJECT
 * ============================================================
 *
 * Remove undefined/null values while preserving:
 * - 0
 * - false
 * - empty strings when intentionally supplied
 */
function cleanObject(
  object = {}
) {
  return Object.fromEntries(
    Object.entries(
      object
    ).filter(
      ([, value]) =>
        value !==
          undefined &&
        value !== null
    )
  );
}

/**
 * ============================================================
 * API HASH
 * ============================================================
 *
 * Prestmit:
 *
 * payload =
 *   API_KEY + ":" + JSON.stringify(body)
 *
 * hash =
 *   HMAC-SHA256(payload, API_SECRET)
 *
 * IMPORTANT:
 * attachments[] are deliberately excluded from the body used
 * to generate API-HASH.
 */
function generateApiHash(
  body = {}
) {
  ensureCredentials();

  const bodyString =
    JSON.stringify(body);

  const payload =
    `${API_KEY}:${bodyString}`;

  return crypto
    .createHmac(
      "sha256",
      API_SECRET
    )
    .update(
      payload,
      "utf8"
    )
    .digest("hex");
}

/**
 * ============================================================
 * SIGNED HEADERS
 * ============================================================
 */
function signedHeaders(
  body = {},
  extraHeaders = {}
) {
  ensureCredentials();

  return {
    Accept:
      "application/json",

    "API-KEY":
      API_KEY,

    "API-HASH":
      generateApiHash(
        body
      ),

    ...extraHeaders,
  };
}

/**
 * ============================================================
 * NORMALIZE AXIOS ERROR
 * ============================================================
 */
function normalizeAxiosError(
  error,
  operation
) {
  logPrestmitError(
    operation,
    error
  );

  const response =
    error?.response;

  const responseData =
    response?.data;

  let details;

  if (responseData) {
    if (
      typeof responseData ===
      "string"
    ) {
      details =
        responseData;
    } else {
      details =
        responseData.message ||
        responseData.details ||
        responseData.error ||
        responseData.errors ||
        JSON.stringify(
          sanitizeForLog(
            responseData
          )
        );
    }
  }

  if (!details) {
    details =
      error?.message ||
      "Unknown Prestmit error";
  }

  const normalized =
    new Error(
      `Prestmit ${operation} failed: ${details}`
    );

  normalized.status =
    response?.status;

  normalized.response =
    responseData;

  return normalized;
}

/**
 * ============================================================
 * SIGNED GET
 * ============================================================
 */
async function signedGet(
  path,
  params = {},
  operation = "GET request"
) {
  const query =
    cleanObject(
      params
    );

  const requestUrl =
    `${BASE_URL}${path}`;

  sellLog(
    `${operation} REQUEST`,
    {
      timestamp:
        new Date().toISOString(),

      method:
        "GET",

      url:
        requestUrl,

      params:
        sanitizeForLog(
          query
        ),
    }
  );

  try {
    const response =
      await axios.get(
        requestUrl,
        {
          params:
            query,

          headers:
            signedHeaders(
              query
            ),

          timeout:
            30000,
        }
      );

    logPrestmitResponse(
      operation,
      response
    );

    return response.data;
  } catch (error) {
    throw normalizeAxiosError(
      error,
      operation
    );
  }
}

/**
 * ============================================================
 * SELL RATE CALCULATOR
 * ============================================================
 */
async function getSellRateCalculatorData() {
  return signedGet(
    "/giftcard-trade/sell/rate-calculator-data",
    {},
    "SELL RATE CALCULATOR"
  );
}

/**
 * ============================================================
 * SELL PAYOUT METHODS
 * ============================================================
 */
async function getSellPayoutMethods() {
  return signedGet(
    "/giftcard-trade/sell/payout-methods",
    {},
    "SELL PAYOUT METHODS"
  );
}

/**
 * ============================================================
 * SELL GIFT CARD CATEGORIES
 * ============================================================
 */
async function getSellGiftcardCategories(
  params = {}
) {
  return signedGet(
    "/lookup/sell-giftcard-categories",
    params,
    "SELL GIFTCARD CATEGORIES"
  );
}

/**
 * ============================================================
 * SELL GIFT CARD SUBCATEGORIES
 * ============================================================
 */
async function getSellGiftcardSubcategories(
  params = {}
) {
  return signedGet(
    "/lookup/sell-giftcard-subcategories",
    params,
    "SELL GIFTCARD SUBCATEGORIES"
  );
}

/**
 * ============================================================
 * SELL GIFTCARD FILTERS
 * ============================================================
 */
async function getSellGiftcardFilters(
  params = {}
) {
  return signedGet(
    "/lookup/sell-giftcard-filters",
    params,
    "SELL GIFTCARD FILTERS"
  );
}

/**
 * ============================================================
 * SELL GIFTCARD COUNTRIES
 * ============================================================
 */
async function getSellGiftcardCountries(
  params = {}
) {
  return signedGet(
    "/lookup/sell-giftcard-countries",
    params,
    "SELL GIFTCARD COUNTRIES"
  );
}

/**
 * ============================================================
 * CREATE SELL TRANSACTION
 * ============================================================
 *
 * POST /giftcard-trade/sell/create
 *
 * multipart/form-data
 */
async function createSellTransaction({
  giftcard_id,
  amount,
  payoutMethod,
  comments,
  uniqueIdentifier,
  payoutAddress,
  promoCode,
  files = [],
}) {
  ensureCredentials();

  // ==========================================================
  // GIFTCARD ID
  // ==========================================================

  if (
    giftcard_id ===
      undefined ||
    giftcard_id === null ||
    giftcard_id === ""
  ) {
    throw new Error(
      "giftcard_id is required"
    );
  }

  const normalizedGiftcardId =
    Number(
      giftcard_id
    );

  if (
    !Number.isInteger(
      normalizedGiftcardId
    ) ||
    normalizedGiftcardId <= 0
  ) {
    throw new Error(
      "giftcard_id must be a valid positive integer"
    );
  }

  // ==========================================================
  // AMOUNT
  // ==========================================================

  if (
    amount === undefined ||
    amount === null ||
    amount === ""
  ) {
    throw new Error(
      "amount is required"
    );
  }

  const normalizedAmount =
    Number(amount);

  if (
    !Number.isFinite(
      normalizedAmount
    ) ||
    normalizedAmount <= 0
  ) {
    throw new Error(
      "amount must be a valid positive number"
    );
  }

  // ==========================================================
  // PAYOUT METHOD
  // ==========================================================

  if (
    payoutMethod ===
      undefined ||
    payoutMethod === null ||
    String(
      payoutMethod
    ).trim() === ""
  ) {
    throw new Error(
      "payoutMethod is required"
    );
  }

  const normalizedPayoutMethod =
    String(
      payoutMethod
    ).trim();

  // ==========================================================
  // FILE VALIDATION
  // ==========================================================

  if (!Array.isArray(files)) {
    throw new Error(
      "files must be an array"
    );
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

    const mimetype =
      String(
        file.mimetype || ""
      ).toLowerCase();

    if (
      mimetype !==
        "image/jpeg" &&
      mimetype !==
        "image/png"
    ) {
      throw new Error(
        "Only JPG and PNG gift card images are accepted"
      );
    }

    const size =
      Number(file.size) ||
      file.buffer.length;

    if (
      size >
      5 * 1024 * 1024
    ) {
      throw new Error(
        `Gift card image ${
          file.originalname || ""
        } exceeds the 5MB limit`
      );
    }
  }

  // ==========================================================
  // SIGNED BODY
  // ==========================================================
  //
  // IMPORTANT:
  //
  // The signed body must contain exactly the non-file request
  // fields that are actually sent to Prestmit.
  //
  // attachments[] are intentionally excluded.
  //
  // The object insertion order is preserved so JSON.stringify()
  // produces the same field order used by the request.
  // ==========================================================

  const signedBody =
    cleanObject({
      giftcard_id:
        normalizedGiftcardId,

      amount:
        normalizedAmount,

      payoutMethod:
        normalizedPayoutMethod,

      comments:
        comments !==
            undefined &&
        comments !== null
          ? String(
              comments
            )
          : undefined,

      uniqueIdentifier:
        uniqueIdentifier !==
            undefined &&
        uniqueIdentifier !== null
          ? String(
              uniqueIdentifier
            )
          : undefined,

      payoutAddress:
        payoutAddress !==
            undefined &&
        payoutAddress !== null
          ? String(
              payoutAddress
            )
          : undefined,

      promoCode:
        promoCode !==
            undefined &&
        promoCode !== null
          ? String(
              promoCode
            )
          : undefined,
    });

  // ==========================================================
  // REQUEST DEBUG LOG
  // ==========================================================
  //
  // Do NOT log signedBody because comments may contain the
  // actual gift card E-code.
  // ==========================================================

  sellLog(
    "SELL CREATE REQUEST",
    {
      timestamp:
        new Date().toISOString(),

      method:
        "POST",

      url:
        `${BASE_URL}/giftcard-trade/sell/create`,

      giftcard_id:
        normalizedGiftcardId,

      amount:
        normalizedAmount,

      payoutMethod:
        normalizedPayoutMethod,

      hasComments:
        Boolean(
          comments !==
              undefined &&
          comments !== null &&
          String(
            comments
          ).trim()
        ),

      hasUniqueIdentifier:
        Boolean(
          uniqueIdentifier
        ),

      hasPayoutAddress:
        Boolean(
          payoutAddress
        ),

      hasPromoCode:
        Boolean(
          promoCode
        ),

      attachmentCount:
        files.length,

      attachmentNames:
        files.map(
          (file) =>
            file?.originalname ||
            "unknown"
        ),
    }
  );

  // ==========================================================
  // FORM DATA
  // ==========================================================

  const form =
    new FormData();

  // Required fields.

  form.append(
    "giftcard_id",
    String(
      normalizedGiftcardId
    )
  );

  form.append(
    "amount",
    String(
      normalizedAmount
    )
  );

  form.append(
    "payoutMethod",
    normalizedPayoutMethod
  );

  // Optional text fields.

  if (
    signedBody.comments !==
    undefined
  ) {
    form.append(
      "comments",
      signedBody.comments
    );
  }

  if (
    signedBody.uniqueIdentifier !==
    undefined
  ) {
    form.append(
      "uniqueIdentifier",
      signedBody.uniqueIdentifier
    );
  }

  if (
    signedBody.payoutAddress !==
    undefined
  ) {
    form.append(
      "payoutAddress",
      signedBody.payoutAddress
    );
  }

  if (
    signedBody.promoCode !==
    undefined
  ) {
    form.append(
      "promoCode",
      signedBody.promoCode
    );
  }

  // ==========================================================
  // ATTACHMENTS
  // ==========================================================
  //
  // Native FormData + Blob is intentionally used here.
  //
  // Do NOT manually add a Content-Type header. Axios must
  // generate the multipart boundary.
  // ==========================================================

  for (const file of files) {
    const blob =
      new Blob(
        [
          file.buffer,
        ],
        {
          type:
            file.mimetype,
        }
      );

    form.append(
      "attachments[]",
      blob,
      file.originalname ||
        "giftcard-image"
    );
  }

  // ==========================================================
  // AUTH HEADERS
  // ==========================================================

  const requestHeaders =
    signedHeaders(
      signedBody
    );

  // ==========================================================
  // SEND TO PRESTMIT
  // ==========================================================

  try {
    const response =
      await axios.post(
        `${BASE_URL}/giftcard-trade/sell/create`,
        form,
        {
          headers:
            requestHeaders,

          timeout:
            120000,

          maxContentLength:
            Infinity,

          maxBodyLength:
            Infinity,
        }
      );

    logPrestmitResponse(
      "SELL CREATE",
      response
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
 * ============================================================
 * SELL HISTORY
 * ============================================================
 */
async function getSellHistory({
  page = 1,
  perPage,
  uniqueIdentifier,
  referenceOrID,
} = {}) {
  const params =
    cleanObject({
      page,
      perPage,
      uniqueIdentifier,
      referenceOrID,
    });

  return signedGet(
    "/giftcard-trade/sell/history",
    params,
    "SELL HISTORY"
  );
}

/**
 * ============================================================
 * GET SINGLE SELL TRANSACTION
 * ============================================================
 *
 * Prestmit exposes this through the history endpoint using
 * referenceOrID.
 */
async function getSellTransaction(
  reference
) {
  if (
    reference ===
      undefined ||
    reference === null ||
    String(
      reference
    ).trim() === ""
  ) {
    throw new Error(
      "Prestmit sell reference is required"
    );
  }

  return getSellHistory({
    referenceOrID:
      String(
        reference
      ).trim(),

    page: 1,

    perPage: 1,
  });
}

/**
 * ============================================================
 * EXPORTS
 * ============================================================
 */
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
