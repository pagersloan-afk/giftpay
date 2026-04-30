// backend/src/services/clubkonnectCable.service.js
const axios = require("axios");

const USER_ID = process.env.CLUBKONNECT_USERID;
const API_KEY = process.env.CLUBKONNECT_APIKEY;

async function verifyCableSmartcard({ cable, smartcard }) {
  const url =
    `https://www.nellobytesystems.com/APIVerifyCableTVV1.0.asp?UserID=${USER_ID}` +
    `&APIKey=${API_KEY}&CableTV=${cable}&SmartCardNo=${smartcard}`;

  const res = await axios.get(url);
  return res.data;
}

async function fetchCablePackages() {
  const url = `https://www.nellobytesystems.com/APICableTVPackagesV2.asp?UserID=${USER_ID}`;
  const res = await axios.get(url);
  return res.data;
}

async function vendCableTV({ cable, pkg, smartcard, phone, requestId }) {
  const url =
    `https://www.nellobytesystems.com/APICableTVV1.asp?UserID=${USER_ID}` +
    `&APIKey=${API_KEY}` +
    `&CableTV=${cable}` +
    `&Package=${pkg}` +
    `&SmartCardNo=${smartcard}` +
    `&PhoneNo=${phone}` +
    `&RequestID=${requestId}`;

  const res = await axios.get(url);
  return res.data;
}

module.exports = {
  verifyCableSmartcard,
  fetchCablePackages,
  vendCableTV,
};
