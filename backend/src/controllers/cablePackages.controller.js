// backend/src/controllers/cablePackages.controller.js
const { fetchCablePackages } = require("../services/clubkonnectCable.service");

exports.getCablePackagesController = async (req, res) => {
  try {
    const raw = await fetchCablePackages();

    // ⭐ Log raw provider response
    console.log("===== CLUBKONNECT RAW PACKAGES =====");
    console.log(JSON.stringify(raw, null, 2));
    console.log("====================================");

    // ⭐ Correct root key based on your actual provider response
    const tvRoot = raw?.TV_ID;
    if (!tvRoot) {
      return res.status(400).json({
        status: false,
        message: "Invalid provider response: missing TV_ID",
        raw,
      });
    }

    const result = {};

    // Loop through providers (DStv, GOtv, Startimes, Showmax)
    for (const providerName in tvRoot) {
      const providerArray = tvRoot[providerName];

      if (!Array.isArray(providerArray) || providerArray.length === 0) continue;

      const providerObj = providerArray[0];

      // ⭐ Provider ID (dstv, gotv, startimes, showmax)
      const providerId = providerObj.ID?.toLowerCase() || providerName.toLowerCase();

      // ⭐ Extract packages from PRODUCT
      const products = providerObj.PRODUCT || [];

      const packages = products.map((p) => ({
        code: p.PACKAGE_ID,
        name: p.PACKAGE_NAME,
        amount: Number(p.PACKAGE_AMOUNT || 0),
      }));

      result[providerId] = packages;
    }

    return res.json({
      status: true,
      data: result,
    });
  } catch (err) {
    console.error("Cable packages error:", err);
    return res.status(500).json({
      status: false,
      message: "Failed to fetch cable packages",
    });
  }
};
