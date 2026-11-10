const axios = require("axios");

const BASE_URL = (process.env.CLUBKONNECT_BASE_URL || "https://www.nellobytesystems.com").replace(/\/+$/, "");

function credentials() {
  const UserID = process.env.CLUBKONNECT_USERID;
  const APIKey = process.env.CLUBKONNECT_APIKEY;
  if (!UserID || !APIKey) throw new Error("ClubKonnect credentials are not configured.");
  return { UserID, APIKey };
}

async function get(endpoint, params = {}) {
  const response = await axios.get(`${BASE_URL}/${endpoint}`, {
    params: { ...credentials(), ...params },
    timeout: 30000,
    headers: { Accept: "application/json" },
  });
  return response.data;
}

function flattenObjects(value, output = [], depth = 0) {
  if (depth > 7 || value == null) return output;
  if (Array.isArray(value)) {
    for (const item of value) flattenObjects(item, output, depth + 1);
  } else if (typeof value === "object") {
    output.push(value);
    for (const child of Object.values(value)) {
      if (child && typeof child === "object") flattenObjects(child, output, depth + 1);
    }
  }
  return output;
}

function normalizePackages(raw) {
  const rows = flattenObjects(raw);
  const seen = new Set();
  const result = [];
  for (const row of rows) {
    const code = String(row.PRODUCT_CODE ?? row.PRODUCT_ID ?? row.ExamType ?? row.EXAM_TYPE ?? row.exam_type ?? row.examtype ?? row.EXAMCODE ?? row.EXAM_CODE ?? row.VARIATION_CODE ?? row.variation_code ?? row.variationCode ?? row.CODE ?? row.code ?? row.ID ?? row.id ?? row.DataPlan ?? "").trim();
    const name = String(row.PRODUCT_NAME ?? row.PackageName ?? row.PACKAGE_NAME ?? row.package_name ?? row.EXAM_NAME ?? row.PRODUCT_DESCRIPTION ?? row.PRODUCT_DESC ?? row.NAME ?? row.name ?? row.Description ?? row.description ?? "").trim();
    const amountRaw = row.PRODUCT_AMOUNT ?? row.Amount ?? row.amount ?? row.PRICE ?? row.price ?? row.Cost ?? row.cost ?? row.SELLING_PRICE ?? row.AMOUNT_NGN ?? row.EXAM_AMOUNT;
    const amount = Number(String(amountRaw ?? "").replace(/[^0-9.]/g, ""));
    if (!code || !name || !Number.isFinite(amount) || amount <= 0) continue;
    const key = `${code}|${name}|${amount}`;
    if (seen.has(key)) continue;
    seen.add(key);
    result.push({ code, name, amount, validity: String(row.PRODUCT_VALIDITY ?? row.Validity ?? row.validity ?? ""), raw: row });
  }
  return result;
}

function normalizeNetworks(raw) {
  const source = raw?.MOBILE_NETWORK || raw?.mobile_network || raw?.networks || {};
  const entries = Array.isArray(source) ? source : Object.entries(source).map(([key, value]) => ({ key, value }));
  const result = [];
  for (const entry of entries) {
    const first = Array.isArray(entry?.value) ? entry.value[0] : (entry?.value ?? entry);
    const key = String(entry?.key || first?.ID || first?.NETWORK_ID || "");
    let code = String(first?.ID || first?.NETWORK_ID || key.replace(/^m_/i, "").replace(/\D/g, ""));
    if (/^\d$/.test(code)) code = `0${code}`;
    let name = String(first?.PRODUCT_NAME || first?.NETWORK_NAME || first?.network || first?.name || key.replace(/^m_/i, "").replace(/_/g, "")).trim();
    const lower = name.toLowerCase();
    if (lower.includes("mtn")) name = "MTN";
    else if (lower.includes("glo")) name = "Glo";
    else if (lower.includes("airtel")) name = "Airtel";
    else if (lower.includes("9mobile") || lower.includes("etisalat")) name = "9mobile";
    if (code && name) result.push({ code, name });
  }
  return [...new Map(result.map((item) => [item.code, item])).values()];
}

async function getAirtimeNetworks() {
  const raw = await get("APIAirtimeNetworkV2.asp");
  return normalizeNetworks(raw);
}

