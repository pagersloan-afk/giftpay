// backend/src/controllers/electricityDiscos.controller.js
const axios = require("axios");

exports.getDiscosController = async (req, res) => {
  try {
    const USER_ID = process.env.CLUBKONNECT_USERID;

    const url = `https://www.nellobytesystems.com/APIElectricityDiscosV2.asp?UserID=${USER_ID}`;

    console.log("📡 Fetching CK Discos:", url);

    const response = await axios.get(url);
    const raw = response.data;

    console.log("📨 CK Disco Response:", JSON.stringify(raw, null, 2));

    if (!raw?.ELECTRIC_COMPANY) {
      return res.status(400).json({
        status: false,
        message: "Invalid response from ClubKonnect",
        raw,
      });
    }

    const companies = raw.ELECTRIC_COMPANY;
    const discos = [];

    for (const key in companies) {
      const arr = companies[key];
      if (!Array.isArray(arr) || arr.length === 0) continue;

      const item = arr[0];

      discos.push({
        name: item.NAME,
        code: item.ID, // ⭐ CK numeric code
      });
    }

    return res.json({
      status: true,
      data: discos,
    });
  } catch (err) {
    console.error("❌ Disco fetch error:", err.message);
    return res.status(500).json({
      status: false,
      message: "Failed to fetch discos",
    });
  }
};
