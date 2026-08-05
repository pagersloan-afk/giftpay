const axios = require("axios");

exports.verifyIdentity = async (req, res) => {
  try {
    console.log("🔥 Incoming verify-identity request:", req.body);

    const { nin, bvn } = req.body;

    if (!nin && !bvn) {
      return res.status(400).json({
        status: "failed",
        message: "NIN or BVN is required",
      });
    }

    // ⭐ Auto-switch between LIVE and SANDBOX
    const isSandbox = process.env.PREMBLY_ENV === "sandbox";

    const baseUrl = isSandbox
      ? "https://api.prembly.com" // sandbox uses same base URL
      : "https://api.prembly.com";

    const apiKey = isSandbox
      ? process.env.PREMBLY_SANDBOX_KEY
      : process.env.PREMBLY_SECRET_KEY;

    console.log("🌍 Environment:", isSandbox ? "SANDBOX" : "LIVE");
    console.log("🔐 Using Key:", apiKey);

    // ⭐ Correct v1 endpoints (NO /v2/)
    const endpoint = nin
      ? `${baseUrl}/identitypass/verification/nin`
      : `${baseUrl}/identitypass/verification/bvn`;

    console.log("🌍 Prembly endpoint:", endpoint);

    // ⭐ Correct v1 request body
    const payload = nin
  ? { number_nin: nin }
  : { number_bvn: bvn };

    const response = await axios.post(endpoint, payload, {
      headers: {
        "x-api-key": apiKey,
        "Content-Type": "application/json",
      },
    });

    console.log("📥 Prembly raw response:", response.data);

    const data = response.data;

    if (!data.status) {
      return res.status(400).json({
        status: "failed",
        message: data.detail || "Identity verification failed",
        data,
      });
    }

    return res.json({
      status: "success",
      message: "Identity verified",
      data,
    });

  } catch (error) {
    console.log("💥 Prembly ERROR:", error.response?.data || error.message);

    return res.status(500).json({
      status: "error",
      message: "Prembly verification error",
      details: error.response?.data || error.message,
    });
  }
};
