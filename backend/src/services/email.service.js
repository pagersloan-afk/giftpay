const nodemailer = require("nodemailer");

// ============================================================
// CREATE MAIL TRANSPORTER
// ============================================================

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.MAIL_USER,
    pass: process.env.MAIL_PASS,
  },
});

// ============================================================
// SEND EMAIL
// ============================================================

exports.sendEmail = async ({ to, subject, html }) => {
  if (!to) {
    throw new Error("Recipient email address is required");
  }

  if (!process.env.MAIL_USER || !process.env.MAIL_PASS) {
    throw new Error("Mail service is not configured");
  }

  return transporter.sendMail({
    from: `"GiftPay Security" <${process.env.MAIL_USER}>`,
    to,
    subject,
    html,
  });
};