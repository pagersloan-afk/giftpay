const admin = require("firebase-admin");
const { reconcileFoodMerchantPayoutStatus } = require("../services/foodMerchantPayout.service");
const { applyFlutterwaveTransferStatus } = require("../services/flutterwaveTransferStatus.service");

function validSecret(req) {
  const expected = String(process.env.FLUTTERWAVE_WEBHOOK_SECRET_HASH || process.env.FLW_WEBHOOK_SECRET_HASH || "");
  const received = String(req.headers["verif-hash"] || "");
  if (!expected || !received) return false;
  const a = Buffer.from(expected);
  const b = Buffer.from(received);
  return a.length === b.length && require("crypto").timingSafeEqual(a, b);
}

async function handle(req, res) {
  if (!validSecret(req)) return res.status(401).send("Invalid Flutterwave webhook signature");

  const body = req.body || {};
  const event = String(body.event || "");
  const data = body.data || {};
  if (!event.toLowerCase().includes("transfer")) return res.sendStatus(200);

  const reference = String(data.reference || "").trim();
  if (!reference) return res.sendStatus(200);

  try {
    const db = admin.firestore();
    const foodRef = db.collection("monnify_transfers").doc(reference);
    const foodSnap = await foodRef.get();

    if (foodSnap.exists && foodSnap.data()?.type === "food_merchant_payout") {
      const foodRecord = foodSnap.data() || {};
      // Do not let a Flutterwave webhook reconcile a Monnify payout record.
      if (String(foodRecord.provider || "").toLowerCase() !== "flutterwave") return res.sendStatus(200);

      await reconcileFoodMerchantPayoutStatus({
        reference,
        status: data.status || event,
        providerData: data,
        provider: "flutterwave",
      });
      return res.sendStatus(200);
    }

    await applyFlutterwaveTransferStatus({ reference, providerData: data, event });
    // Unknown references are acknowledged to prevent endless provider retries.
    return res.sendStatus(200);
  } catch (e) {
    console.error("Flutterwave transfer webhook processing failed:", e.message || e);
    return res.sendStatus(500);
  }
}

module.exports = { flutterwaveTransferWebhook: handle };
