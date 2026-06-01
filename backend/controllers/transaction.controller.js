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

    // ⭐ FILTER WALLET TRANSACTIONS (remove corrupted ones)
    walletTx = walletTx.filter((tx) => {
      if (!tx) return false;

      return (
        tx.amount !== null &&
        tx.amount !== undefined &&
        tx.title !== null &&
        tx.title !== undefined &&
        tx.type !== null &&
        tx.type !== undefined &&
        (tx.timestamp || tx.date)
      );
    });

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

    // ⭐ FILTER + NORMALIZE SERVICE TRANSACTIONS
    serviceTx = serviceTx.map((tx) => {
      return {
        ...tx,
        // normalize amount: prefer numeric amount, fallback to amountcharged string
        amount: tx.amount ?? parseInt(tx.amountcharged || "0", 10),

        // preserve electricity type so frontend can show ⚡ icon
        type: tx.type === "electricity" ? "electricity" : tx.type,

        // ensure timestamp is numeric: prefer timestamp, fallback to parsed date string
        timestamp:
          typeof tx.timestamp === "number"
            ? tx.timestamp
            : Date.parse(tx.timestamp || tx.date),
      };
    }).filter((tx) => tx.amount && tx.type && tx.timestamp);

    // ---------------------------------------------------------
    // 3. MERGE CLEAN TRANSACTIONS
    // ---------------------------------------------------------
    const all = [...walletTx, ...serviceTx];

    // ---------------------------------------------------------
    // 4. SORT DESCENDING BY DATE
    // ---------------------------------------------------------
    all.sort((a, b) => {
      const ta =
        typeof a.timestamp === "number"
          ? a.timestamp
          : Date.parse(a.timestamp || a.date);
      const tb =
        typeof b.timestamp === "number"
          ? b.timestamp
          : Date.parse(b.timestamp || b.date);
      return tb - ta;
    });

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
