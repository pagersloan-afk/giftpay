
const axios = require("axios");
const crypto = require("crypto");

const BASE_URL = (
  process.env.CLUBKONNECT_BASE_URL ||
  "https://www.nellobytesystems.com"
).replace(/\/+$/, "");

const DEBUG =
  String(process.env.CLUBKONNECT_DEBUG || "false").toLowerCase() ===
  "true";

function credentials() {
  const userId = process.env.CLUBKONNECT_USERID;
  const apiKey = process.env.CLUBKONNECT_APIKEY;

  if (!userId || !apiKey) {
    throw new Error(
      "ClubKonnect credentials are missing. Configure CLUBKONNECT_USERID and CLUBKONNECT_APIKEY."
    );
  }

  return {
    UserID: userId,
    APIKey: apiKey,
  };
}

// -------------------------------------------------
// DEBUG LOGGING HELPERS
// -------------------------------------------------

function debugLog(label, data) {
  if (!DEBUG) return;

  const timestamp = new Date().toISOString();

  console.log(
    `\n[CLUBKONNECT DEBUG] ${timestamp} | ${label}`
  );

  if (data !== undefined) {
    try {
      console.log(
        JSON.stringify(data, null, 2)
      );
    } catch (_) {
      console.log(data);
    }
  }

  console.log("[END CLUBKONNECT DEBUG]\n");
}

function maskSensitiveParams(params = {}) {
  const masked = { ...params };

  const sensitiveFields = [
    "MobileNumber",
    "PhoneNo",
    "MeterNo",
  ];

  for (const field of sensitiveFields) {
    if (masked[field]) {
      const value = String(masked[field]);

      masked[field] =
        value.length > 4
          ? `${"*".repeat(value.length - 4)}${value.slice(-4)}`
          : "****";
    }
  }

  return masked;
}

// -------------------------------------------------
// CENTRAL CLUBKONNECT API REQUEST
// -------------------------------------------------

async function get(path, params = {}) {
  const url = `${BASE_URL}/${path}`;

  const requestParams = {
    ...credentials(),
    ...params,
  };

  debugLog("OUTGOING REQUEST", {
    endpoint: path,
    url,
    method: "GET",
    parameters: maskSensitiveParams(params),
    timestamp: new Date().toISOString(),
  });

  try {
    const response = await axios.get(url, {
      params: requestParams,
      timeout: 30000,
    });

    // Log the complete provider response.
    // Credentials are never included in this log.
    debugLog("SUCCESSFUL HTTP RESPONSE", {
      endpoint: path,
      httpStatus: response.status,
      contentType: response.headers?.["content-type"] || null,
      response: response.data,
      timestamp: new Date().toISOString(),
    });

    return response.data;
  } catch (error) {
    const providerResponse = error.response;

    debugLog("API REQUEST FAILED", {
      endpoint: path,
      url,
      httpStatus: providerResponse?.status || null,
      statusText: providerResponse?.statusText || null,

      // Full response body returned by ClubKonnect,
      // when available.
      providerResponse: providerResponse?.data || null,

      errorMessage: error.message,
      errorCode: error.code || null,

      timestamp: new Date().toISOString(),
    });

    throw error;
  }
}

// -------------------------------------------------
// AIRTIME NETWORKS
// -------------------------------------------------

function getMobileNetworks(raw) {
  const source =
    raw?.MOBILE_NETWORK ||
    raw?.mobile_network ||
    raw?.networks ||
    {};

  const entries = Array.isArray(source)
    ? source
    : Object.entries(source).map(([key, value]) => ({
        key,
        value,
      }));

  const result = [];

  for (const entry of entries) {
    const value = entry?.value ?? entry;
    const first = Array.isArray(value) ? value[0] : value;

    const key = String(
      entry?.key ||
      first?.ID ||
      first?.NETWORK_ID ||
      ""
    );

    let name = String(
      first?.PRODUCT_NAME ||
      first?.NETWORK_NAME ||
      first?.network ||
      first?.name ||
      key
        .replace(/^m\_/i, "")
        .replace(/\_/g, "")
    ).trim();

    const normalized = name.toLowerCase();

    if (normalized.includes("mtn")) {
      name = "MTN";
    } else if (normalized.includes("glo")) {
      name = "GLO";
    } else if (normalized.includes("airtel")) {
      name = "Airtel";
    } else if (
      normalized.includes("9mobile") ||
      normalized.includes("etisalat") ||
      normalized.includes("t2")
    ) {
      name = "9mobile";
    }

    const codeMatch = key.match(/(?:m\_)?0?(\d{1,2})$/i);

    let code = String(
      first?.ID ||
      first?.NETWORK_ID ||
      (codeMatch ? codeMatch[1].padStart(2, "0") : "")
    ).trim();

    if (/^\d$/.test(code)) {
      code = `0${code}`;
    }

    if (name && code) {
      result.push({ code, name });
    }
  }

  const unique = new Map();

  for (const item of result) {
    unique.set(item.code, item);
  }

  return [...unique.values()];
}

