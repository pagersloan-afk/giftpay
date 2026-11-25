const Busha = require("../services/busha.service");
const admin = require("firebase-admin");

const customerLinks = () => admin.firestore().collection("busha_customer_links");

function customerPayload(body) {
  const required = ["email", "phone", "birth_date", "first_name", "last_name"];
  const missing = required.filter((key) => !String(body?.[key] || "").trim());
  if (missing.length || !body?.address || typeof body.address !== "object") {
    const error = new Error(`Missing required customer fields: ${[...missing, ...(!body?.address ? ["address"] : [])].join(", ")}`);
    error.statusCode = 400;
    throw error;
  }
  const address = body.address;
  const addressRequired = ["street", "city", "state", "postal_code", "country"];
  const missingAddress = addressRequired.filter((key) => !String(address[key] || "").trim());
  if (missingAddress.length) {
    const error = new Error(`Missing address fields: ${missingAddress.join(", ")}`);
    error.statusCode = 400;
    throw error;
  }
  return {
    email: String(body.email).trim().toLowerCase(),
    has_accepted_terms: body.has_accepted_terms === true,
    type: "individual",
    country_id: String(body.country_id || "NG").trim().toUpperCase(),
    phone: String(body.phone).trim(),
    birth_date: String(body.birth_date).trim(),
    first_name: String(body.first_name).trim(),
    last_name: String(body.last_name).trim(),
    address: {
      street: String(address.street).trim(),
      city: String(address.city).trim(),
      state: String(address.state).trim(),
      postal_code: String(address.postal_code).trim(),
      country: String(address.country).trim().toUpperCase(),
    },
  };
}

function send(res, work) {
  return Promise.resolve()
    .then(work)
    .then((data) => res.status(200).json({
      status: true,
      message: "Busha data retrieved successfully.",
      data,
    }))
    .catch((error) => {
      console.error("[BUSHA]", error.message);
      return res.status(error.statusCode || 502).json({
        status: false,
        message: error.message || "Busha service is temporarily unavailable.",
        ...(error.providerError ? { providerCode: error.providerError } : {}),
      });
    });
}

exports.currencies = (req, res) => send(res, () => Busha.getCurrencies(req.query));
exports.currency = (req, res) => send(res, () => Busha.getCurrency(req.params.code));
exports.pairs = (req, res) => send(res, () => Busha.getPairs(req.query));
exports.balances = (req, res) => send(res, () => Busha.getBalances(req.query));
exports.balance = (req, res) => send(res, () => Busha.getBalance(req.params.idOrCode));
exports.quotes = (req, res) => send(res, () => Busha.getQuotes(req.query));
exports.createQuote = (req, res) => send(res, () => {
  if (!req.body || typeof req.body !== "object" || Array.isArray(req.body) || !Object.keys(req.body).length) {
    const error = new Error("A quote request body is required.");
    error.statusCode = 400;
    throw error;
  }
  return Busha.createQuote(req.body);
});
exports.quote = (req, res) => send(res, () => Busha.getQuote(req.params.id));
exports.transactions = (req, res) => send(res, () => Busha.getTransactions(req.query));
exports.transaction = (req, res) => send(res, () => Busha.getTransaction(req.params.id));
exports.depositAddress = (req, res) => send(res, () => Busha.getDepositAddress(req.params.code));
exports.regenerateDepositAddress = (req, res) => send(res, () => {
  if (!req.body || typeof req.body !== "object" || Array.isArray(req.body) || !Object.keys(req.body).length) {
    const error = new Error("A deposit-address request body is required.");
    error.statusCode = 400;
    throw error;
  }
  return Busha.regenerateDepositAddress(req.body);
});
exports.recipients = (req, res) => send(res, () => Busha.getRecipients(req.query));
exports.createRecipient = (req, res) => send(res, () => Busha.createRecipient(req.body));
exports.recipient = (req, res) => send(res, () => Busha.getRecipient(req.params.id));
exports.deleteRecipient = (req, res) => send(res, () => Busha.deleteRecipient(req.params.id));
exports.createTransfer = (req, res) => send(res, () => Busha.createTransfer(req.body));
exports.transfer = (req, res) => send(res, () => Busha.getTransfer(req.params.id));


// One Busha individual customer per authenticated GiftPay Firebase account.
exports.myCustomerProfile = async (req, res) => {
  try {
    const snap = await customerLinks().doc(req.user.uid).get();
    if (!snap.exists || !snap.data().bushaCustomerId) {
      return res.status(200).json({ status: true, data: { linked: false, state: snap.exists ? snap.data().state : "not_created" } });
    }
    return res.status(200).json({ status: true, data: { linked: true, bushaCustomerId: snap.data().bushaCustomerId, state: snap.data().state } });
  } catch (error) {
    console.error("[BUSHA CUSTOMER LINK]", error.message);
    return res.status(500).json({ status: false, message: "Unable to load your crypto account status." });
  }
};

exports.createMyCustomerProfile = async (req, res) => {
  const uid = req.user.uid;
  let reserved = false;
  try {
    const payload = customerPayload(req.body);
    if (payload.has_accepted_terms !== true) {
      return res.status(400).json({ status: false, message: "You must accept the Busha customer terms before continuing." });
    }
    const ref = customerLinks().doc(uid);
    await admin.firestore().runTransaction(async (tx) => {
      const existing = await tx.get(ref);
      if (existing.exists) {
        const data = existing.data();
        const error = new Error(data.bushaCustomerId ? "Your crypto customer profile already exists." : "Your crypto profile is being created or needs support review.");
        error.statusCode = 409;
        throw error;
      }
      tx.create(ref, { state: "creating", createdAt: admin.firestore.FieldValue.serverTimestamp() });
      reserved = true;
    });
    const result = await Busha.createCustomer(payload);
    const customer = result?.data || result?.customer || result;
    const bushaCustomerId = customer?.id || customer?.customer?.id;
    if (!bushaCustomerId) {
      const error = new Error("Busha did not return a customer ID. The request requires reconciliation before retrying.");
      error.statusCode = 502;
      throw error;
    }
    await ref.set({
      bushaCustomerId,
      state: customer?.status || "created",
      email: payload.email,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    return res.status(201).json({ status: true, message: "Your individual crypto customer profile was created.", data: { linked: true, bushaCustomerId, state: customer?.status || "created" } });
  } catch (error) {
    console.error("[BUSHA CUSTOMER CREATE]", error.message);
    if (reserved) {
      // Keep a reconciliation marker: a timeout may happen after Busha created the customer.
      await customerLinks().doc(uid).set({ state: "needs_review", lastError: "Provider creation could not be confirmed", updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true }).catch(() => {});
    }
    return res.status(error.statusCode || 502).json({ status: false, message: error.message || "Unable to create your crypto customer profile." });
  }
};
