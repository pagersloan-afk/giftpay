// backend/src/controllers/cableVerify.controller.js
const { verifyCableSmartcard } = require("../services/clubkonnectCable.service");

exports.verifyCableSmartcardController = async (req, res) => {
  try {
    const { cable, smartcard } = req.body;

    if (!cable || !smartcard) {
      return res.status(400).json({
        status: false,
        message: "Missing cable or smartcard",
      });
    }

    const raw = await verifyCableSmartcard({ cable, smartcard });

    // Log raw provider response
    console.log("===== CLUBKONNECT RAW CABLE VERIFY =====");
    console.log(JSON.stringify(raw, null, 2));
    console.log("========================================");

    const customerName =
      raw?.customer_name ||
      raw?.Customer_Name ||
      raw?.CUSTOMER_NAME ||
      null;

    if (!raw || !customerName || customerName === "INVALID_SMARTCARDNO") {
      return res.status(400).json({
        status: false,
        message: "Smartcard verification failed",
        raw,
      });
    }

    return res.json({
      status: true,
      customerName,
      smartcard,
      cable,
    });
  } catch (err) {
    console.error("Cable verify error:", err);
    return res.status(500).json({
      status: false,
      message: "Server error verifying smartcard",
    });
  }
};
