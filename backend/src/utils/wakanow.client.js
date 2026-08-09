const axios = require("axios");

const wakanow = axios.create({
  baseURL: "https://partners-api.wakanow.com/v1",
  headers: {
    "x-api-key": process.env.WAKANOW_API_KEY,
    "x-api-secret": process.env.WAKANOW_API_SECRET,
    "x-partner-id": process.env.WAKANOW_PARTNER_ID,
    "Content-Type": "application/json",
  },
});

module.exports = wakanow;
