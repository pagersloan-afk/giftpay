const { validateCustomer } = require("../services/monnifyBills.service.js");

exports.verifyMeterController = async (req, res) => {
  try {
    const meterNumber = String(req.body?.meterNumber || "").trim();
    const billerCode = String(req.body?.billerCode || req.body?.discoCode || "").trim();
    const productCode = String(req.body?.productCode || "").trim();
    const meterType = String(req.body?.meterType || "").trim();

    if (!meterNumber || !billerCode || !productCode) {
      return res.status(400).json({
        status: false,
        message: "meterNumber, billerCode and productCode are required",
      });
    }

    const response = await validateCustomer({
      productCode,
      customerId: meterNumber,
    });

    const body = response?.responseBody ?? response?.data ?? {};
    const vendInstruction = body?.vendInstruction ?? {};
    const requireValidationRef = Boolean(vendInstruction?.requireValidationRef);

    if (!response?.requestSuccessful || String(response?.responseCode) !== "0") {
      return res.status(400).json({
        status: false,
        message: response?.responseMessage || "Meter verification failed",
        raw: response,
      });
    }

    const customerName =
      body?.customerName ?? body?.customer_name ?? body?.name ?? "";

    const address = body?.address ?? "";
    const validationReference =
      body?.validationReference ??
      body?.validationRef ??
      body?.reference ??
      null;

    if (requireValidationRef && !validationReference) {
      return res.status(502).json({
        status: false,
        message: "Monnify requires a validation reference but did not return one",
        raw: response,
      });
    }

    return res.json({
      status: true,
      customerName,
      address,
      meterNumber,
      billerCode,
      discoCode: billerCode,
      productCode,
      meterType,
      requireValidationRef,
      validationReference,
      raw: response,
    });
  } catch (err) {
    console.error("Monnify electricity meter validation error:", err);
    return res.status(err.status || 502).json({
      status: false,
      message: err.message || "Server error verifying meter",
      provider: err.provider,
    });
  }
};
