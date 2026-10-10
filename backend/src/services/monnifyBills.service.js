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

  console.log(
    "[MONNIFY AUTH] POST /api/v1/auth/login"
  );

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

  console.log(
    "[MONNIFY AUTH] Response:",
    response.status,
    body?.requestSuccessful,
    body?.responseCode,
    body?.responseMessage
  );

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

    normalized.provider = provider;

    normalized.response = error.response;

    normalized.isMonnifyError = true;

    return normalized;
  }

  return error;
}

// ============================================================
// LOGGING HELPERS
// ============================================================

function logRequest(method, path, options = {}) {
  console.log(
    `[MONNIFY BILLS] ${method} ${path}`
  );

  if (options.params) {
    console.log(
      "[MONNIFY BILLS] Query Params:",
      JSON.stringify(options.params)
    );
  }

  if (options.data) {
    console.log(
      "[MONNIFY BILLS] Request Body:",
      JSON.stringify(options.data)
    );
  }
}

function logResponse(method, path, response) {
  const body = response?.data;

  console.log(
    `[MONNIFY BILLS] ${method} ${path} -> HTTP ${response?.status}`
  );

  if (body && typeof body === "object") {
    console.log(
      "[MONNIFY BILLS] requestSuccessful:",
      body.requestSuccessful
    );

    console.log(
      "[MONNIFY BILLS] responseCode:",
      body.responseCode
    );

    console.log(
      "[MONNIFY BILLS] responseMessage:",
      body.responseMessage
    );

    if (body.responseBody !== undefined) {
      console.log(
        "[MONNIFY BILLS] responseBody:",
        JSON.stringify(body.responseBody)
      );
    }
  } else {
    console.log(
      "[MONNIFY BILLS] Raw response:",
      String(body)
    );
  }
}

function logError(method, path, error) {
  console.error(
    `[MONNIFY BILLS] ${method} ${path} FAILED`
  );

  console.error(
    "[MONNIFY BILLS] HTTP status:",
    error?.response?.status
  );

  console.error(
    "[MONNIFY BILLS] responseCode:",
    error?.response?.data?.responseCode
  );

  console.error(
    "[MONNIFY BILLS] responseMessage:",
    error?.response?.data?.responseMessage
  );

  console.error(
    "[MONNIFY BILLS] response body:",
    typeof error?.response?.data === "string"
      ? error.response.data
      : JSON.stringify(error?.response?.data)
  );

  console.error(
    "[MONNIFY BILLS] Error:",
    error?.message
  );
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

  logRequest(method, path, options);

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
    });

    logResponse(method, path, response);

    const body = response.data;

    // --------------------------------------------------------
    // Monnify can return HTTP 200 while requestSuccessful=false.
    // --------------------------------------------------------

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
    logError(method, path, error);

    // --------------------------------------------------------
    // Refresh once if access token has expired.
    // --------------------------------------------------------

    if (
      retry &&
      error?.response?.status === 401
    ) {
      console.log(
        "[MONNIFY AUTH] Token expired/unauthorized. Refreshing token..."
      );

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
//
// Monnify Bills Payment discovery calls are configured here
// with page: 0 from the application layer.
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
//
// GET /api/v1/vas/bills-payment/biller-categories
// ============================================================

async function getCategories(query = {}) {
  const params = pagination({
    size: query.size ?? 100,
    page: query.page ?? 0,
  });

  console.log(
    "[MONNIFY BILLS] ========================================"
  );

  console.log(
    "[MONNIFY BILLS] Fetching BILLER CATEGORIES"
  );

  console.log(
    "[MONNIFY BILLS] Endpoint: GET /api/v1/vas/bills-payment/biller-categories"
  );

  console.log(
    "[MONNIFY BILLS] Pagination:",
    JSON.stringify(params)
  );

  return request(
    "GET",
    "/api/v1/vas/bills-payment/biller-categories",
    {
      params,
    }
  );
}

// ============================================================
// BILLERS
//
// GET /api/v1/vas/bills-payment/billers
// ============================================================

async function getBillers(query = {}) {
  const params = pagination({
    size: query.size ?? 100,
    page: query.page ?? 0,
  });

  if (query.category_code) {
    params.category_code =
      String(query.category_code);
  }

  console.log(
    "[MONNIFY BILLS] ========================================"
  );

  console.log(
    "[MONNIFY BILLS] Fetching BILLERS"
  );

  console.log(
    "[MONNIFY BILLS] Endpoint: GET /api/v1/vas/bills-payment/billers"
  );

  console.log(
    "[MONNIFY BILLS] Pagination:",
    JSON.stringify(params)
  );

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
//
// GET /api/v1/vas/bills-payment/biller-products
// ============================================================

async function getProducts(query = {}) {
  const params = pagination({
    size: query.size ?? 100,
    page: query.page ?? 0,
  });

  if (!query.biller_code) {
    const error = new Error(
      "biller_code is required"
    );

    error.status = 400;

    throw error;
  }

  params.biller_code =
    String(query.biller_code);

  console.log(
    "[MONNIFY BILLS] ========================================"
  );

  console.log(
    "[MONNIFY BILLS] Fetching BILLER PRODUCTS"
  );

  console.log(
    "[MONNIFY BILLS] Endpoint: GET /api/v1/vas/bills-payment/biller-products"
  );

  console.log(
    "[MONNIFY BILLS] Pagination:",
    JSON.stringify(params)
  );

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
//
// POST /api/v1/vas/bills-payment/validate-customer
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

  console.log(
    "[MONNIFY BILLS] ========================================"
  );

  console.log(
    "[MONNIFY BILLS] Validating CUSTOMER"
  );

  console.log(
    "[MONNIFY BILLS] Endpoint: POST /api/v1/vas/bills-payment/validate-customer"
  );

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
// Monnify Bills Payment documentation uses the vend endpoint
// after successful customer validation.
//
// Current application payload:
//
// amount
// customerId
// productCode
// reference
// emailAddress
// phoneNumber (optional)
// validationReference (optional)
//
// IMPORTANT:
// validationReference is only included when supplied by the
// validation step.
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

  console.log(
    "[MONNIFY BILLS] ========================================"
  );

  console.log(
    "[MONNIFY BILLS] VEND AIRTIME/BILL"
  );

  console.log(
    "[MONNIFY BILLS] Endpoint: POST /api/v1/vas/bills-payment/vend"
  );

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
//
// GET /api/v1/vas/bills-payment/requery
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

  const params = {
    reference:
      String(reference).trim(),
  };

  console.log(
    "[MONNIFY BILLS] ========================================"
  );

  console.log(
    "[MONNIFY BILLS] REQUERY"
  );

  console.log(
    "[MONNIFY BILLS] Endpoint: GET /api/v1/vas/bills-payment/requery"
  );

  return request(
    "GET",
    "/api/v1/vas/bills-payment/requery",
    {
      params,
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