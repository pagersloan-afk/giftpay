const crypto = require("crypto");
const admin = require("firebase-admin");

exports.monnifyWebhook = async (req, res) => {
  const signature = req.headers["monnify-signature"];
  const payload = JSON.stringify(req.body);

  const computed = crypto
    .createHmac("sha512", process.env.MONNIFY_SECRET_KEY)
    .update(payload)
    .digest("hex");

  if (computed !== signature) {
    return res.status(401).send("Invalid signature");
  }

  const event = req.body.eventType;

  if (event === "SUCCESSFUL_TRANSACTION") {
    const { accountReference, amountPaid } = req.body.eventData;

    await admin.firestore().collection("users").doc(accountReference).update({
      walletBalance: admin.firestore.FieldValue.increment(amountPaid),
    });
  }

  return res.send("OK");
};
