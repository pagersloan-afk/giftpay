// backend/src/services/monnifyBills.service.js

const axios = require("axios");

const BASE_URL = (
  process.env.MONNIFY_BASE_URL || "https://api.monnify.com"
).replace(/\/+$/, "");

const API_KEY = process.env.MONNIFY_API_KEY;
const SECRET_KEY = process.env.MONNIFY_SECRET_KEY;

let cachedToken = null;
let tokenExpiresAt = 0;

// ============================================================
// CONFIG
// ============================================================

function getConfig() {
  if (!API_KEY || !SECRET_KEY) {
    throw new Error(
      "MONNIFY_API_KEY and MONNIFY_SECRET_KEY must be configured"
    );
  }

  return {
    baseURL: BASE_URL,
    timeout: 30000,
  };
}

// ============================================================
// AUTH
// ============================================================

async function getAccessToken(forceRefresh = false) {
  if (!forceRefresh && cachedToken && Date.now() < tokenExpiresAt) {
    return cachedToken;
  }

  getConfig();

  const credentials = Buffer.from(
    `${API_KEY}:${SECRET_KEY}`
  ).toString("base64");

  const response = await axios.post(
    `${BASE_URL}/api/v1/auth/login`,
    {},
    {
      headers: {
        Authorization: `Basic ${credentials}`,
        "Content-Type": "application/json",
      },
      timeout: 30000,
    }
  );

  const body = response.data;

  if (
    !body?.requestSuccessful ||
    !body?.responseBody?.accessToken
  ) {
    throw new Error(
      body?.responseMessage || "Unable to authenticate with Monnify"
    );
  }

  cachedToken = body.responseBody.accessToken;

  const expiresIn = Number(
    body.responseBody.expiresIn || 3600
  );

  tokenExpiresAt =
    Date.now() +
    Math.max(expiresIn - 60, 60) * 1000;

  return cachedToken;
}

// ============================================================
// PROVIDER ERROR NORMALIZATION
//
// IMPORTANT:
// Axios rejects HTTP 400/401/etc. before returning response.data.
// Monnify puts the useful error inside response.data:
//
// {
//   requestSuccessful: false,
//   responseMessage: "invalid customerId",
//   responseCode: "99"
// }
//
// Convert that into a normal Error while preserving the provider
// details so controllers can return the real message to Flutter.
// ============================================================

function normalizeProviderError(error) {
  const provider = error?.response?.data;

  if (provider && typeof provider === "object") {
    const providerMessage =
      provider.responseMessage ||
      provider.message ||
      provider.errorMessage ||
      error.message ||
      "Monnify request failed";

    const normalized = new Error(
      String(providerMessage)
    );

    normalized.status =
      error.response?.status ||
      provider.responseCode ||
      502;

    normalized.responseCode =
      provider.responseCode ?? null;

    normalized.responseMessage =
      provider.responseMessage ||
      provider.message ||
      null;

    normalized.provider =
      provider;

    normalized.response =
      error.response;

    normalized.isMonnifyError = true;

    return normalized;
  }

  return error;
}

// ============================================================
// GENERIC MONNIFY REQUEST
// ============================================================

async function request(
  method,
  path,
  options = {},
  retry = true
) {
  const token = await getAccessToken();

  try {
    const response = await axios({
      method,
      url: `${BASE_URL}${path}`,
      params: options.params,
      data: options.data,
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      timeout: 30000,
      // We deliberately allow Axios to reject HTTP errors.
      // The catch block below converts them into useful Monnify errors.
    });

    const body = response.data;

    // Some Monnify errors can arrive as HTTP 200 while
    // requestSuccessful is false.
    if (
      body &&
      typeof body === "object" &&
      body.requestSuccessful === false
    ) {
      const error = new Error(
        body.responseMessage ||
          body.message ||
          "Monnify request failed"
      );

      error.status = 400;
      error.responseCode =
        body.responseCode ?? null;
      error.responseMessage =
        body.responseMessage ?? null;
      error.provider = body;
      error.isMonnifyError = true;

      throw error;
    }

    return body;
  } catch (error) {
    // Refresh once if the access token has expired.
    if (
      retry &&
      error?.response?.status === 401
    ) {
      await getAccessToken(true);

      return request(
        method,
        path,
        options,
        false
      );
    }

    throw normalizeProviderError(error);
  }
}

