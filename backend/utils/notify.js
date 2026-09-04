const admin = require("firebase-admin");
const { sendEmail } = require("../src/services/email.service");

// ============================================================
// SEND FCM PUSH NOTIFICATION
// ============================================================

async function sendPush(userId, title, body) {
  try {
    const db = admin.firestore();

    const userDoc = await db
      .collection("users")
      .doc(userId)
      .get();

    if (!userDoc.exists) {
      console.warn(
        `⚠️ Cannot send push notification: user ${userId} not found`
      );
      return;
    }

    const token = userDoc.data()?.fcmToken;

    if (!token) {
      console.log(
        `ℹ️ No FCM token for user ${userId}; skipping push notification`
      );
      return;
    }

    await admin.messaging().send({
      token,
      notification: {
        title,
        body,
      },
      android: {
        priority: "high",
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    });

    console.log(`📱 Push notification sent to user ${userId}`);
  } catch (error) {
    // Push failure must NOT break the transaction.
    console.error(
      `⚠️ Push notification failed for user ${userId}:`,
      error.message
    );
  }
}

// ============================================================
// DETERMINE WHETHER CATEGORY IS A TRANSACTION NOTIFICATION
// ============================================================
//
// These categories use:
//
// emailAlerts == true
// AND
// transactionUpdates != false
//
// ============================================================

function isTransactionNotification(category) {
  const transactionCategories = [
    "wallet",
    "electricity",
    "airtime",
    "data",
    "payment",
    "transfer",
    "cable",
    "giftcard",
    "betting",
    "transaction",
  ];

  return transactionCategories.includes(
    String(category || "").toLowerCase()
  );
}

// ============================================================
// SEND TRANSACTION EMAIL
// ============================================================

async function sendTransactionEmail({
  userId,
  email,
  title,
  body,
  category,
}) {
  try {
    if (!email) {
      console.log(
        `ℹ️ No email address found for user ${userId}; skipping email`
      );
      return;
    }

    const subject = `GiftPay — ${title}`;

    const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${escapeHtml(subject)}</title>
</head>

<body style="
  margin:0;
  padding:0;
  background:#f4f7fb;
  font-family:Arial,Helvetica,sans-serif;
  color:#1f2937;
">

  <div style="
    max-width:620px;
    margin:40px auto;
    background:#ffffff;
    border-radius:16px;
    overflow:hidden;
    box-shadow:0 8px 30px rgba(0,0,0,0.08);
  ">

    <div style="
      background:#273D68;
      padding:28px 30px;
      color:#ffffff;
    ">
      <div style="
        font-size:24px;
        font-weight:700;
        letter-spacing:0.3px;
      ">
        GiftPay
      </div>

      <div style="
        margin-top:6px;
        font-size:13px;
        color:#dbe7ff;
      ">
        Transaction Notification
      </div>
    </div>

    <div style="padding:32px 30px;">

      <h2 style="
        margin:0 0 14px 0;
        color:#273D68;
        font-size:21px;
      ">
        ${escapeHtml(title)}
      </h2>

      <p style="
        margin:0;
        font-size:16px;
        line-height:1.6;
        color:#4b5563;
      ">
        ${escapeHtml(body)}
      </p>

      <div style="
        margin-top:24px;
        padding:14px 16px;
        background:#f5f8ff;
        border-left:4px solid #4A6BB8;
        border-radius:8px;
        font-size:13px;
        color:#6b7280;
      ">
        Category: ${escapeHtml(category)}
      </div>

      <p style="
        margin-top:28px;
        font-size:13px;
        line-height:1.6;
        color:#6b7280;
      ">
        This is an automatic notification from your GiftPay account.
        If you did not authorize this transaction, please review your
        account immediately.
      </p>

    </div>

    <div style="
      padding:20px 30px;
      background:#f8fafc;
      border-top:1px solid #e5e7eb;
      font-size:12px;
      color:#9ca3af;
    ">
      © ${new Date().getFullYear()} GiftPay. All rights reserved.
    </div>

  </div>

</body>
</html>
`;

    await sendEmail({
      to: email,
      subject,
      html,
    });

    console.log(
      `📧 Transaction email sent to ${email} for user ${userId}`
    );
  } catch (error) {
    // IMPORTANT:
    // Email failure must NEVER cause the transaction itself to fail.
    console.error(
      `⚠️ Transaction email failed for user ${userId}:`,
      error.message
    );
  }
}

// ============================================================
// SEND MANDATORY LOGIN SECURITY EMAIL
// ============================================================
//
// IMPORTANT:
//
// This is intentionally SEPARATE from transaction email.
//
// It does NOT check:
//
//   emailAlerts
//   securityAlerts
//
// A successful login always generates this security notification.
//
// The backend can provide:
//
//   timeZone
//   ipAddress
//   location.city
//   location.region
//   location.country
//
// The timezone should be an IANA timezone such as:
//
//   America/New_York
//   America/Chicago
//   Europe/London
//   Africa/Lagos
//
// ============================================================

async function sendLoginSecurityEmail({
  userId,
  email,
  loginTime,
  timeZone,
  ipAddress,
  location,
}) {
  try {
    if (!email) {
      console.warn(
        `⚠️ Cannot send login security email: no email for user ${userId}`
      );
      return;
    }

    const subject = "GiftPay — New Login Detected";

    // ----------------------------------------------------------
    // VALIDATE / RESOLVE TIMEZONE
    // ----------------------------------------------------------

    let resolvedTimezone = "UTC";

    if (timeZone && typeof timeZone === "string") {
      try {
        // Intl throws if the timezone is invalid.
        new Intl.DateTimeFormat("en-US", {
          timeZone,
        }).format(new Date());

        resolvedTimezone = timeZone;
      } catch (timezoneError) {
        console.warn(
          `⚠️ Invalid login timezone "${timeZone}" for user ${userId}; falling back to UTC`
        );
      }
    }

    // ----------------------------------------------------------
    // FORMAT LOGIN TIME IN USER'S LOCAL TIMEZONE
    // ----------------------------------------------------------

    const loginDate = loginTime
      ? new Date(loginTime)
      : new Date();

    let formattedLoginTime;

    try {
      formattedLoginTime = new Intl.DateTimeFormat("en-US", {
        day: "numeric",
        month: "long",
        year: "numeric",
        hour: "numeric",
        minute: "2-digit",
        timeZone: resolvedTimezone,
        timeZoneName: "short",
      }).format(loginDate);
    } catch (error) {
      console.warn(
        `⚠️ Unable to format login time in ${resolvedTimezone}; falling back to UTC`
      );

      formattedLoginTime = new Intl.DateTimeFormat("en-US", {
        day: "numeric",
        month: "long",
        year: "numeric",
        hour: "numeric",
        minute: "2-digit",
        timeZone: "UTC",
        timeZoneName: "short",
      }).format(loginDate);

      resolvedTimezone = "UTC";
    }

    // ----------------------------------------------------------
    // APPROXIMATE LOCATION
    // ----------------------------------------------------------

    const city = location?.city || "";
    const region = location?.region || "";
    const country = location?.country || "";

    const locationParts = [
      city,
      region,
      country,
    ].filter(Boolean);

    const approximateLocation =
      locationParts.length > 0
        ? locationParts.join(", ")
        : "Unavailable";

    // ----------------------------------------------------------
    // SAFE HTML VALUES
    // ----------------------------------------------------------

    const safeEmail = escapeHtml(email);

    const safeFormattedLoginTime =
      escapeHtml(formattedLoginTime);

    const safeTimezone =
      escapeHtml(resolvedTimezone);

    const safeIpAddress =
      escapeHtml(ipAddress || "Unavailable");

    const safeLocation =
      escapeHtml(approximateLocation);

    // ----------------------------------------------------------
    // EMAIL HTML
    // ----------------------------------------------------------

    const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
  >
  <title>${escapeHtml(subject)}</title>
</head>

<body style="
  margin:0;
  padding:0;
  background:#f4f7fb;
  font-family:Arial,Helvetica,sans-serif;
  color:#1f2937;
">

  <div style="
    max-width:620px;
    margin:40px auto;
    background:#ffffff;
    border-radius:16px;
    overflow:hidden;
    box-shadow:0 8px 30px rgba(0,0,0,0.08);
  ">

    <!-- =====================================================
         HEADER
         ===================================================== -->

    <div style="
      background:#273D68;
      padding:28px 30px;
      color:#ffffff;
    ">

      <div style="
        font-size:24px;
        font-weight:700;
        letter-spacing:0.3px;
      ">
        GiftPay
      </div>

      <div style="
        margin-top:6px;
        font-size:13px;
        color:#dbe7ff;
      ">
        Account Security
      </div>

    </div>

    <!-- =====================================================
         CONTENT
         ===================================================== -->

    <div style="padding:32px 30px;">

      <div style="
        width:52px;
        height:52px;
        line-height:52px;
        text-align:center;
        border-radius:50%;
        background:#eef4ff;
        color:#273D68;
        font-size:25px;
        margin-bottom:20px;
      ">
        🔐
      </div>

      <h2 style="
        margin:0 0 14px 0;
        color:#273D68;
        font-size:22px;
      ">
        New Login Detected
      </h2>

      <p style="
        margin:0;
        font-size:16px;
        line-height:1.6;
        color:#4b5563;
      ">
        A successful login to your GiftPay account was detected.
      </p>

      <!-- ===================================================
           LOGIN DETAILS
           =================================================== -->

      <div style="
        margin-top:24px;
        border:1px solid #e5eaf2;
        border-radius:12px;
        overflow:hidden;
      ">

        <!-- ACCOUNT -->

        <div style="
          padding:16px 18px;
          border-bottom:1px solid #e5eaf2;
        ">

          <div style="
            font-size:12px;
            color:#7b8494;
            margin-bottom:6px;
          ">
            Account
          </div>

          <div style="
            font-size:15px;
            font-weight:600;
            color:#273D68;
            word-break:break-word;
          ">
            ${safeEmail}
          </div>

        </div>

        <!-- LOGIN TIME -->

        <div style="
          padding:16px 18px;
          border-bottom:1px solid #e5eaf2;
        ">

          <div style="
            font-size:12px;
            color:#7b8494;
            margin-bottom:6px;
          ">
            Login Time
          </div>

          <div style="
            font-size:15px;
            font-weight:600;
            color:#273D68;
          ">
            ${safeFormattedLoginTime}
          </div>

        </div>

        <!-- TIMEZONE -->

        <div style="
          padding:16px 18px;
          border-bottom:1px solid #e5eaf2;
        ">

          <div style="
            font-size:12px;
            color:#7b8494;
            margin-bottom:6px;
          ">
            Time Zone
          </div>

          <div style="
            font-size:15px;
            font-weight:600;
            color:#273D68;
            word-break:break-word;
          ">
            ${safeTimezone}
          </div>

        </div>

        <!-- APPROXIMATE LOCATION -->

        <div style="
          padding:16px 18px;
          border-bottom:1px solid #e5eaf2;
        ">

          <div style="
            font-size:12px;
            color:#7b8494;
            margin-bottom:6px;
          ">
            Approximate Location
          </div>

          <div style="
            font-size:15px;
            font-weight:600;
            color:#273D68;
            word-break:break-word;
          ">
            ${safeLocation}
          </div>

        </div>

        <!-- IP ADDRESS -->

        <div style="
          padding:16px 18px;
        ">

          <div style="
            font-size:12px;
            color:#7b8494;
            margin-bottom:6px;
          ">
            IP Address
          </div>

          <div style="
            font-size:15px;
            font-weight:600;
            color:#273D68;
            word-break:break-all;
          ">
            ${safeIpAddress}
          </div>

        </div>

      </div>

      <!-- ===================================================
           RECOGNIZED LOGIN
           =================================================== -->

      <p style="
        margin-top:28px;
        font-size:14px;
        line-height:1.7;
        color:#4b5563;
      ">
        If you recognize this login, no action is required.
      </p>

      <!-- ===================================================
           SECURITY WARNING
           =================================================== -->

      <div style="
        margin-top:18px;
        padding:16px;
        background:#fff7ed;
        border-left:4px solid #f59e0b;
        border-radius:8px;
        font-size:13px;
        line-height:1.6;
        color:#92400e;
      ">

        <strong>Didn't sign in?</strong><br>

        If you do not recognize this activity, please secure your
        GiftPay account immediately by changing your password and
        reviewing your trusted devices.

      </div>

      <!-- ===================================================
           SECURITY NOTICE
           =================================================== -->

      <p style="
        margin-top:28px;
        font-size:13px;
        line-height:1.6;
        color:#6b7280;
      ">
        This is a mandatory security notification associated with
        your GiftPay account.
      </p>

      <p style="
        margin-top:12px;
        font-size:12px;
        line-height:1.6;
        color:#9ca3af;
      ">
        Location information is approximate and is based on the
        network address associated with this login.
      </p>

    </div>

    <!-- =====================================================
         FOOTER
         ===================================================== -->

    <div style="
      padding:20px 30px;
      background:#f8fafc;
      border-top:1px solid #e5e7eb;
      font-size:12px;
      color:#9ca3af;
    ">

      © ${new Date().getFullYear()} GiftPay. All rights reserved.

    </div>

  </div>

</body>
</html>
`;

    await sendEmail({
      to: email,
      subject,
      html,
    });

    console.log(
      `🔐 Login security email sent to ${email} for user ${userId}`
    );
  } catch (error) {
    // IMPORTANT:
    // Failure to send the security email must NOT prevent
    // the user from completing login.
    console.error(
      `⚠️ Login security email failed for user ${userId}:`,
      error.message
    );
  }
}

// ============================================================
// BASIC HTML ESCAPE
// ============================================================

function escapeHtml(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

// ============================================================
// UNIFIED NOTIFICATION HELPER
// ============================================================
//
// Existing controllers can continue using:
//
// sendNotification(
//   userId,
//   title,
//   body,
//   category
// );
//
// No need to modify every transaction controller.
// ============================================================

async function sendNotification(
  userId,
  title,
  body,
  category = "system"
) {
  const db = admin.firestore();

  // ----------------------------------------------------------
  // GET USER PROFILE + NOTIFICATION PREFERENCES
  // ----------------------------------------------------------

  const userRef = db.collection("users").doc(userId);

  const userDoc = await userRef.get();

  if (!userDoc.exists) {
    console.warn(
      `⚠️ Notification skipped: user ${userId} does not exist`
    );
    return;
  }

  const userData = userDoc.data() || {};

  const email = String(userData.email || "").trim();

  // ----------------------------------------------------------
  // USER EMAIL PREFERENCES
  // ----------------------------------------------------------
  //
  // Transaction email requires:
  //
  // emailAlerts == true
  // AND
  // transactionUpdates != false
  //
  // ----------------------------------------------------------

  const emailAlerts =
    userData.emailAlerts === true;

  const transactionUpdates =
    userData.transactionUpdates !== false;

  const shouldSendTransactionEmail =
    isTransactionNotification(category) &&
    emailAlerts &&
    transactionUpdates &&
    email;

  console.log(
    `🔔 Notification preferences for ${userId}:`,
    {
      emailAlerts,
      transactionUpdates,
      category,
      emailEnabled: shouldSendTransactionEmail,
    }
  );

  // ----------------------------------------------------------
  // 1. SAVE NOTIFICATION TO FIRESTORE
  // ----------------------------------------------------------

  await userRef
    .collection("notifications")
    .add({
      title,
      body,
      category,
      createdAt: admin.firestore.Timestamp.now(),
      read: false,
    });

  console.log(
    `💾 Firestore notification saved for user ${userId}`
  );

  // ----------------------------------------------------------
  // 2. SEND PUSH NOTIFICATION
  // ----------------------------------------------------------

  await sendPush(
    userId,
    title,
    body
  );

  // ----------------------------------------------------------
  // 3. SEND EMAIL IF USER ENABLED TRANSACTION EMAILS
  // ----------------------------------------------------------

  if (shouldSendTransactionEmail) {
    await sendTransactionEmail({
      userId,
      email,
      title,
      body,
      category,
    });
  } else {
    console.log(
      `📧 Transaction email skipped for user ${userId}`
    );
  }
}

// ============================================================
// EXPORTS
// ============================================================

module.exports = {
  sendNotification,
  sendPush,
  sendLoginSecurityEmail,
};