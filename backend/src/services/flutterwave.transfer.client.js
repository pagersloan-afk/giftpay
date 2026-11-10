
const axios = require("axios");

const SECRET = () => process.env.FLW_SECRET_KEY || process.env.FLUTTERWAVE_SECRET_KEY || "";
const client = () => {
  const key = SECRET();
  if (!key) throw new Error("FLUTTERWAVE_SECRET_KEY_MISSING");
  return axios.create({
    baseURL: "https://api.flutterwave.com/v3",
    timeout: 30000,
    headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
  });
};

async function request(method, path, data, params) {
  const response = await client().request({ method, url: path, data, params });
  const body = response.data || {};
  if (String(body.status || "").toLowerCase() !== "success") {
    const error = new Error(body.message || "Flutterwave request failed");
    error.providerData = body;
    error.httpStatus = response.status;
    error.providerRejected = response.status >= 400 && response.status < 500;
    throw error;
  }
  return body.data;
}

module.exports = { request };
