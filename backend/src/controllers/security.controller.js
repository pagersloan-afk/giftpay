const admin = require("firebase-admin");

const {
  sendLoginSecurityEmail,
} = require("../../utils/notify");

const {
  getIpLocation,
} = require("../services/ipLocation.service");

function isValidTimezone(timeZone) {
  if (!timeZone || typeof timeZone !== "string") {
    return false;
  }

  try {
    new Intl.DateTimeFormat("en-US", {
      timeZone,
    }).format(new Date());

    return true;
  } catch {
    return false;
  }
}

function getClientIp(req) {
  try {
    return String(req.ip || "").trim();
  } catch {
    return "";
  }
}

exports.loginAlert = async (req, res) => {
  try {
    const userId = req.user?.uid;

    if (!userId) {
      return res.status(401).json({
        status: false,
        message: "Unauthorized",
      });
    }

    const firebaseUser =
      await admin.auth().getUser(userId);

    const email =
      String(firebaseUser.email || "").trim();

    if (!email) {
      console.warn(
        `⚠️ Login alert skipped: no email address for user ${userId}`,
      );

      return res.status(400).json({
        status: false,
        message:
          "Authenticated user has no email address",
      });
    }

    const loginTime = Date.now();

    /*
     * Device/browser timezone supplied by Flutter.
     *
     * We validate it before using it in Intl.
     */
    const requestedTimezone =
      typeof req.body?.timeZone === "string"
        ? req.body.timeZone.trim()
        : "";

    const deviceTimezone =
      isValidTimezone(requestedTimezone)
        ? requestedTimezone
        : null;

    /*
     * Because Express is configured with:
     *
     * app.set("trust proxy", 1)
     *
     * req.ip represents the client IP forwarded
     * through our trusted Nginx proxy.
     */
    const clientIp = getClientIp(req);

    console.log(
      `🔐 Login detected for ${userId}`,
    );

    console.log(
      `🌍 Client IP: ${clientIp || "unknown"}`,
    );

    console.log(
      `🕐 Device timezone: ${
        deviceTimezone || "not supplied"
      }`,
    );

    /*
     * IP lookup must never block login security
     * processing if the external service fails.
     */
    const location =
      await getIpLocation(clientIp);

    /*
     * If the device timezone is unavailable,
     * IP geolocation timezone becomes the fallback.
     */
    const finalTimezone =
      deviceTimezone ||
      (
        location.timezone &&
        isValidTimezone(location.timezone)
          ? location.timezone
          : "UTC"
      );

    const title = "New Login Detected";

    const body =
      "A successful login to your GiftPay account was detected.";

    const db = admin.firestore();

    await db
      .collection("users")
      .doc(userId)
      .collection("notifications")
      .add({
        title,
        body,
        category: "security",
        type: "login",
        mandatory: true,

        createdAt:
          admin.firestore.Timestamp.fromMillis(
            loginTime,
          ),

        read: false,

        /*
         * Store security metadata for future
         * security-history screens.
         */
        loginIp: location.ipAddress || clientIp || null,

        loginTimezone: finalTimezone,

        loginLocation: {
          city: location.city || null,
          region: location.region || null,
          country: location.country || null,
          countryCode:
            location.countryCode || null,
        },
      });

    console.log(
      `🔐 Login security notification saved for user ${userId}`,
    );

    /*
     * Mandatory security email.
     *
     * This intentionally does NOT inspect:
     * emailAlerts
     * transactionUpdates
     * notification preferences
     */
    let emailSent = false;

    try {
      await sendLoginSecurityEmail({
        userId,
        email,
        loginTime,
        timeZone: finalTimezone,
        ipAddress:
          location.ipAddress ||
          clientIp ||
          null,
        location: {
          city: location.city || null,
          region: location.region || null,
          country: location.country || null,
          countryCode:
            location.countryCode || null,
        },
      });

      emailSent = true;

      console.log(
        `📧 Login security email sent to ${email}`,
      );
    } catch (emailError) {
      /*
       * Email failure must never prevent the login.
       */
      console.error(
        "⚠️ Login security email failed:",
        emailError.message,
      );
    }

    return res.status(200).json({
      status: true,
      message: "Login security alert processed",
      emailSent,
    });
  } catch (error) {
    /*
     * The frontend deliberately does not block login
     * based on this endpoint.
     */
    console.error(
      "💥 Login security alert error:",
      error.message,
    );

    return res.status(500).json({
      status: false,
      message:
        "Unable to process login security alert",
    });
  }
};