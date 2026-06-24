const admin = require("firebase-admin");

exports.getTransactionHistory = async (req, res) => {
  const { userId } = req.query;

  if (!userId) {
    return res.status(400).json({
      status: false,
      message: "Missing userId",
    });
  }

  try {
    const db = admin.firestore();

    // ---------------------------------------------------------
    // 1. FETCH WALLET TRANSACTIONS
    // ---------------------------------------------------------
    const walletDoc = await db.collection("wallets").doc(userId).get();

    let walletTx = [];
    if (walletDoc.exists) {
      walletTx = walletDoc.data().transactions || [];
    }

    // ⭐ CLEAN WALLET TRANSACTIONS
    walletTx = walletTx
      .filter((tx) => tx)
      .map((tx) => ({
        ...tx,
        amount: Number(tx.amount) || 0,
        timestamp:
          typeof tx.timestamp === "number"
            ? tx.timestamp
            : Date.parse(tx.timestamp || tx.date) || 0,
        type: tx.type || "wallet",
      }))
      .filter((tx) => tx.amount && tx.timestamp);

    // ---------------------------------------------------------
    // 2. FETCH SERVICE TRANSACTIONS (electricity, airtime, data)
    // ---------------------------------------------------------
    const txSnap = await db
      .collection("users")
      .doc(userId)
      .collection("transactions")
      .get();

    let serviceTx = txSnap.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    // ⭐ NORMALIZE SERVICE TRANSACTIONS
    serviceTx = serviceTx
  .map((tx) => {
    return {
      ...tx,

      // ⭐ FIXED: Electricity amounts must be rounded to whole Naira
      amount: tx.amount
        ? Number(tx.amount)
        : Math.round(Number(tx.amountcharged || "0")),

      // Preserve electricity type
      type: tx.type || "electricity",

      // Normalize timestamp
      timestamp:
        typeof tx.timestamp === "number"
          ? tx.timestamp
          : Date.parse(tx.timestamp || tx.date) || 0,
    };
  })
  .filter((tx) => tx.amount && tx.timestamp);


    // ---------------------------------------------------------
    // 3. MERGE BOTH SOURCES
    // ---------------------------------------------------------
    const all = [...walletTx, ...serviceTx];

    // ---------------------------------------------------------
    // 4. SORT NEWEST → OLDEST
    // ---------------------------------------------------------
    all.sort((a, b) => b.timestamp - a.timestamp);

    return res.json({
      status: true,
      data: all,
    });
  } catch (err) {
    console.error("Transaction history error:", err);
    return res.status(500).json({
      status: false,
      message: "Server error fetching history",
    });
  }
};
