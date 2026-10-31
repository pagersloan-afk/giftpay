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
            : (tx.createdAt && typeof tx.createdAt.toDate === "function")
              ? tx.createdAt.toDate().getTime()
              : Date.parse(tx.timestamp || tx.date || tx.createdAt) || 0,
        type: tx.category === "food_order" ? "food_order" : (tx.type || "wallet"),
        title: tx.title || (tx.category === "food_order" ? "GiftPay Food Order" : undefined),
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
    // 3. ENRICH FOOD ORDER WALLET TRANSACTIONS WITH LIVE ORDER STATUS
    // ---------------------------------------------------------
    const foodOrderSnap = await db.collection("foodOrders")
      .where("userId", "==", userId)
      .limit(100)
      .get();

    const foodOrdersById = new Map();
    for (const doc of foodOrderSnap.docs) {
      const order = doc.data() || {};
      foodOrdersById.set(doc.id, {
        id: doc.id,
        orderId: doc.id,
        type: "food_order",
        category: "food_order",
        title: "GiftPay Food Order",
        description: `Food order ${doc.id}`,
        amount: Number(order.total) || 0,
        currency: order.currency || "NGN",
        timestamp: order.createdAt && typeof order.createdAt.toDate === "function"
          ? order.createdAt.toDate().getTime()
          : Date.parse(order.createdAt || "") || Date.now(),
        status: order.status || "pending",
        paymentStatus: order.paymentStatus || "reserved",
        orderStatus: order.status || "pending",
        statusHistory: Array.isArray(order.statusHistory) ? order.statusHistory : [],
        reference: doc.id,
        orderId: doc.id,
      });
    }

    walletTx = walletTx.map((tx) => {
      if (tx.category !== "food_order") return tx;
      const orderId = String(tx.reference || "").trim();
      const order = foodOrdersById.get(orderId);
      if (!order) return tx;
      return {
        ...tx,
        ...order,
        id: tx.id || `${orderId}_debit`,
        title: "GiftPay Food Order",
        amount: Number(order.amount) || Number(tx.amount) || 0,
        type: "food_order",
        category: "food_order",
        status: order.orderStatus,
        paymentStatus: order.paymentStatus,
      };
    });

    // ---------------------------------------------------------
    // 4. FETCH BULK TRANSFER BATCHES
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
    // 4. REMOVE DUPLICATE SERVICE TRANSACTIONS
    // ---------------------------------------------------------
    // A wallet-funded service transaction is intentionally written
    // to two places:
    //   1. wallets/{uid}.transactions  -> debit + receipt details
    //   2. users/{uid}/transactions     -> provider/service record
    //
    // Both records use the same reference/id. They are ONE customer
    // transaction, so the history API must return only one copy.
    // We keep the wallet record because it contains the customer-
    // facing title such as "Airtime Purchase (080...)".
    // ---------------------------------------------------------
    // Keep the wallet record as the preferred customer-facing copy.
    // Build a key set from wallet records and remove only the matching
    // service duplicate.
    const walletReferences = new Set();

    for (const tx of walletTx) {
      const key =
        tx.id?.toString() ||
        tx.reference?.toString() ||
        tx.requestReference?.toString() ||
        tx.requestId?.toString() ||
        "";

      if (key) {
        walletReferences.add(key);
      }
    }

    const uniqueServiceTx = serviceTx.filter((tx) => {
      const key =
        tx.id?.toString() ||
        tx.reference?.toString() ||
        tx.requestReference?.toString() ||
        tx.requestId?.toString() ||
        "";

      return !key || !walletReferences.has(key);
    });

    // ---------------------------------------------------------
    // 5. MERGE ALL SOURCES
    // ---------------------------------------------------------
    const all = [
      ...walletTx,
      ...uniqueServiceTx,
      ...bulkTx,
    ];

    // ---------------------------------------------------------
    // 6. SORT NEWEST → OLDEST
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