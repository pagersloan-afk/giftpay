// backend/src/controllers/bettingVerify.controller.js
const {
  verifyBettingCustomer,
} = require("../services/clubkonnectBetting.service");

exports.verifyBettingCustomerController = async (req, res) => {
  try {
    const { bettingCompany, customerId } = req.body;

    if (!bettingCompany || !customerId) {
      return res.status(400).json({
        status: false,
        message: "Missing bettingCompany or customerId",
      });
    }

    const raw = await verifyBettingCustomer({ bettingCompany, customerId });

    console.log("[BETTING VERIFY][RAW]", raw);

    const name = raw?.customer_name;

    if (!name || name === "Error, Invalid Customer ID") {
      return res.status(400).json({
        status: false,
        message: "Customer verification failed",
        raw,
      });
    }

    return res.json({
      status: true,
      customerName: name,
      bettingCompany,
      customerId,
    });
  } catch (err) {
    console.error("Betting verify error:", err.message || err);
    return res.status(500).json({
      status: false,
      message: "Server error verifying betting customer",
    });
  }
};
