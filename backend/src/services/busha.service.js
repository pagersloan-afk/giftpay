const axios = require("axios");

const BASE_URL = (
  process.env.BUSHA_ENV === "production"
    ? "https://api.busha.io"
    : "https://api.sandbox.busha.so"
).replace(/\/+$/, "");

function config() {
  const token = process.env.BUSHA_API_TOKEN;
  if (!token || !token.trim()) {
    const error = new Error("Busha API credentials are not configured.");
    error.statusCode = 503;
    throw error;
  }
  return {
    baseURL: BASE_URL,
    timeout: 30000,
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      Authorization: `Bearer ${token.trim()}`,
      ...(process.env.BUSHA_PROFILE_ID
        ? { "X-BU-PROFILE-ID": process.env.BUSHA_PROFILE_ID.trim() }
        : {}),
    },
  };
}

function safeError(error) {
  const status = error.response?.status;
  const payload = error.response?.data;
  const message =
    payload?.error?.message ||
    payload?.message ||
    (status === 401
      ? "Busha rejected the configured credentials."
      : status === 429
      ? "Busha rate limit reached. Please retry shortly."
      : status
      ? `Busha request failed (${status}).`
      : error.message || "Unable to reach Busha.");

  const wrapped = new Error(message);
  wrapped.statusCode =
    status === 400 ? 400 :
    status === 401 ? 502 :
    status === 404 ? 404 :
    status === 429 ? 429 :
    status >= 500 ? 502 :
    error.statusCode || 502;
  wrapped.providerStatus = status;
  wrapped.providerError = payload?.error?.name;
  return wrapped;
}

async function request(method, path, { params, body } = {}) {
  try {
    const response = await axios.request({
      ...config(),
      method,
      url: path,
      params,
      data: body,
    });
    return response.data;
  } catch (error) {
    throw safeError(error);
  }
}

module.exports = {
  request,
  createCustomer: (body) => request("post", "/v1/customers", { body }),
  getCustomer: (id) => request("get", `/v1/customers/${encodeURIComponent(id)}`),
  getCurrencies: (params) => request("get", "/v1/currencies", { params }),
  getCurrency: (code) => request("get", `/v1/currencies/${encodeURIComponent(code)}`),
  getPairs: (params) => request("get", "/v1/pairs", { params }),
  getBalances: (params) => request("get", "/v1/balances", { params }),
  getBalance: (idOrCode) => request("get", `/v1/balances/${encodeURIComponent(idOrCode)}`),
  getQuotes: (params) => request("get", "/v1/quotes", { params }),
  createQuote: (body) => request("post", "/v1/quotes", { body }),
  getQuote: (id) => request("get", `/v1/quotes/${encodeURIComponent(id)}`),
  getTransactions: (params) => request("get", "/v1/transactions", { params }),
  getTransaction: (id) => request("get", `/v1/transactions/${encodeURIComponent(id)}`),
  getDepositAddress: (code) => request("get", `/v1/addresses/${encodeURIComponent(code)}`),
  regenerateDepositAddress: (body) => request("post", "/v1/addresses/regenerate", { body }),
  getRecipients: (params) => request("get", "/v1/recipients", { params }),
  createRecipient: (body) => request("post", "/v1/recipients", { body }),
  getRecipient: (id) => request("get", `/v1/recipients/${encodeURIComponent(id)}`),
  deleteRecipient: (id) => request("delete", `/v1/recipients/${encodeURIComponent(id)}`),
  createTransfer: (body) => request("post", "/v1/transfers", { body }),
  getTransfer: (id) => request("get", `/v1/transfers/${encodeURIComponent(id)}`),
};
