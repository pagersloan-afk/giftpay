const { createClient } = require("@supabase/supabase-js");
const admin = require("firebase-admin");

const bucket = process.env.SUPABASE_KYC_BUCKET || "kyc-documents";
let supabaseClient;

function getSupabase() {
  if (supabaseClient) return supabaseClient;
  if (!process.env.SUPABASE_URL || !process.env.SUPABASE_SERVICE_ROLE_KEY) {
    const error = new Error("Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in backend .env.");
    error.statusCode = 503;
    throw error;
  }
  supabaseClient = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  return supabaseClient;
}

async function getKycDocumentUrls(req, res) {
  try {
    const adminUid = req.user?.uid;
    const applicantUid = String(req.params.uid || "").trim();
    if (!adminUid) return res.status(401).json({ status: false, message: "Authentication required." });
    if (!applicantUid) return res.status(400).json({ status: false, message: "Applicant UID is required." });

    const adminDoc = await admin.firestore().collection("users").doc(adminUid).get();
    const adminData = adminDoc.exists ? adminDoc.data() : {};
    if (!(adminData.isAdmin === true || String(adminData.role || "").toLowerCase() === "admin")) {
      return res.status(403).json({ status: false, message: "Administrator access required." });
    }

    const storage = getSupabase().storage.from(bucket);
    const names = { idFront: "id_front.jpg", idBack: "id_back.jpg", selfie: "selfie.jpg" };
    const documents = {};
    const missing = [];

    for (const [key, filename] of Object.entries(names)) {
      const path = `kyc/${applicantUid}/${filename}`;
      const { data, error } = await storage.createSignedUrl(path, 600);
      if (error || !data?.signedUrl) {
        documents[key] = null;
        missing.push(key);
        console.warn(`KYC ${key} unavailable for ${applicantUid}:`, error?.message || "No signed URL");
      } else {
        documents[key] = data.signedUrl;
      }
    }

    return res.json({ status: true, uid: applicantUid, expiresInSeconds: 600, documents, missing });
  } catch (error) {
    console.error("KYC document preview error:", error);
    return res.status(error.statusCode || 500).json({
      status: false,
      message: error.statusCode === 503 ? error.message : "Unable to retrieve KYC documents.",
    });
  }
}

module.exports = { getKycDocumentUrls };
