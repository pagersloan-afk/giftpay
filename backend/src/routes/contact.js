const express = require("express");
const router = express.Router();
const nodemailer = require("nodemailer");

// ------------------------------------------------------------
// UNIVERSAL EMAIL TRANSPORTER (Gmail + Custom Domain)
// ------------------------------------------------------------
function createTransporter() {
  const provider = process.env.MAIL_PROVIDER || "gmail";

  console.log("📨 MAIL PROVIDER:", provider);
  console.log("📨 MAIL_USER:", process.env.MAIL_USER);
  console.log("📨 SMTP_USER:", process.env.SMTP_USER);

  // ⭐ DEVELOPMENT: Gmail
  if (provider === "gmail") {
    console.log("📨 Using Gmail transporter...");

    return nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: process.env.MAIL_USER,
        pass: process.env.MAIL_PASS,
      },
    });
  }

  // ⭐ PRODUCTION: Custom Domain SMTP
  console.log("📨 Using Custom Domain SMTP transporter...");

  return nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT || 465),
    secure:
      process.env.SMTP_SECURE === "true" ||
      Number(process.env.SMTP_PORT || 465) === 465,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });
}

const transporter = createTransporter();

// ------------------------------------------------------------
// CONTACT ROUTE
// ------------------------------------------------------------
router.post("/contact", async (req, res) => {
  try {
    const { name, email, subject, message } = req.body;

    console.log("📩 Incoming contact submission:");
    console.log("Name:", name);
    console.log("Email:", email);
    console.log("Subject:", subject);
    console.log("Message:", message);

    // ------------------------------------------------------------
    // DETERMINE SENDER
    // ------------------------------------------------------------
    // Production:
    //   SMTP_USER = support@titleoneabstractny.com
    //
    // Gmail:
    //   MAIL_USER = your Gmail address
    //
    // This allows the same file to work in both environments.
    const senderEmail =
      process.env.MAIL_PROVIDER === "gmail"
        ? process.env.MAIL_USER
        : process.env.SMTP_USER;

    // ------------------------------------------------------------
    // 1️⃣ SEND TO PRODUCTION EMAIL + GMAIL
    // ------------------------------------------------------------
    const adminMailOptions = {
      from: `"Gift Technology Ltd" <${senderEmail}>`,
      replyTo: email,

      to: [
        process.env.SMTP_USER, // Production email
        process.env.MAIL_USER,  // Gmail copy
      ],

      subject: `New Contact Message: ${subject}`,

      text: `
Name: ${name}
Email: ${email}

Message:
${message}
      `,
    };

    console.log("📨 Sending admin email:", adminMailOptions);

    const adminResult = await transporter.sendMail(adminMailOptions);

    console.log("✅ Admin email sent!");
    console.log("📨 Nodemailer result:", adminResult);

    // ------------------------------------------------------------
    // 2️⃣ AUTO-REPLY TO VISITOR
    // ------------------------------------------------------------
    const autoReplyOptions = {
      from: `"Gift Technology Ltd" <${senderEmail}>`,
      to: email,

      subject: "We received your message",

      text: `
Hello ${name},

Thank you for contacting Gift Technology Ltd.

Your message has been received successfully, and our support team will get back to you shortly.

Here is a copy of your submission:

Subject: ${subject}
Message: ${message}

Best regards,
Gift Technology Ltd Support Team
      `,
    };

    console.log("📨 Sending auto-reply:", autoReplyOptions);

    const autoReplyResult = await transporter.sendMail(autoReplyOptions);

    console.log("✅ Auto-reply sent!");
    console.log("📨 Nodemailer result:", autoReplyResult);

    // ------------------------------------------------------------
    // DONE
    // ------------------------------------------------------------
    return res.status(200).json({ success: true });

  } catch (err) {
    console.error("❌ Email error:", err);

    return res.status(500).json({
      error: "Failed to send message",
    });
  }
});

module.exports = router;