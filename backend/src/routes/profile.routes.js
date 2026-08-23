const express = require("express");
const multer = require("multer");
const path = require("path");
const { createClient } = require("@supabase/supabase-js");
const ws = require("ws");
const admin = require("firebase-admin");

const router = express.Router();

// ============================================================
// SUPABASE
// ============================================================

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY,
  {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },

    // Node.js 20 does not provide native WebSocket support.
    // Supabase Realtime requires a WebSocket implementation.
    // The profile upload route itself uses Storage, but the
    // Supabase client initializes Realtime internally.
    realtime: {
      transport: ws,
    },
  }
);

const PROFILE_BUCKET =
  process.env.SUPABASE_PROFILE_BUCKET || "profile-pictures";

// ============================================================
// MULTER
// ============================================================
//
// Store the uploaded image in memory.
// We immediately send the bytes to Supabase.
// Nothing is permanently stored on the backend server.
//

const upload = multer({
  storage: multer.memoryStorage(),

  limits: {
    fileSize: 5 * 1024 * 1024, // 5 MB
  },

  fileFilter: (req, file, cb) => {
    const allowed = [
      "image/jpeg",
      "image/png",
      "image/webp",
    ];

    if (!allowed.includes(file.mimetype)) {
      return cb(
        new Error(
          "Only JPEG, PNG, and WebP images are allowed."
        )
      );
    }

    cb(null, true);
  },
});

// ============================================================
// FIREBASE AUTH MIDDLEWARE
// ============================================================
//
// Flutter sends:
//
// Authorization: Bearer FIREBASE_ID_TOKEN
//
// Firebase Admin verifies the token.
// The UID comes from Firebase itself.
// We NEVER trust a userId sent in the request body.
//

async function verifyFirebaseUser(req, res, next) {
  try {
    const authHeader = req.headers.authorization || "";

    if (!authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        status: false,
        message: "Missing Firebase authentication token.",
      });
    }

    const idToken = authHeader.substring(7).trim();

    if (!idToken) {
      return res.status(401).json({
        status: false,
        message: "Invalid Firebase authentication token.",
      });
    }

    const decodedToken = await admin.auth().verifyIdToken(idToken);

    req.firebaseUser = decodedToken;

    next();
  } catch (error) {
    console.error(
      "Firebase profile authentication error:",
      error.message || error
    );

    return res.status(401).json({
      status: false,
      message: "Your Firebase session is invalid or expired.",
    });
  }
}

// ============================================================
// PROFILE PICTURE UPLOAD
// ============================================================

router.post(
  "/profile/upload-picture",
  verifyFirebaseUser,
  upload.single("image"),
  async (req, res) => {
    try {
      const firebaseUser = req.firebaseUser;

      if (!firebaseUser || !firebaseUser.uid) {
        return res.status(401).json({
          status: false,
          message: "Unable to identify Firebase user.",
        });
      }

      const uid = firebaseUser.uid;

      // --------------------------------------------------------
      // Make sure an image was actually uploaded
      // --------------------------------------------------------

      if (!req.file) {
        return res.status(400).json({
          status: false,
          message: "No profile picture was uploaded.",
        });
      }

      // --------------------------------------------------------
      // Determine extension
      // --------------------------------------------------------

      let extension = "jpg";

      switch (req.file.mimetype) {
        case "image/png":
          extension = "png";
          break;

        case "image/webp":
          extension = "webp";
          break;

        case "image/jpeg":
        default:
          extension = "jpg";
          break;
      }

      // --------------------------------------------------------
      // Unique path
      //
      // Example:
      //
      // firebaseUid/profile_1723456789123.jpg
      //
      // Keeping files under the Firebase UID gives every user
      // their own logical storage folder.
      // --------------------------------------------------------

      const filePath =
        `${uid}/profile_${Date.now()}.${extension}`;

      console.log(
        `Uploading profile picture for Firebase UID: ${uid}`
      );

      // --------------------------------------------------------
      // Upload using SUPABASE SERVICE ROLE
      //
      // IMPORTANT:
      // This key NEVER goes to Flutter.
      // --------------------------------------------------------

      const { error: uploadError } = await supabase.storage
        .from(PROFILE_BUCKET)
        .upload(filePath, req.file.buffer, {
          contentType: req.file.mimetype,
          cacheControl: "3600",
          upsert: false,
        });

      if (uploadError) {
        console.error(
          "Supabase profile upload error:",
          uploadError
        );

        return res.status(500).json({
          status: false,
          message: "Unable to upload profile picture.",
        });
      }

      // --------------------------------------------------------
      // Generate public URL
      //
      // profile-pictures bucket must be PUBLIC.
      // --------------------------------------------------------

      const {
        data: publicUrlData,
      } = supabase.storage
        .from(PROFILE_BUCKET)
        .getPublicUrl(filePath);

      const publicUrl = publicUrlData?.publicUrl;

      if (!publicUrl) {
        return res.status(500).json({
          status: false,
          message:
            "Profile picture uploaded but URL could not be generated.",
        });
      }

      // --------------------------------------------------------
      // Save URL in Firestore
      //
      // users/{firebaseUid}
      // --------------------------------------------------------

      const userRef = admin
        .firestore()
        .collection("users")
        .doc(uid);

      await userRef.set(
        {
          profileUrl: publicUrl,
          profileStoragePath: filePath,
          profileUpdatedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        },
        {
          merge: true,
        }
      );

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      return res.json({
        status: true,
        message: "Profile picture uploaded successfully.",
        profileUrl: publicUrl,
        storagePath: filePath,
      });
    } catch (error) {
      console.error(
        "Profile picture upload error:",
        error.message || error
      );

      return res.status(500).json({
        status: false,
        message:
          error.message ||
          "Server error uploading profile picture.",
      });
    }
  }
);

// ============================================================
// MULTER / GENERAL ERROR HANDLER
// ============================================================

router.use((error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === "LIMIT_FILE_SIZE") {
      return res.status(400).json({
        status: false,
        message: "Profile picture must be 5 MB or smaller.",
      });
    }

    return res.status(400).json({
      status: false,
      message: error.message,
    });
  }

  if (error) {
    return res.status(400).json({
      status: false,
      message: error.message || "Invalid upload.",
    });
  }

  next();
});

module.exports = router;