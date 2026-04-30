import axios from "axios";

const USER_ID = process.env.CLUBKONNECT_USERID;
const API_KEY = process.env.CLUBKONNECT_APIKEY;

/**
 * ClubKonnect Data Vending Service
 *
 * IMPORTANT:
 * - MobileNetwork MUST be the network code (01, 02, 03, 04)
 * - DataPlan MUST be PRODUCT_CODE (NOT PRODUCT_ID)
 */
export async function vendData({ network, planCode, phone, requestId }) {
  const url =
    `https://www.nellobytesystems.com/APIDatabundleV1.asp` +
    `?UserID=${USER_ID}` +
    `&APIKey=${API_KEY}` +
    `&MobileNetwork=${network}` +   // 01, 02, 03, 04
    `&DataPlan=${planCode}` +       // MUST BE PRODUCT_CODE
    `&MobileNumber=${phone}` +
    `&RequestID=${requestId}` +
    `&CallBackURL=`;

  try {
    const response = await axios.get(url);
    return response.data;
  } catch (err) {
    console.error("❌ ClubKonnect Vending Error:", err);
    return {
      status: "ERROR",
      message: "Failed to reach ClubKonnect",
      error: err?.message,
    };
  }
}
