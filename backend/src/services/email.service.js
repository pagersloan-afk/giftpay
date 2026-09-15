const nodemailer = require("nodemailer");

// ============================================================
// CREATE MAIL TRANSPORTER
// ============================================================

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: Number(process.env.SMTP_PORT || 465),
  secure: Number(process.env.SMTP_PORT || 465) === 465,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

// ============================================================
// SEND EMAIL
// ============================================================

exports.sendEmail = async ({ to, subject, html }) => {
  if (!to) {
    throw new Error("Recipient email address is required");
  }

  if (!process.env.SMTP_USER || !process.env.SMTP_PASS) {
    throw new Error("Mail service is not configured");
  }

  return transporter.sendMail({
    from: `"GiftPay Security" <${process.env.SMTP_USER}>`,
    to,
    subject,
    html,
  });
};