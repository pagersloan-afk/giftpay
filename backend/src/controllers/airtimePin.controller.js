// backend/src/controllers/airtimePin.controller.js

const {
  verifyTransactionPin,
} = require("../services/transactionPin.service");

function getAuthenticatedUserId(req) {
  return (
    req.user?.uid ||
    req.auth?.uid ||
    req.user?.id ||
    null
  );
}

exports.verifyAirtimePin = async (req, res) => {
  try {
    const userId =
      getAuthenticatedUserId(req);

    if (!userId) {
      return res.status(401).json({
        status: false,
        code: "AUTH_REQUIRED",
        message: "Authentication is required.",
      });
    }

    const transactionPin =
      String(
        req.body?.transactionPin || ""
      ).trim();

    if (!/^\d{4}$/.test(transactionPin)) {
      return res.status(401).json({
        status: false,
        code: "PIN_REQUIRED",
        message:
          "A valid 4-digit transaction PIN is required.",
      });
    }

    const result =
      await verifyTransactionPin(
        userId,
        transactionPin
      );

    if (result?.ok) {
      return res.json({
        status: true,
        code: "PIN_VERIFIED",
        message:
          "Transaction PIN verified successfully.",
      });
    }

    if (result?.code === "PIN_LOCKED") {
      return res.status(401).json({
        status: false,
        code: "PIN_LOCKED",
        message:
          "Transaction PIN temporarily locked after too many failed attempts.",
        lockedUntil:
          result.lockedUntil || null,
      });
    }

    if (result?.code === "PIN_NOT_SET") {
      return res.status(401).json({
        status: false,
        code: "PIN_NOT_SET",
        message:
          "Transaction PIN has not been set.",
      });
    }

    if (result?.code === "AUTH_REQUIRED") {
      return res.status(401).json({
        status: false,
        code: "AUTH_REQUIRED",
        message:
          "Authentication is required.",
      });
    }

    if (result?.code === "PIN_REQUIRED") {
      return res.status(401).json({
        status: false,
        code: "PIN_REQUIRED",
        message:
          "A valid 4-digit transaction PIN is required.",
      });
    }

    return res.status(401).json({
      status: false,
      code:
        result?.code || "PIN_INVALID",
      message:
        "Incorrect transaction PIN.",
    });
  } catch (error) {
    console.error(
      "[AIRTIME PIN] Verification error:",
      error.message
    );

    return res.status(500).json({
      status: false,
      code: "PIN_VERIFICATION_FAILED",
      message:
        "Unable to verify transaction PIN.",
    });
  }
};