function getProductsForNetwork(raw, networkCode) {
  const source =
    raw?.MOBILE_NETWORK ||
    raw?.mobile_network ||
    {};

  const target = String(networkCode || "").replace(/^0+/, "");

  const found = Object.entries(source).find(([key, value]) => {
    const first = Array.isArray(value) ? value[0] : value;

    const id = String(
      first?.ID ||
      first?.NETWORK_ID ||
      key.replace(/^m\_/i, "").replace(/\D/g, "")
    ).replace(/^0+/, "");

    return id === target;
  });

  if (!found) return [];

  const value = found[1];
  const first = Array.isArray(value) ? value[0] : value;

  const products =
    first?.PRODUCT ||
    first?.products ||
    first?.PLAN ||
    [];

  return Array.isArray(products) ? products : [];
}

function makeRequestId(prefix) {
  return `${prefix}-${Date.now()}-${crypto.randomBytes(4).toString("hex")}`;
}

async function getAirtimeNetworks() {
  const raw = await get("APIAirtimeNetworkV2.asp");

  const networks = getMobileNetworks(raw);

  if (!networks.length) {
    throw new Error(
      "ClubKonnect did not return any airtime networks"
    );
  }

  return networks;
}

async function vendAirtime({
  network,
  amount,
  phone,
  requestId,
}) {
  return get("APIAirtimeV1.asp", {
    MobileNetwork: network,
    Amount: amount,
    MobileNumber: phone,
    RequestID: requestId,
    CallBackURL:
      process.env.CLUBKONNECT_CALLBACK_URL || "",
  });
}

// -------------------------------------------------
// DATA
// -------------------------------------------------

async function getDataNetworks() {
  const raw = await get("APIDatabundleNetworkV2.asp");

  const networks = getMobileNetworks(raw);

  if (!networks.length) {
    throw new Error(
      "ClubKonnect did not return any data networks"
    );
  }

  return networks;
}

async function getDataPlans(networkCode) {
  const raw = await get("APIDatabundlePlansV2.asp");

  const products = getProductsForNetwork(
    raw,
    networkCode
  );

  return products
    .map((p) => ({
      id: String(
        p.PRODUCT_CODE ||
        p.PRODUCT_ID ||
        p.ID ||
        ""
      ),

      code: String(
        p.PRODUCT_CODE ||
        p.PRODUCT_ID ||
        p.ID ||
        ""
      ),

      PRODUCT_CODE: String(
        p.PRODUCT_CODE ||
        p.PRODUCT_ID ||
        p.ID ||
        ""
      ),

      name: String(
        p.PRODUCT_NAME ||
        p.NAME ||
        p.name ||
        ""
      ),

      PRODUCT_NAME: String(
        p.PRODUCT_NAME ||
        p.NAME ||
        p.name ||
        ""
      ),

      price: String(
        p.PRODUCT_AMOUNT ||
        p.AMOUNT ||
        p.PRICE ||
        ""
      ),

      PRODUCT_AMOUNT: String(
        p.PRODUCT_AMOUNT ||
        p.AMOUNT ||
        p.PRICE ||
        ""
      ),

      validity:
        p.PRODUCT_VALIDITY ||
        p.VALIDITY ||
        p.validity ||
        "",

      raw: p,
    }))
    .filter((p) => p.code && p.name);
}

async function vendData({
  network,
  planCode,
  phone,
  requestId,
}) {
  return get("APIDatabundleV1.asp", {
    MobileNetwork: network,
    DataPlan: planCode,
    MobileNumber: phone,
    RequestID: requestId,
    CallBackURL:
      process.env.CLUBKONNECT_CALLBACK_URL || "",
  });
}

// -------------------------------------------------
// ELECTRICITY
// -------------------------------------------------

