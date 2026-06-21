require("dotenv").config();
const axios = require("axios");

(async () => {
  const USER_ID = process.env.CLUBKONNECT_USERID;
  const API_KEY = process.env.CLUBKONNECT_APIKEY;

  const url = `https://www.nellobytesystems.com/APIDatabundleNetworksV2.asp?UserID=${USER_ID}&APIKey=${API_KEY}`;

  console.log("Testing URL:", url);

  try {
    const res = await axios.get(url);
    console.log("\n📨 RESPONSE FROM CLUBKONNECT:");
    console.log(res.data);
  } catch (err) {
    console.log("\n❌ ERROR:");
    console.log(err.response?.data || err.message);
  }
})();
