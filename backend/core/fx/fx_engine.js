const axios = require("axios");
const admin = require("firebase-admin");
const db = admin.firestore();

const FX_CACHE_DOC = db.collection("fx").doc("usdToNgn");
const CACHE_DURATION_MS = 10 * 60 * 1000; // 10 minutes

const CURRENCY_API_KEY = process.env.CURRENCY_API_KEY;

const FXEngine = {
  getUsdToNgnRate: async () => {
    // ⭐ Check cache first
    const cache = await FX_CACHE_DOC.get();

    if (cache.exists) {
      const data = cache.data();
      const age = Date.now() - data.updatedAt;

      if (age < CACHE_DURATION_MS && data.rate) {
        return data.rate;
      }
    }

    // ⭐ Fetch live rate from CurrencyAPI
    const url = `https://api.currencyapi.com/v3/latest?apikey=${CURRENCY_API_KEY}&base_currency=USD&currencies=NGN`;

    const res = await axios.get(url);

    const rate = res.data?.data?.NGN?.value;

    if (!rate) {
      console.log("FX API response:", res.data);
      throw new Error("Failed to fetch USD/NGN rate");
    }

    const markup = 0.03; // 3% GiftPay margin
    const finalRate = rate * (1 + markup);

    // ⭐ Save to cache
    await FX_CACHE_DOC.set({
      rate: finalRate,
      updatedAt: Date.now(),
    });

    return finalRate;
  },
};

module.exports = FXEngine;