async function getDataNetworks() {
  const raw = await get("APIDatabundleNetworkV2.asp");
  return normalizeNetworks(raw);
}

function productsForNetwork(raw, networkCode) {
  const source = raw?.MOBILE_NETWORK || raw?.mobile_network || {};
  const target = String(networkCode).replace(/^0+/, "");
  const found = Object.entries(source).find(([key, value]) => {
    const first = Array.isArray(value) ? value[0] : value;
    const id = String(first?.ID || first?.NETWORK_ID || key.replace(/^m_/i, "").replace(/\D/g, "")).replace(/^0+/, "");
    return id === target;
  });
  if (!found) return [];
  const value = found[1];
  const first = Array.isArray(value) ? value[0] : value;
  const plans = first?.PRODUCT || first?.PRODUCTS || first?.PLAN || first?.PLANS || [];
  return normalizePackages(plans);
}

async function getDataPinPlans(networkCode) {
  const raw = await get("APIDatabundlePlansV2.asp");
  return productsForNetwork(raw, networkCode);
}

async function getSmilePackages() {
  return normalizePackages(await get("APISmilePackagesV2.asp"));
}
async function getWaecPackages() {
  return normalizePackages(await get("APIWAECPackagesV2.asp"));
}
async function getJambPackages() {
  return normalizePackages(await get("APIJAMBPackagesV2.asp"));
}

async function verifySmileAccount(account) {
  return get("APIVerifySmileV1.asp", { MobileNetwork: "smile-direct", MobileNumber: account });
}
async function verifyJambProfile(examType, profileId) {
  return get("APIVerifyJAMBV1.asp", { ExamType: examType, ProfileID: profileId });
}

async function vend({ product, network, value, planCode, quantity, recipient, examType, requestId }) {
  const common = { RequestID: requestId, CallBackURL: process.env.CLUBKONNECT_CALLBACK_URL || "" };
  switch (product) {
    case "airtime-pin":
      return get("APIEPINV1.asp", { ...common, MobileNetwork: network, Value: value, Quantity: quantity });
    case "data-pin":
      return get("APIDatabundleEPINV1.asp", { ...common, MobileNetwork: network, DataPlan: planCode, Quantity: quantity });
    case "smile":
      return get("APISmileV1.asp", { ...common, MobileNetwork: "smile-direct", DataPlan: planCode, MobileNumber: recipient });
    case "waec":
      return get("APIWAECV1.asp", { ...common, ExamType: examType, PhoneNo: recipient });
    case "jamb":
      return get("APIJAMBV1.asp", { ...common, ExamType: examType, PhoneNo: recipient });
    default:
      throw new Error("Unsupported ClubKonnect product.");
  }
}

async function query(requestId, orderId) {
  const params = orderId ? { OrderID: orderId } : { RequestID: requestId };
  return get("APIQueryV1.asp", params);
}

function extractDelivery(raw) {
  const pins = raw?.TXN_EPIN ?? raw?.TXN_EPIN_DATABUNDLE ?? raw?.txn_epin ?? raw?.epins ?? null;
  const cardDetails = raw?.carddetails ?? raw?.CardDetails ?? raw?.card_details ?? null;
  return { pins, cardDetails };
}

function classify(raw) {
  const status = String(raw?.orderstatus ?? raw?.OrderStatus ?? raw?.status ?? raw?.Status ?? "").trim().toUpperCase();
  const code = String(raw?.statuscode ?? raw?.StatusCode ?? "").trim();
  const delivery = extractDelivery(raw);
  if ((Array.isArray(delivery.pins) && delivery.pins.length) || delivery.cardDetails || ["ORDER_COMPLETED", "SUCCESS", "SUCCESSFUL", "COMPLETED"].includes(status) || code === "200") return "SUCCESS";
  if (["ORDER_FAILED", "FAILED", "FAILURE", "DECLINED", "CANCELLED", "REVERSED"].includes(status) || status.startsWith("INVALID_") || status.includes("ERROR") || (code && !["100", "200"].includes(code))) return "FAILED";
  return "PENDING";
}

module.exports = {
  getAirtimeNetworks, getDataNetworks, getDataPinPlans,
  getSmilePackages, getWaecPackages, getJambPackages,
  verifySmileAccount, verifyJambProfile, vend, query,
  extractDelivery, classify,
};
