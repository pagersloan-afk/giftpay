// backend/src/services/transactionPin.service.js
//
// Transaction PIN verification service.
//
// Supported existing formats:
//   1. Plain legacy PIN:       "2654"
//   2. Legacy encoded PIN:     "enc_2654"
//   3. Hardened scrypt format: "scrypt$N$r$p$salt$hash"
//
// Legacy PINs are accepted only for migration.
// After successful verification they are replaced with
// a salted scrypt hash.
//
// Firestore document:
//   users/{uid}
//
// Fields used:
//   transactionPin
//   transactionPinFailedAttempts
//   transactionPinLockedUntil
//
// Security:
//   - PIN is never logged.
//   - New PIN values are stored as salted scrypt hashes.
//   - Five failed attempts trigger a 15-minute lockout.
//   - Successful verification resets the failed-attempt counter.

const crypto = require("crypto");
const admin = require("firebase-admin");

const db = admin.firestore();

const MAX_ATTEMPTS = 5;
const LOCKOUT_MINUTES = 15;
const LOCKOUT_MS = LOCKOUT_MINUTES * 60 * 1000;

// scrypt parameters
const SCRYPT_N = 16384;
const SCRYPT_R = 8;
const SCRYPT_P = 1;
const KEY_LENGTH = 64;
const SALT_LENGTH = 16;

function normalizePin(pin) {
  return String(pin ?? "").trim();
}

function isValidPin(pin) {
  return /^\d{4}$/.test(pin);
}

function createScryptHash(pin) {
  const salt = crypto.randomBytes(SALT_LENGTH);

  const derivedKey = crypto.scryptSync(
    pin,
    salt,
    KEY_LENGTH,
    {
      N: SCRYPT_N,
      r: SCRYPT_R,
      p: SCRYPT_P,
      maxmem: 32 * 1024 * 1024,
    }
  );

  return [
    "scrypt",
    SCRYPT_N,
    SCRYPT_R,
    SCRYPT_P,
    salt.toString("base64"),
    derivedKey.toString("base64"),
  ].join("$");
}

function verifyScryptHash(storedValue, pin) {
  const parts = String(storedValue).split("$");

  if (parts.length !== 6 || parts[0] !== "scrypt") {
    return false;
  }

  const n = Number(parts[1]);
  const r = Number(parts[2]);
  const p = Number(parts[3]);

  const saltBase64 = parts[4];
  const hashBase64 = parts[5];

  if (
    !Number.isInteger(n) ||
    !Number.isInteger(r) ||
    !Number.isInteger(p) ||
    !saltBase64 ||
    !hashBase64
  ) {
    return false;
  }

  try {
    const salt = Buffer.from(saltBase64, "base64");
    const expectedHash = Buffer.from(hashBase64, "base64");

    if (!salt.length || !expectedHash.length) {
      return false;
    }

    const derivedKey = crypto.scryptSync(
      pin,
      salt,
      expectedHash.length,
      {
        N: n,
        r,
        p,
        maxmem: 32 * 1024 * 1024,
      }
    );

    if (derivedKey.length !== expectedHash.length) {
      return false;
    }

    return crypto.timingSafeEqual(
      derivedKey,
      expectedHash
    );
  } catch (error) {
    console.error(
      "❌ Transaction PIN hash verification failed:",
      error.message
    );

    return false;
  }
}

function isScryptHash(value) {
  return (
    typeof value === "string" &&
    value.startsWith("scrypt$")
  );
}

function isLegacyEncodedPin(value) {
  return (
    typeof value === "string" &&
    /^enc_\d{4}$/.test(value)
  );
}

function isLegacyPlainPin(value) {
  return (
    typeof value === "string" &&
    /^\d{4}$/.test(value)
  );
}

function parseLockedUntil(value) {
  if (value === null || value === undefined) {
    return 0;
  }

  if (typeof value === "number") {
    return Number.isFinite(value) ? value : 0;
  }

  if (value instanceof Date) {
    return value.getTime();
  }

  if (typeof value.toMillis === "function") {
    try {
      return value.toMillis();
    } catch (_) {
      return 0;
    }
  }

  const parsed = Date.parse(String(value));

  return Number.isFinite(parsed) ? parsed : 0;
}

