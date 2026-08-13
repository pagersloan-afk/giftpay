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

  // ⭐ PRODUCTION: Custom Domain (cPanel / Hostinger / Namecheap / WHM)
  console.log("📨 Using Custom Domain SMTP transporter...");
  return nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT),
    secure: process.env.SMTP_SECURE === "true",
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
    // 1️⃣ SEND TO ADMIN + YOUR GMAIL
    // ------------------------------------------------------------
    const adminMailOptions = {
      from: process.env.MAIL_USER, // Gmail account
      replyTo: email,              // Visitor email
      to: [
        process.env.SMTP_USER,     // support@gifttechnologyltd.com
        process.env.MAIL_USER      // giftbaker77@gmail.com
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
    // 2️⃣ AUTO‑REPLY TO VISITOR
    // ------------------------------------------------------------
    const autoReplyOptions = {
      from: process.env.MAIL_USER, // Gmail account
      to: email,                   // Visitor email
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
    return res.status(500).json({ error: "Failed to send message" });
  }
});

module.exports = router;
