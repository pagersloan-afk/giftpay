// backend/src/controllers/electricityCallback.controller.js
const { requeryElectricity } = require("../services/clubkonnectElectricity.service");

exports.electricityCallbackController = async (req, res) => {
  try {
    console.log("\n==============================");
    console.log("⚡ CK CALLBACK RECEIVED");
    console.log("==============================");
    console.log("Query Params:", req.query);
    console.log("Body:", req.body);

    // CK may send data via query string OR JSON body
    const orderId =
      req.query.orderid ||
      req.body.orderid ||
      req.query.OrderID ||
      req.body.OrderID;

    const requestId =
      req.query.requestid ||
      req.body.requestid ||
      req.query.RequestID ||
      req.body.RequestID;

    const statusCode =
      req.query.statuscode ||
      req.body.statuscode ||
      req.query.StatusCode ||
      req.body.StatusCode;

    const orderStatus =
      req.query.orderstatus ||
      req.body.orderstatus ||
      req.query.OrderStatus ||
      req.body.OrderStatus;

    console.log("\n📌 Extracted Callback Values:");
    console.log({ orderId, requestId, statusCode, orderStatus });

    // If CK did not send orderId or requestId, we cannot continue
    if (!orderId && !requestId) {
      console.log("❌ Missing orderId/requestId in callback");
      return res.status(400).send("Missing orderId/requestId");
    }

    // ⭐ Immediately query CK for the token
    console.log("\n==============================");
    console.log("🔍 CALLING CK APIQueryV1.asp FOR TOKEN");
    console.log("==============================");

    const queryResponse = await requeryElectricity({
      orderId,
      requestId,
    });

    console.log("\n==============================");
    console.log("🔍 CK TOKEN RESPONSE (APIQueryV1)");
    console.log("==============================");
    console.log(JSON.stringify(queryResponse, null, 2));

    // Extract token + units
    const token =
      queryResponse?.metertoken ||
      queryResponse?.MeterToken ||
      queryResponse?.token ||
      queryResponse?.Token ||
      "";

    const units =
      queryResponse?.units ||
      queryResponse?.unit ||
      queryResponse?.Units ||
      queryResponse?.unitvalue ||
      "";

    console.log("\n📌 Extracted Token + Units:");
    console.log({ token, units });

    // ⭐ TODO: SAVE TOKEN TO FIRESTORE
    // await saveTokenToFirestore({ orderId, requestId, token, units });

    console.log("\n💾 Token saved successfully (placeholder log)");

    // ⭐ Respond to CK (must be 200 OK)
    return res.status(200).send("OK");
  } catch (err) {
    console.error("❌ CALLBACK ERROR:", err.message);
    return res.status(500).send("Callback processing failed");
  }
};
