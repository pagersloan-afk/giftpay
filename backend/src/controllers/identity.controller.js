const axios = require("axios");

exports.verifyIdentity = async (req, res) => {
  try {
    console.log("🔥 Incoming verify-identity request:", req.body);

    let { nin, bvn } = req.body;

    // ============================================================
    // NORMALIZE INPUT
    // ============================================================

    nin = typeof nin === "string" ? nin.trim() : "";
    bvn = typeof bvn === "string" ? bvn.trim() : "";

    // ============================================================
    // VALIDATE INPUT
    // ============================================================

    if (!nin && !bvn) {
      return res.status(400).json({
        status: "failed",
        message: "NIN or BVN is required",
      });
    }

    // Only one identity number should be submitted.
    if (nin && bvn) {
      return res.status(400).json({
        status: "failed",
        message: "Provide either NIN or BVN, not both",
      });
    }

    // ============================================================
    // PREMBLY ENVIRONMENT
    // ============================================================

    const isSandbox =
      String(process.env.PREMBLY_ENV || "").toLowerCase() === "sandbox";

    const baseUrl = "https://api.prembly.com";

    const apiKey = isSandbox
      ? process.env.PREMBLY_SANDBOX_KEY
      : process.env.PREMBLY_SECRET_KEY;

    if (!apiKey) {
      console.error("❌ Prembly API key is not configured.");

      return res.status(500).json({
        status: "error",
        message: "Identity verification service is not configured",
      });
    }

    console.log(
      "🌍 Environment:",
      isSandbox ? "SANDBOX" : "LIVE"
    );

    console.log("🔐 Prembly API key loaded");

    // ============================================================
    // DETERMINE IDENTITY TYPE
    // ============================================================

    const identityType = nin ? "NIN" : "BVN";

    // ============================================================
    // PREMBLY ENDPOINT
    // ============================================================

    const endpoint = nin
      ? `${baseUrl}/identitypass/verification/nin`
      : `${baseUrl}/identitypass/verification/bvn`;

    console.log("🪪 Identity type:", identityType);
    console.log("🌍 Prembly endpoint:", endpoint);

    // ============================================================
    // PREMBLY REQUEST BODY
    // ============================================================
    //
    // IMPORTANT:
    //
    // NIN endpoint expects:
    // {
    //   number_nin: "..."
    // }
    //
    // BVN endpoint expects:
    // {
    //   number: "..."
    // }
    //
    // We intentionally do NOT use the same payload for both.
    // ============================================================

    const payload = nin
      ? {
          number_nin: nin,
        }
      : {
          number: bvn,
        };

    console.log(
      "📤 Sending identity verification request to Prembly"
    );

    const response = await axios.post(endpoint, payload, {
      headers: {
        "x-api-key": apiKey,
        "Content-Type": "application/json",
      },
      timeout: 30000,
    });

    console.log("📥 Prembly raw response:", response.data);

    const data = response.data;

    // ============================================================
    // VERIFICATION FAILED
    // ============================================================

    if (!data || !data.status) {
      return res.status(400).json({
        status: "failed",
        message:
          data?.detail ||
          data?.message ||
          `${identityType} verification failed`,
        data,
      });
    }

    // ============================================================
    // KYC TIER
    // ============================================================
    //
    // NIN or BVN verification = Tier 1
    // Face + BVN match = Tier 2
    // Full KYC = Tier 3
    //
    // This endpoint handles Tier 1.
    // ============================================================

    const kycStatus = "tier1";

    return res.json({
      status: "success",
      message: "Tier1 identity verified",
      identityType: identityType.toLowerCase(),
      kycStatus,
      tier: 1,
      data,
    });
  } catch (error) {
    console.error(
      "💥 Prembly ERROR:",
      error.response?.data || error.message
    );

    // ============================================================
    // PREMBLY HTTP ERROR
    // ============================================================

    if (error.response) {
      return res.status(error.response.status || 400).json({
        status: "failed",
        message:
          error.response.data?.detail ||
          error.response.data?.message ||
          "Identity verification failed",
        data: error.response.data,
      });
    }

    // ============================================================
    // NETWORK / TIMEOUT / UNKNOWN ERROR
    // ============================================================

    return res.status(500).json({
      status: "error",
      message: "Prembly verification error",
      details: error.message,
    });
  }
};