module.exports = (otp) => `
<!DOCTYPE html>
<html>
<body style="background:#05060A;padding:40px;font-family:Arial;color:#E5E7EB;">
  <div style="max-width:480px;margin:auto;background:#0F1115;border-radius:18px;padding:28px;border:1px solid rgba(255,255,255,0.06);">
    <h2 style="color:#4FC3F7;text-shadow:0 0 12px rgba(79,195,247,0.55);">GiftPay Login OTP</h2>
    <p>Your one-time login code is:</p>
    <h1 style="font-size:32px;letter-spacing:6px;color:#FFFFFF;">${otp}</h1>
    <p>This code expires in 10 minutes. Do not share it with anyone.</p>
    <hr style="border-color:rgba(255,255,255,0.1);margin:24px 0;">
    <p style="font-size:12px;color:#9CA3AF;">If you did not request this, please secure your account immediately.</p>
  </div>
</body>
</html>
`;
