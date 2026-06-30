const { sendEmail } = require("../services/email.service");
const otpTemplate = require("../templates/otp_template");

exports.sendOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({
        status: false,
        message: "Email and OTP are required",
      });
    }

    const html = otpTemplate(otp);

    await sendEmail({
      to: email,
      subject: "Your GiftPay Login OTP",
      html,
    });

    return res.json({
      status: true,
      message: "OTP sent successfully",
    });

  } catch (err) {
    console.error("OTP Email Error:", err);
    return res.status(500).json({
      status: false,
      message: "Failed to send OTP email",
    });
  }
};