// ============================================================
// PAGINATION
// ============================================================

function pagination(query = {}) {
  const size = Number(query.size ?? 20);
  const page = Number(query.page ?? 0);

  if (
    !Number.isInteger(size) ||
    size < 1 ||
    size > 100 ||
    !Number.isInteger(page) ||
    page < 0
  ) {
    const error = new Error(
      "Invalid pagination parameters"
    );

    error.status = 400;

    throw error;
  }

  return {
    size,
    page,
  };
}

// ============================================================
// BILLER CATEGORIES
// ============================================================

async function getCategories(query = {}) {
  return request(
    "GET",
    "/api/v1/vas/bills-payment/biller-categories",
    {
      params: pagination(query),
    }
  );
}

// ============================================================
// BILLERS
// ============================================================

async function getBillers(query = {}) {
  const params = pagination(query);

  if (query.category_code) {
    params.category_code =
      String(query.category_code);
  }

  return request(
    "GET",
    "/api/v1/vas/bills-payment/billers",
    {
      params,
    }
  );
}

// ============================================================
// PRODUCTS
// ============================================================

async function getProducts(query = {}) {
  const params = pagination(query);

  if (!query.biller_code) {
    const error = new Error(
      "biller_code is required"
    );

    error.status = 400;

    throw error;
  }

  params.biller_code =
    String(query.biller_code);

  return request(
    "GET",
    "/api/v1/vas/bills-payment/biller-products",
    {
      params,
    }
  );
}

// ============================================================
// VALIDATE CUSTOMER
// ============================================================

async function validateCustomer(payload = {}) {
  const {
    productCode,
    customerId,
  } = payload;

  if (!productCode || !customerId) {
    const error = new Error(
      "productCode and customerId are required"
    );

    error.status = 400;

    throw error;
  }

  return request(
    "POST",
    "/api/v1/vas/bills-payment/validate-customer",
    {
      data: {
        productCode:
          String(productCode),

        customerId:
          String(customerId),
      },
    }
  );
}

// ============================================================
// VEND
//
// Monnify Bills Payment documentation uses:
// amount
// customerId
// productCode
// reference
// emailAddress
//
// Do NOT change these back to vendAmount/vendReference.
// ============================================================

async function vend(payload = {}) {
  const {
    amount,
    customerId,
    productCode,
    reference,
    emailAddress,
    phoneNumber,
    validationReference,
  } = payload;

  const numericAmount =
    Number(amount);

  if (
    !Number.isFinite(numericAmount) ||
    numericAmount <= 0 ||
    !customerId ||
    !productCode ||
    !reference ||
    !emailAddress
  ) {
    const error = new Error(
      "amount, customerId, productCode, reference, and emailAddress are required"
    );

    error.status = 400;

    throw error;
  }

  const data = {
    amount: numericAmount,

    customerId:
      String(customerId),

    productCode:
      String(productCode),

    reference:
      String(reference),

    emailAddress:
      String(emailAddress),
  };

  if (phoneNumber) {
    data.phoneNumber =
      String(phoneNumber);
  }

  if (validationReference) {
    data.validationReference =
      String(validationReference);
  }

  return request(
    "POST",
    "/api/v1/vas/bills-payment/vend",
    {
      data,
    }
  );
}

// ============================================================
// REQUERY
// ============================================================

async function requery(reference) {
  if (
    !reference ||
    !String(reference).trim()
  ) {
    const error = new Error(
      "reference is required"
    );

    error.status = 400;

    throw error;
  }

  return request(
    "GET",
    "/api/v1/vas/bills-payment/requery",
    {
      params: {
        reference:
          String(reference).trim(),
      },
    }
  );
}

// ============================================================
// EXPORTS
// ============================================================

module.exports = {
  getCategories,
  getBillers,
  getProducts,
  validateCustomer,
  vend,
  requery,
};