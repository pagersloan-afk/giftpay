const nodemailer = require("nodemailer");

exports.sendEmail = async ({ to, subject, html }) => {
  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: process.env.MAIL_USER,
      pass: process.env.MAIL_PASS,
    },
  });

  return transporter.sendMail({
    from: `"GiftPay Security" <${process.env.MAIL_USER}>`,
    to,
    subject,
    html,
  });
};