const DISCOS = [
  {
    code: "EKO",
    name: "Eko Electric (EKEDC)",
    providerCode: "01",
  },
  {
    code: "IKEDC",
    name: "Ikeja Electric (IKEDC)",
    providerCode: "02",
  },
  {
    code: "AEDC",
    name: "Abuja Electric (AEDC)",
    providerCode: "03",
  },
  {
    code: "KEDCO",
    name: "Kano Electric (KEDCO)",
    providerCode: "04",
  },
  {
    code: "PHED",
    name: "Port Harcourt Electric (PHEDC)",
    providerCode: "05",
  },
  {
    code: "JED",
    name: "Jos Electric (JEDC)",
    providerCode: "06",
  },
  {
    code: "IBEDC",
    name: "Ibadan Electric (IBEDC)",
    providerCode: "07",
  },
  {
    code: "KAEDC",
    name: "Kaduna Electric (KAEDC)",
    providerCode: "08",
  },
  {
    code: "EEDC",
    name: "Enugu Electric (EEDC)",
    providerCode: "09",
  },
  {
    code: "BEDC",
    name: "Benin Electric (BEDC)",
    providerCode: "10",
  },
  {
    code: "YEDC",
    name: "Yola Electric (YEDC)",
    providerCode: "11",
  },
  {
    code: "APLE",
    name: "Aba Electric (APLE)",
    providerCode: "12",
  },
];

function findDisco(code) {
  const normalized = String(code || "")
    .trim()
    .toUpperCase();

  return DISCOS.find(
    (d) =>
      d.code === normalized ||
      d.providerCode === normalized
  );
}

async function verifyMeter({
  disco,
  meterNumber,
  meterType,
}) {
  const selected = findDisco(disco);

  if (!selected) {
    throw new Error(
      "Unsupported electricity distribution company"
    );
  }

  const type = normalizeMeterType(meterType);

  return get("APIVerifyElectricityV1.asp", {
    ElectricCompany: selected.providerCode,
    MeterNo: meterNumber,
    MeterType: type,
  });
}

function normalizeMeterType(value) {
  const v = String(value || "")
    .trim()
    .toLowerCase();

  if (["01", "1", "prepaid"].includes(v)) {
    return "01";
  }

  if (["02", "2", "postpaid"].includes(v)) {
    return "02";
  }

  throw new Error(
    "Select Prepaid or Postpaid meter type"
  );
}

async function vendElectricity({
  disco,
  meterNumber,
  meterType,
  amount,
  phone,
  requestId,
}) {
  const selected = findDisco(disco);

  if (!selected) {
    throw new Error(
      "Unsupported electricity distribution company"
    );
  }

  return get("APIElectricityV1.asp", {
    ElectricCompany: selected.providerCode,
    MeterType: normalizeMeterType(meterType),
    MeterNo: meterNumber,
    Amount: amount,
    PhoneNo: phone || "",
    RequestID: requestId || makeRequestId("ELEC"),
    CallBackURL:
      process.env.CLUBKONNECT_CALLBACK_URL || "",
  });
}

// -------------------------------------------------
// TRANSACTION QUERY
// -------------------------------------------------

async function queryTransaction({
  requestId,
  orderId,
}) {
  const params = {};

  if (orderId) {
    params.OrderID = orderId;
  } else if (requestId) {
    params.RequestID = requestId;
  } else {
    throw new Error(
      "A ClubKonnect RequestID or OrderID is required for requery"
    );
  }

  return get("APIQueryV1.asp", params);
}

// -------------------------------------------------
// RESPONSE STATUS NORMALIZATION
// -------------------------------------------------

function normalizeStatus(raw) {
  const status = String(
    raw?.orderstatus ||
    raw?.OrderStatus ||
    raw?.status ||
    raw?.Status ||
    ""
  ).trim().toUpperCase();

  const code = String(
    raw?.statuscode ||
    raw?.StatusCode ||
    ""
  ).trim();

  if (
    [
      "ORDER_COMPLETED",
      "SUCCESS",
      "SUCCESSFUL",
      "COMPLETED",
    ].includes(status) ||
    code === "200"
  ) {
    return "SUCCESS";
  }

  if (
    [
      "ORDER_FAILED",
      "FAILED",
      "FAILURE",
      "DECLINED",
      "CANCELLED",
      "REVERSED",
    ].includes(status)
  ) {
    return "FAILED";
  }

  if (
    [
      "ORDER_RECEIVED",
      "ORDER_ONHOLD",
      "PENDING",
      "PROCESSING",
      "",
    ].includes(status) ||
    code === "100"
  ) {
    return "PENDING";
  }

  return "PENDING";
}

// -------------------------------------------------
// EXPORTS
// -------------------------------------------------

module.exports = {
  getAirtimeNetworks,
  vendAirtime,
  getDataNetworks,
  getDataPlans,
  vendData,
  DISCOS,
  findDisco,
  verifyMeter,
  vendElectricity,
  queryTransaction,
  normalizeStatus,
  makeRequestId,
  normalizeMeterType,
};
