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
    // 2. FETCH SERVICE TRANSACTIONS
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

    serviceTx = serviceTx
      .map((tx) => ({
        ...tx,
        amount: tx.amount
          ? Number(tx.amount)
          : Math.round(Number(tx.amountcharged || "0")),
        type: tx.type || "electricity",
        timestamp:
          typeof tx.timestamp === "number"
            ? tx.timestamp
            : Date.parse(tx.timestamp || tx.date) || 0,
      }))
      .filter((tx) => tx.amount && tx.timestamp);

    // ---------------------------------------------------------
    // 3. FETCH BULK TRANSFER BATCHES
    // ---------------------------------------------------------
    const bulkSnap = await db
      .collection("users")
      .doc(userId)
      .collection("bulk_transfers")
      .get();

    const bulkTx = bulkSnap.docs
      .map((doc) => {
        const batch = doc.data() || {};

        const rawTimestamp =
          batch.timestamp ||
          batch.createdAt ||
          batch.created_at ||
          batch.date;

        let timestamp = 0;

        if (typeof rawTimestamp === "number") {
          timestamp = rawTimestamp;
        } else if (rawTimestamp && typeof rawTimestamp.toDate === "function") {
          timestamp = rawTimestamp.toDate().getTime();
        } else if (rawTimestamp) {
          timestamp = Date.parse(rawTimestamp) || 0;
        }

        const recipients = Array.isArray(batch.recipients)
          ? batch.recipients
          : [];

        const recipientCount =
          Number(batch.recipientCount ?? batch.totalRecipients) ||
          recipients.length;

        const totalAmount = Number(
          batch.totalAmount ??
            batch.total_amount ??
            batch.amount ??
            batch.total ??
            0
        );

        return {
          id: doc.id,
          type: "bulk_transfer",
          title: "Bulk Transfer",
          description: `${recipientCount} recipient${
            recipientCount === 1 ? "" : "s"
          }`,
          amount: totalAmount,
          timestamp,
          batchReference:
            batch.batchReference ||
            batch.batch_reference ||
            doc.id,
          status: batch.status || "pending",
          recipientCount,
          recipients,
          successfulCount: Number(
            batch.successfulCount ?? batch.successful_count ?? 0
          ),
          failedCount: Number(
            batch.failedCount ?? batch.failed_count ?? 0
          ),
          pendingCount: Number(
            batch.pendingCount ?? batch.pending_count ?? 0
          ),
        };
      })
      // Keep batches with a valid date, including batches that
      // have not completed yet. Zero-amount batches are excluded.
      .filter((tx) => tx.amount > 0 && tx.timestamp > 0);

    // ---------------------------------------------------------
    // 4. MERGE ALL SOURCES
    // ---------------------------------------------------------
    const all = [...walletTx, ...serviceTx, ...bulkTx];

    // ---------------------------------------------------------
    // 5. SORT NEWEST → OLDEST
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