async function verifyTransactionPin(userId, suppliedPin) {
  const normalizedUserId = String(userId ?? "").trim();
  const pin = normalizePin(suppliedPin);

  if (!normalizedUserId) {
    return {
      ok: false,
      code: "AUTH_REQUIRED",
    };
  }

  if (!isValidPin(pin)) {
    return {
      ok: false,
      code: "PIN_REQUIRED",
    };
  }

  const userRef = db
    .collection("users")
    .doc(normalizedUserId);

  const userSnap = await userRef.get();

  if (!userSnap.exists) {
    return {
      ok: false,
      code: "PIN_NOT_SET",
    };
  }

  const data = userSnap.data() || {};

  const storedPin =
    data.transactionPin ??
    data.authPin ??
    null;

  if (
    storedPin === null ||
    storedPin === undefined
  ) {
    return {
      ok: false,
      code: "PIN_NOT_SET",
    };
  }

  const now = Date.now();

  const lockedUntil = parseLockedUntil(
    data.transactionPinLockedUntil
  );

  if (lockedUntil > now) {
    return {
      ok: false,
      code: "PIN_LOCKED",
      lockedUntil,
    };
  }

  // Clear an expired lock.
  if (lockedUntil > 0 && lockedUntil <= now) {
    await userRef.set(
      {
        transactionPinLockedUntil:
          admin.firestore.FieldValue.delete(),

        transactionPinFailedAttempts: 0,
      },
      {
        merge: true,
      }
    );
  }

  let verified = false;
  let legacyFormat = false;

  // ---------------------------------------------
  // CURRENT SECURE FORMAT
  // ---------------------------------------------

  if (isScryptHash(storedPin)) {
    verified = verifyScryptHash(
      storedPin,
      pin
    );
  }

  // ---------------------------------------------
  // LEGACY FORMAT: enc_2654
  // ---------------------------------------------

  else if (isLegacyEncodedPin(storedPin)) {
    verified =
      storedPin.substring(4) === pin;

    legacyFormat = verified;
  }

  // ---------------------------------------------
  // LEGACY FORMAT: 2654
  // ---------------------------------------------
  //
  // This supports users whose existing Firestore
  // document currently contains the PIN directly.
  //
  // It is only used for migration.
  // Once verified successfully, it is immediately
  // converted to a salted scrypt hash.

  else if (isLegacyPlainPin(storedPin)) {
    verified = storedPin === pin;
    legacyFormat = verified;
  }

  // ---------------------------------------------
  // SUCCESS
  // ---------------------------------------------

  if (verified) {
    const update = {
      transactionPinFailedAttempts: 0,

      transactionPinLockedUntil:
        admin.firestore.FieldValue.delete(),
    };

    // Immediately migrate legacy PIN storage
    // to a secure salted scrypt hash.
    if (legacyFormat) {
      update.transactionPin =
        createScryptHash(pin);
    }

    await userRef.set(
      update,
      {
        merge: true,
      }
    );

    return {
      ok: true,
      migrated: legacyFormat,
    };
  }

  // ---------------------------------------------
  // FAILED PIN
  // ---------------------------------------------

  const currentAttempts = Number(
    data.transactionPinFailedAttempts || 0
  );

  const nextAttempts = currentAttempts + 1;

  // ---------------------------------------------
  // LOCK AFTER 5 FAILED ATTEMPTS
  // ---------------------------------------------

  if (nextAttempts >= MAX_ATTEMPTS) {
    const newLockedUntil =
      now + LOCKOUT_MS;

    await userRef.set(
      {
        transactionPinFailedAttempts: 0,

        transactionPinLockedUntil:
          newLockedUntil,
      },
      {
        merge: true,
      }
    );

    return {
      ok: false,
      code: "PIN_LOCKED",
      lockedUntil: newLockedUntil,
    };
  }

  // ---------------------------------------------
  // SAVE FAILED ATTEMPT
  // ---------------------------------------------

  await userRef.set(
    {
      transactionPinFailedAttempts:
        nextAttempts,
    },
    {
      merge: true,
    }
  );

  return {
    ok: false,
    code: "PIN_INVALID",
    attemptsRemaining:
      MAX_ATTEMPTS - nextAttempts,
  };
}

// -------------------------------------------------
// SET / UPDATE TRANSACTION PIN
// -------------------------------------------------

async function setTransactionPin(
  userId,
  pin
) {
  const normalizedUserId =
    String(userId ?? "").trim();

  const normalizedPin =
    normalizePin(pin);

  if (!normalizedUserId) {
    throw new Error(
      "User ID is required"
    );
  }

  if (!isValidPin(normalizedPin)) {
    throw new Error(
      "Transaction PIN must be exactly 4 digits"
    );
  }

  const userRef = db
    .collection("users")
    .doc(normalizedUserId);

  await userRef.set(
    {
      transactionPin:
        createScryptHash(normalizedPin),

      transactionPinFailedAttempts: 0,

      transactionPinLockedUntil:
        admin.firestore.FieldValue.delete(),

      onboardingStatus: "pin_set",
    },
    {
      merge: true,
    }
  );

  return {
    ok: true,
  };
}

module.exports = {
  verifyTransactionPin,
  setTransactionPin,
};