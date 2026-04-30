// backend/src/controllers/electricity.controller.js
const axios = require("axios");

exports.verifyMeterController = async (req, res) => {
  try {
    const { discoCode, meterNumber, meterType } = req.body;

    if (!discoCode || !meterNumber || !meterType) {
      return res.status(400).json({
        status: false,
        message: "Missing discoCode, meterNumber or meterType",
      });
    }

    const USER_ID = process.env.CLUBKONNECT_USERID;
    const API_KEY = process.env.CLUBKONNECT_APIKEY;

    const url =
      `https://www.nellobytesystems.com/APIVerifyElectricityV1.asp?UserID=${USER_ID}&APIKey=${API_KEY}&ElectricCompany=${discoCode}&MeterNo=${meterNumber}&MeterType=${meterType}`;

    console.log("📡 VERIFY METER URL:", url);

    const response = await axios.get(url);
    const raw = response.data;

    console.log("📨 VERIFY METER RESPONSE:", raw);

    if (!raw || !raw.customer_name || raw.customer_name === "INVALID_METERNO") {
      return res.status(400).json({
        status: false,
        message: "Meter verification failed",
        raw,
      });
    }

    return res.json({
      status: true,
      customerName: raw.customer_name,
      address: raw.address ?? "",
      meterNumber,
      discoCode,
      meterType,
    });
  } catch (err) {
    console.error("❌ VERIFY METER ERROR:", err.message);
    return res.status(500).json({
      status: false,
      message: "Server error verifying meter",
    });
  }
};
