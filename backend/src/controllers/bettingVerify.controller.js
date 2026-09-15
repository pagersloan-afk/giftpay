// backend/src/controllers/bettingVerify.controller.js

const {
  verifyBettingCustomer,
} = require("../services/clubkonnectBetting.service");

exports.verifyBettingCustomerController = async (req, res) => {
  try {
    const { bettingCompany, customerId } = req.body;

    console.log("[BETTING VERIFY][INCOMING]", {
      bettingCompany,
      customerId,
    });

    if (!bettingCompany || !customerId) {
      return res.status(400).json({
        status: false,
        message: "Missing bettingCompany or customerId",
      });
    }

    const raw = await verifyBettingCustomer({
      bettingCompany,
      customerId,
    });

    console.log("[BETTING VERIFY][CLUBKONNECT RAW]", raw);

    const name = raw?.customer_name;

    // ClubKonnect can return failure messages in customer_name.
    const invalidMessages = [
      "Error, Invalid Customer ID",
      "Unable to validate Customer ID.",
      "Unable to validate Customer ID",
      "Invalid Customer ID",
    ];

    const invalidCustomer =
      !name ||
      invalidMessages.some(
        (message) =>
          String(name).trim().toLowerCase() ===
          message.trim().toLowerCase()
      );

    if (invalidCustomer) {
      console.error("[BETTING VERIFY][FAILED]", {
        bettingCompany,
        providerCode: raw?.providerCode,
        customerId,
        raw,
      });

      return res.status(400).json({
        status: false,
        message:
          name || "Unable to validate Customer ID.",
        customerName: null,
        bettingCompany,
        providerCode: raw?.providerCode,
        customerId,
        raw,
      });
    }

    console.log("[BETTING VERIFY][SUCCESS]", {
      bettingCompany,
      providerCode: raw?.providerCode,
      customerId,
      customerName: name,
    });

    return res.json({
      status: true,
      customerName: name,
      bettingCompany,
      providerCode: raw?.providerCode,
      customerId,
    });
  } catch (err) {
    console.error("[BETTING VERIFY][SERVER ERROR]", {
      message: err.message,
      stack: err.stack,
      response: err.response?.data,
    });

    return res.status(500).json({
      status: false,
      message: "Server error verifying betting customer",
    });
  }
};