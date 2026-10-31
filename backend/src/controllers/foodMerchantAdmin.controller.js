const admin = require("firebase-admin");
const { sendEmail } = require("../services/email.service");
const { sendPush } = require("../../utils/notify");

const db = admin.firestore();

function escapeHtml(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

function approvalEmailHtml(merchantName) {
  const safeName = escapeHtml(merchantName || "your business");
  return `<!DOCTYPE html>
<html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>GiftPay Food Merchant Approved</title></head>
<body style="margin:0;padding:24px;background:#f4f7fb;font-family:Arial,Helvetica,sans-serif;color:#1f2937">
  <div style="max-width:620px;margin:20px auto;background:#fff;border-radius:14px;overflow:hidden">
    <div style="background:#273D68;padding:26px 30px;color:#fff;font-size:24px;font-weight:700">GiftPay</div>
    <div style="padding:30px">
      <h2 style="margin:0 0 16px;color:#273D68">Your food merchant application is approved!</h2>
      <p style="font-size:16px;line-height:1.7;color:#4b5563">Congratulations! Your application for <strong>${safeName}</strong> has been approved. Your food merchant account is now active.</p>
      <p style="font-size:14px;line-height:1.7;color:#6b7280">You can now sign in to GiftPay and continue to the food merchant features.</p>
    </div>
    <div style="padding:18px 30px;background:#f8fafc;border-top:1px solid #e5e7eb;font-size:12px;color:#9ca3af">© ${new Date().getFullYear()} GiftPay. All rights reserved.</div>
  </div>
</body></html>`;
}

exports.reviewFoodMerchantApplication = async (req, res) => {
  try {
    const adminUid = req.user?.uid;
    const applicantUid = String(req.params.uid || "").trim();
    const decision = String(req.body?.decision || "").toLowerCase();
    const notes = String(req.body?.notes || "").trim();
    const registrationChecked = req.body?.registrationChecked === true;
    const foodSafetyChecked = req.body?.foodSafetyChecked === true;

    if (!adminUid) {
      return res.status(401).json({ status: false, message: "Authentication required." });
    }
    if (!applicantUid) {
      return res.status(400).json({ status: false, message: "Merchant user ID is required." });
    }
    if (!["approved", "rejected"].includes(decision)) {
      return res.status(400).json({ status: false, message: "Decision must be approved or rejected." });
    }
    if (decision === "approved" && (!registrationChecked || !foodSafetyChecked)) {
      return res.status(400).json({ status: false, message: "Complete both verification checks before approval." });
    }
    if (decision === "rejected" && !notes) {
      return res.status(400).json({ status: false, message: "A rejection reason is required." });
    }
    if (adminUid === applicantUid) {
      return res.status(403).json({ status: false, message: "Administrators cannot review their own merchant application." });
    }

    const adminRef = db.collection("users").doc(adminUid);
    const adminDoc = await adminRef.get();
    const adminData = adminDoc.exists ? adminDoc.data() || {} : {};
    if (!(adminData.isAdmin === true || adminData.role === "admin")) {
      return res.status(403).json({ status: false, message: "Administrator access required." });
    }

    const merchantRef = db.collection("foodMerchants").doc(applicantUid);
    const userRef = db.collection("users").doc(applicantUid);
    const [merchantDoc, userDoc] = await Promise.all([merchantRef.get(), userRef.get()]);

    if (!merchantDoc.exists) {
      return res.status(404).json({ status: false, message: "Merchant application not found." });
    }
    if (!userDoc.exists) {
      return res.status(404).json({ status: false, message: "Applicant user profile not found." });
    }

    const userData = userDoc.data() || {};
    const registeredEmail = String(userData.email || "").trim();
    if (decision === "approved" && !registeredEmail) {
      return res.status(422).json({ status: false, message: "The applicant has no registered email address in users." + applicantUid + "." });
    }

    const merchantData = merchantDoc.data() || {};
    const merchantName = String(merchantData.restaurantName || "your business");
    const notificationTitle = decision === "approved"
      ? "Food Merchant Application Approved"
      : "Food Merchant Application Update";
    const notificationBody = decision === "approved"
      ? `Congratulations! Your application for ${merchantName} has been approved. Your food merchant account is now active.`
      : `Your application for ${merchantName} was not approved. Reason: ${notes}`;

    const notificationRef = userRef.collection("notifications").doc();

    await db.runTransaction(async (tx) => {
      const latestMerchant = await tx.get(merchantRef);
      if (!latestMerchant.exists) throw new Error("This application no longer exists.");
      if ((latestMerchant.data() || {}).status !== "pending") {
        throw new Error("This application has already been reviewed. Refresh the list.");
      }

      const now = admin.firestore.FieldValue.serverTimestamp();
      tx.update(merchantRef, {
        status: decision,
        isActive: decision === "approved",
        updatedAt: now,
        "verification.status": decision,
        "verification.registrationChecked": registrationChecked,
        "verification.foodSafetyPermitChecked": foodSafetyChecked,
        "verification.reviewedBy": adminUid,
        "verification.reviewedAt": now,
        "verification.reviewNotes": notes,
      });
      tx.set(notificationRef, {
        title: notificationTitle,
        body: notificationBody,
        category: "food_merchant",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        read: false,
      });
    });

    // Push is best-effort and does not determine whether approval succeeds.
    try {
      await sendPush(applicantUid, notificationTitle, notificationBody);
    } catch (pushError) {
      console.error("Food merchant push notification failed:", pushError.message);
    }

    // Approval email is mandatory for this event and deliberately bypasses
    // transaction email preferences. A mail failure does not undo approval.
    let emailSent = false;
    let emailError = null;
    if (decision === "approved") {
      try {
        await sendEmail({
          to: registeredEmail,
          subject: "GiftPay — Food Merchant Application Approved",
          html: approvalEmailHtml(merchantName),
        });
        emailSent = true;
      } catch (mailError) {
        emailError = mailError.message || "Email delivery failed";
        console.error(`Food merchant approval email failed for ${applicantUid}:`, emailError);
      }
    }

    return res.status(200).json({
      status: true,
      message: decision === "approved"
        ? "Merchant approved. In-app notification saved."
        : "Merchant application rejected. In-app notification saved.",
      decision,
      emailSent: decision === "approved" ? emailSent : null,
      emailError,
    });
  } catch (error) {
    const message = error.message || "Unable to review merchant application.";
    const statusCode = message.includes("already been reviewed") || message.includes("no longer exists") ? 409 : 500;
    console.error("Food merchant review error:", error);
    return res.status(statusCode).json({ status: false, message });
  }
};
