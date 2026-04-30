import axios from "axios";

const USER_ID = process.env.CLUBKONNECT_USERID;
const API_KEY = process.env.CLUBKONNECT_APIKEY;

// ⭐ VEND AIRTIME WITH FULL LOGGING
export async function vendAirtime({ network, amount, phone, requestId }) {
  const url = `https://www.nellobytesystems.com/APIAirtimeV1.asp?UserID=${USER_ID}&APIKey=${API_KEY}&MobileNetwork=${network}&Amount=${amount}&MobileNumber=${phone}&RequestID=${requestId}&CallBackURL=`;

  console.log("📡 [AIRTIME REQUEST] URL:", url);

  try {
    const response = await axios.get(url);

    console.log("📨 [AIRTIME RESPONSE] RAW:", response.data);

    return response.data;
  } catch (err) {
    console.log("❌ [AIRTIME ERROR]", err?.response?.data || err.message);
    throw err;
  }
}

// ⭐ REQUERY AIRTIME WITH FULL LOGGING
export async function requeryAirtime({ requestId }) {
  const url = `https://www.nellobytesystems.com/APIQueryV1.asp?UserID=${USER_ID}&APIKey=${API_KEY}&RequestID=${requestId}`;

  console.log("🔄 [AIRTIME REQUERY] URL:", url);

  try {
    const response = await axios.get(url);

    console.log("📨 [AIRTIME REQUERY RESPONSE] RAW:", response.data);

    return response.data;
  } catch (err) {
    console.log("❌ [AIRTIME REQUERY ERROR]", err?.response?.data || err.message);
    throw err;
  }
}
