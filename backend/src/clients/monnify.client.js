// src/clients/monnify.client.js
const axios = require("axios");
require("dotenv").config();

// BASIC AUTH CLIENT (for /auth/login only)
const basicAuth = Buffer.from(
  `${process.env.MONNIFY_API_KEY}:${process.env.MONNIFY_SECRET_KEY}`
).toString("base64");

const monnifyBasic = axios.create({
  baseURL: process.env.MONNIFY_BASE_URL,
  headers: {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": `Basic ${basicAuth}`,
  },
});

// FACTORY: JWT CLIENT (for reserved accounts)
function monnifyJwtClient(token) {
  return axios.create({
    baseURL: process.env.MONNIFY_BASE_URL,
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": `Bearer ${token}`,
    },
  });
}

module.exports = {
  monnifyBasic,
  monnifyJwtClient,
};
