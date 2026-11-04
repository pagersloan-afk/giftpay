const axios = require("axios");

function createPaystackClient() {
  const secret = process.env.PAYSTACK_SECRET_KEY || process.env.PAYSTACK_SECRET;
  if (!secret) throw new Error("PAYSTACK_SECRET_KEY (or PAYSTACK_SECRET) is not configured");

  return axios.create({
    baseURL: process.env.PAYSTACK_BASE_URL || "https://api.paystack.co",
    timeout: 30000,
    headers: {
      Authorization: `Bearer ${secret}`,
      "Content-Type": "application/json",
      Accept: "application/json",
    },
  });
}

module.exports = { createPaystackClient };
