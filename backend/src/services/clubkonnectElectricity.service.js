// backend/src/services/clubkonnectElectricity.service.js
const axios = require("axios");
const crypto = require("crypto");

const CLUBKONNECT_USERID = process.env.CLUBKONNECT_USERID;
const CLUBKONNECT_APIKEY = process.env.CLUBKONNECT_APIKEY;
const CLUBKONNECT_BASE_URL =
  process.env.CLUBKONNECT_BASE_URL || "https://www.nellobytesystems.com";

if (!CLUBKONNECT_USERID || !CLUBKONNECT_APIKEY) {
  throw new Error("ClubKonnect credentials missing in .env");
}

/** DISCO MAPS **/
const VERIFY_DISCO_MAP = {
  AEDC: "01",
  EKO: "02",
  IKEDC: "03",
  IBEDC: "04",
  PHED: "05",
  EEDC: "06",
  KEDCO: "07",
  JED: "08",
};

const PURCHASE_DISCO_MAP = {
  EKO: "01",
  IKEDC: "02",
  AEDC: "03",
  KEDCO: "04",
  PHED: "05",
  JED: "06",
  IBEDC: "07",
  KAEDC: "08",
  EEDC: "09",
  BEDC: "10",
  YEDC: "11",
  APLE: "12",
};

/** Generate RequestID **/
function generateRequestId(prefix = "GP") {
  return `${prefix}-${Date.now()}-${crypto.randomBytes(4).toString("hex")}`;
}

/** SAFE-MODE VERIFY (APIVerifyElectricityV1.asp) **/
async function verifyMeter({ disco, meterNumber, meterType }) {
  const url = `${CLUBKONNECT_BASE_URL}/APIVerifyElectricityV1.asp`;

  const params = {
    UserID: CLUBKONNECT_USERID,
    APIKey: CLUBKONNECT_APIKEY,
    ElectricCompany: VERIFY_DISCO_MAP[disco],
    MeterNo: meterNumber,
    MeterType: meterType,
  };

  console.log("🔍 SAFE-MODE VERIFY REQUEST:", { url, params });

  const { data } = await axios.get(url, { params });

  console.log("🔍 SAFE-MODE VERIFY RESPONSE:", JSON.stringify(data, null, 2));

  const name = (data?.customer_name || "").trim();
  const address = (data?.customer_address || "").trim();

  if (!name || name === "INVALID_METERNO") {
    return { status: false, message: "Invalid meter number", raw: data };
  }

  return {
    status: true,
    customerName: name,
    customerAddress: address,
    raw: data,
  };
}

/**
 * ⭐ REAL PURCHASE — FOLLOW CK VENDING LOGIC
 * Single call to APIElectricityV1.asp.
 * CK returns JSON like:
 * {
 *   "orderid": "789",
 *   "statuscode": "100",
 *   "status": "ORDER_RECEIVED",
 *   "meterno": "1234567890",
 *   "metertoken": "000123"
 * }
 */
async function vendElectricity({
  disco,
  meterNumber,
  meterType,
  amount,
  phone,
  callbackUrl,
}) {
  const url = `${CLUBKONNECT_BASE_URL}/APIElectricityV1.asp`;

  const requestId = generateRequestId("ELEC");

  const params = {
    UserID: CLUBKONNECT_USERID,
    APIKey: CLUBKONNECT_APIKEY,
    ElectricCompany: PURCHASE_DISCO_MAP[disco],
    MeterType: meterType,
    MeterNo: meterNumber,
    Amount: amount,
    PhoneNo: phone,
    RequestID: requestId,
    CallBackURL: callbackUrl || "",
  };

  console.log("\n==============================");
  console.log("⚡ CK VEND REQUEST (APIElectricityV1)");
  console.log("==============================");
  console.log({ url, params });

  const { data } = await axios.get(url, { params });

  console.log("\n==============================");
  console.log("⚡ CK VEND RESPONSE (APIElectricityV1)");
  console.log("==============================");
  console.log(JSON.stringify(data, null, 2));

  // Just return what CK gave us (orderid, status, metertoken, etc.)
  return {
    requestId,
    response: data,
  };
}

/**
 * ⭐ REQUERY TRANSACTION STATUS — APIQueryV1.asp
 * Can be called by your /api/electricity/requery controller.
 * Prefer OrderID (CK docs + your Flutter screen),
 * fall back to RequestID if needed.
 */
async function requeryElectricity({ requestId, orderId }) {
  const url = `${CLUBKONNECT_BASE_URL}/APIQueryV1.asp`;

  const params = {
    UserID: CLUBKONNECT_USERID,
    APIKey: CLUBKONNECT_APIKEY,
  };

  if (orderId) {
    params.OrderID = orderId;
  } else if (requestId) {
    params.RequestID = requestId;
  }

  console.log("\n==============================");
  console.log("🔍 CK REQUERY REQUEST (APIQueryV1)");
  console.log("==============================");
  console.log({ url, params });

  const { data } = await axios.get(url, { params });

  console.log("\n==============================");
  console.log("🔍 CK REQUERY RESPONSE (APIQueryV1)");
  console.log("==============================");
  console.log(JSON.stringify(data, null, 2));

  return data;
}

module.exports = {
  generateRequestId,
  verifyMeter,
  vendElectricity,
  requeryElectricity,
};
