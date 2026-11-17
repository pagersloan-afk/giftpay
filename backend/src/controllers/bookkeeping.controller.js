const admin = require("firebase-admin");
const { calculateLedger, validateSavingsSequence, summarizeDay } = require("../services/bookkeeping.calculations");

const db = admin.firestore();
const VALID_TYPES = new Set([
  "income",
  "expense",
  "savings_deposit",
  "savings_withdrawal",
]);

function userId(req) {
  return req.user?.uid || null;
}

function userRefs(uid) {
  const userRef = db.collection("users").doc(uid);
  return {
    settingsRef: userRef.collection("bookkeeping").doc("settings"),
    entriesRef: userRef.collection("bookkeepingEntries"),
  };
}

function fail(res, status, message) {
  return res.status(status).json({ status: false, message });
}

function parseAmountKobo(value) {
  if (!Number.isSafeInteger(value) || value <= 0) return null;
  return value;
}

function validDate(value) {
  if (typeof value !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return false;
  }
  const date = new Date(`${value}T00:00:00.000Z`);
  return !Number.isNaN(date.getTime()) && date.toISOString().slice(0, 10) === value;
}

function cleanText(value, max = 120) {
  return String(value || "").trim().slice(0, max);
}

async function loadBook(uid) {
  const { settingsRef, entriesRef } = userRefs(uid);
  const [settingsSnap, entriesSnap] = await Promise.all([
    settingsRef.get(),
    entriesRef.get(),
  ]);
  const settings = settingsSnap.exists ? settingsSnap.data() : {
    openingCashKobo: 0,
    openingSavingsKobo: 0,
    currency: "NGN",
  };
  const rawEntries = entriesSnap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  return { settings, settingsConfigured: settingsSnap.exists, rawEntries, ...calculateLedger(settings, rawEntries) };
}

exports.getBookkeepingDashboard = async (req, res) => {
  try {
    const uid = userId(req);
    if (!uid) return fail(res, 401, "Please sign in to access your bookkeeping records.");
    const date = String(req.query.date || new Date().toISOString().slice(0, 10));
    if (!validDate(date)) return fail(res, 400, "The bookkeeping summary date is invalid.");
    const book = await loadBook(uid);
    const latestEntries = [...book.entries].reverse().slice(0, 100);
    const dailySummary = summarizeDay(book.settings, book.entries, date);
    return res.json({
      status: true,
      data: {
        settings: book.settings,
        settingsConfigured: book.settingsConfigured,
        summary: book.summary,
        dailySummary,
        entries: latestEntries,
      },
    });
  } catch (error) {
    console.error("Bookkeeping dashboard error:", error.message || error);
    return fail(res, 500, "Unable to load your bookkeeping records right now.");
  }
};

exports.getBookkeepingEntries = async (req, res) => {
  try {
    const uid = userId(req);
    if (!uid) return fail(res, 401, "Please sign in to access your bookkeeping records.");
    const { from, to } = req.query;
    if (from && !validDate(String(from))) return fail(res, 400, "The start date is invalid.");
    if (to && !validDate(String(to))) return fail(res, 400, "The end date is invalid.");
    if (from && to && String(from) > String(to)) return fail(res, 400, "The start date must be before the end date.");

    const book = await loadBook(uid);
    const filtered = book.entries.filter((entry) =>
      (!from || entry.entryDate >= String(from)) && (!to || entry.entryDate <= String(to))
    );
    return res.json({ status: true, data: { entries: filtered.reverse() } });
  } catch (error) {
    console.error("Bookkeeping entries error:", error.message || error);
    return fail(res, 500, "Unable to load bookkeeping entries.");
  }
};

exports.setOpeningBalances = async (req, res) => {
  try {
    const uid = userId(req);
    if (!uid) return fail(res, 401, "Please sign in to set up your cashbook.");
    const openingCashKobo = req.body?.openingCashKobo ?? 0;
    const openingSavingsKobo = req.body?.openingSavingsKobo ?? 0;
    if (![openingCashKobo, openingSavingsKobo].every((n) => Number.isSafeInteger(n) && n >= 0)) {
      return fail(res, 400, "Opening balances must be valid amounts in kobo.");
    }

    const { settingsRef, entriesRef } = userRefs(uid);
    await db.runTransaction(async (tx) => {
      const [settingsSnap, entriesSnap] = await Promise.all([
        tx.get(settingsRef),
        tx.get(entriesRef),
      ]);
      const activeEntries = entriesSnap.docs
        .filter((doc) => !doc.data().voided)
        .map((doc) => ({ id: doc.id, ...doc.data() }));

      const validationError = validateSavingsSequence(
        { openingSavingsKobo },
        activeEntries,
      );
      if (validationError) {
        const error = new Error(
          `These opening savings balances cannot be applied to your existing transactions. ${validationError} Remove or correct the affected transaction first, or reset your cashbook.`,
        );
        error.statusCode = 409;
        throw error;
      }

      tx.set(settingsRef, {
        openingCashKobo,
        openingSavingsKobo,
        currency: "NGN",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        ...(settingsSnap.exists
          ? {}
          : { createdAt: admin.firestore.FieldValue.serverTimestamp() }),
      }, { merge: true });
    });

    return res.json({
      status: true,
      message: "Opening balances saved.",
    });
  } catch (error) {
    if (error.statusCode) return fail(res, error.statusCode, error.message);
    console.error("Bookkeeping opening balance error:", error.message || error);
    return fail(res, 500, "Unable to save your opening balances.");
  }
};

// Reset only this authenticated user's bookkeeping book. Existing entries are
// retained as voided audit records; wallet balances and wallet transactions
// are never accessed by this operation.
exports.resetBookkeeping = async (req, res) => {
  try {
    const uid = userId(req);
    if (!uid) return fail(res, 401, "Please sign in to reset your bookkeeping records.");

    const { settingsRef, entriesRef } = userRefs(uid);
    const resetRef = db.collection("users").doc(uid)
      .collection("bookkeepingResets").doc();

    // Mark records in bounded batches to stay below Firestore's 500-write limit.
    // The reset audit is written only after all entry batches have succeeded.
    let snapshot;
    do {
      snapshot = await entriesRef.get();
      const activeDocs = snapshot.docs.filter((doc) => !doc.data().voided);
      if (activeDocs.length === 0) break;

      for (let offset = 0; offset < activeDocs.length; offset += 400) {
        const batch = db.batch();
        const chunk = activeDocs.slice(offset, offset + 400);
        chunk.forEach((doc) => {
          batch.update(doc.ref, {
            voided: true,
            voidedAt: admin.firestore.FieldValue.serverTimestamp(),
            resetAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        });
        await batch.commit();
      }
    } while (true);

    const batch = db.batch();
    batch.delete(settingsRef);
    batch.set(resetRef, {
      resetAt: admin.firestore.FieldValue.serverTimestamp(),
      resetBy: uid,
      entriesVoided: true,
      reason: "User-requested bookkeeping reset",
    });
    await batch.commit();

    return res.json({
      status: true,
      message: "Your bookkeeping records have been reset. You can now set new opening balances.",
    });
  } catch (error) {
    console.error("Bookkeeping reset error:", error.message || error);
    return fail(
      res,
      500,
      "Unable to complete the bookkeeping reset. Please refresh and try again. If the problem continues, contact support.",
    );
  }
};


exports.getBookkeepingReport = async (req, res) => {
  try {
    const uid = userId(req);
    if (!uid) return fail(res, 401, "Please sign in to access your bookkeeping report.");
    const { from, to } = req.query;
    if (!validDate(String(from || "")) || !validDate(String(to || ""))) {
      return fail(res, 400, "Choose a valid report start date and end date.");
    }
    if (String(from) > String(to)) {
      return fail(res, 400, "The report start date must be before or equal to the end date.");
    }

    const book = await loadBook(uid);
    const before = book.entries.filter((entry) => entry.entryDate < String(from));
    const within = book.entries.filter((entry) =>
      entry.entryDate >= String(from) && entry.entryDate <= String(to)
    );
    const initialCash = Number(book.settings.openingCashKobo || 0);
    const initialSavings = Number(book.settings.openingSavingsKobo || 0);
    const previous = before.length ? before[before.length - 1] : null;
    const openingCashKobo = previous
      ? Number(previous.cashBalanceAfterKobo || 0) : initialCash;
    const openingSavingsKobo = previous
      ? Number(previous.savingsBalanceAfterKobo || 0) : initialSavings;

    const totals = {
      incomeKobo: 0, expenseKobo: 0,
      savingsDepositsKobo: 0, savingsWithdrawalsKobo: 0,
    };
    for (const entry of within) {
      const amount = Number(entry.amountKobo || 0);
      if (entry.type === "income") totals.incomeKobo += amount;
      if (entry.type === "expense") totals.expenseKobo += amount;
      if (entry.type === "savings_deposit") totals.savingsDepositsKobo += amount;
      if (entry.type === "savings_withdrawal") totals.savingsWithdrawalsKobo += amount;
    }
    const last = within.length ? within[within.length - 1] : null;
    const closingCashKobo = last
      ? Number(last.cashBalanceAfterKobo || 0) : openingCashKobo;
    const closingSavingsKobo = last
      ? Number(last.savingsBalanceAfterKobo || 0) : openingSavingsKobo;

    return res.json({
      status: true,
      data: {
        currency: "NGN",
        from: String(from),
        to: String(to),
        openingCashKobo,
        openingSavingsKobo,
        ...totals,
        closingCashKobo,
        closingSavingsKobo,
        netCashMovementKobo: totals.incomeKobo - totals.expenseKobo -
          totals.savingsDepositsKobo + totals.savingsWithdrawalsKobo,
        transactionCount: within.length,
        entries: within,
      },
    });
  } catch (error) {
    console.error("Bookkeeping report error:", error.message || error);
    return fail(res, 500, "Unable to generate your bookkeeping report.");
  }
};

exports.createBookkeepingEntry = async (req, res) => {
  try {
    const uid = userId(req);
    if (!uid) return fail(res, 401, "Please sign in to add a transaction.");
    const type = cleanText(req.body?.type, 32);
    const description = cleanText(req.body?.description, 120);
    const category = cleanText(req.body?.category, 60);
    const notes = cleanText(req.body?.notes, 500);
    const entryDate = String(req.body?.entryDate || "");
    const amountKobo = parseAmountKobo(req.body?.amountKobo);

    if (!VALID_TYPES.has(type)) return fail(res, 400, "Choose a valid transaction type.");
    if (!description) return fail(res, 400, "Enter a transaction description.");
    if (!validDate(entryDate)) return fail(res, 400, "Choose a valid transaction date.");
    if (!amountKobo) return fail(res, 400, "Enter an amount greater than zero.");

    const { settingsRef, entriesRef } = userRefs(uid);
    const entryRef = entriesRef.doc();
    const createdAt = admin.firestore.Timestamp.now();
    await db.runTransaction(async (tx) => {
      const [settingsSnap, entriesSnap] = await Promise.all([
        tx.get(settingsRef),
        tx.get(entriesRef),
      ]);
      if (!settingsSnap.exists) {
        const error = new Error("Set your opening cash and savings balances before adding your first transaction.");
        error.statusCode = 409;
        throw error;
      }
      const settings = settingsSnap.data();
      const existing = entriesSnap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
      const candidate = {
        id: entryRef.id, type, description, category, notes, entryDate, amountKobo,
        createdAt, voided: false,
      };
      const validationError = validateSavingsSequence(settings, [...existing, candidate]);
      if (validationError) {
        const error = new Error(validationError);
        error.statusCode = 400;
        throw error;
      }
      tx.create(entryRef, {
        type, description, category, notes, entryDate, amountKobo,
        voided: false,
        createdAt,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    return res.status(201).json({ status: true, message: "Transaction added to your cashbook.", data: { id: entryRef.id } });
  } catch (error) {
    if (error.statusCode) return fail(res, error.statusCode, error.message);
    console.error("Bookkeeping create entry error:", error.message || error);
    return fail(res, 500, "Unable to add this transaction. Please try again.");
  }
};

exports.updateBookkeepingEntry = async (req, res) => {
  try {
    const uid = userId(req);
    if (!uid) return fail(res, 401, "Please sign in to update this transaction.");
    const { settingsRef, entriesRef } = userRefs(uid);
    const entryRef = entriesRef.doc(String(req.params.id || ""));
    const type = cleanText(req.body?.type, 32);
    const description = cleanText(req.body?.description, 120);
    const category = cleanText(req.body?.category, 60);
    const notes = cleanText(req.body?.notes, 500);
    const entryDate = String(req.body?.entryDate || "");
    const amountKobo = parseAmountKobo(req.body?.amountKobo);
    if (!VALID_TYPES.has(type) || !description || !validDate(entryDate) || !amountKobo) {
      return fail(res, 400, "Please provide a valid transaction type, description, date and amount.");
    }

    await db.runTransaction(async (tx) => {
      const [settingsSnap, entriesSnap] = await Promise.all([
        tx.get(settingsRef),
        tx.get(entriesRef),
      ]);
      const currentDoc = entriesSnap.docs.find((doc) => doc.id === entryRef.id);
      if (!currentDoc || currentDoc.data().voided) {
        const error = new Error("This bookkeeping transaction could not be found.");
        error.statusCode = 404;
        throw error;
      }
      if (Array.isArray(currentDoc.data().goalAllocations) && currentDoc.data().goalAllocations.length) {
        const error = new Error("This savings-goal transaction cannot be edited here. Remove it and record the contribution or withdrawal again so goal balances remain accurate.");
        error.statusCode = 409;
        throw error;
      }
      const settings = settingsSnap.exists ? settingsSnap.data() : {};
      const replacement = {
        id: entryRef.id, type, description, category, notes, entryDate, amountKobo,
        createdAt: currentDoc.data().createdAt,
        voided: false,
      };
      const updatedEntries = entriesSnap.docs.map((doc) =>
        doc.id === entryRef.id ? replacement : { id: doc.id, ...doc.data() }
      );
      const validationError = validateSavingsSequence(settings, updatedEntries);
      if (validationError) {
        const error = new Error(validationError);
        error.statusCode = 400;
        throw error;
      }
      tx.update(entryRef, {
        type, description, category, notes, entryDate, amountKobo,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    return res.json({ status: true, message: "Bookkeeping transaction updated." });
  } catch (error) {
    if (error.statusCode) return fail(res, error.statusCode, error.message);
    console.error("Bookkeeping update entry error:", error.message || error);
    return fail(res, 500, "Unable to update this transaction.");
  }
};

exports.voidBookkeepingEntry = async (req, res) => {
  try {
    const uid = userId(req);
    if (!uid) return fail(res, 401, "Please sign in to remove this transaction.");
    const { settingsRef, entriesRef } = userRefs(uid);
    const entryRef = entriesRef.doc(String(req.params.id || ""));

    await db.runTransaction(async (tx) => {
      const [settingsSnap, entriesSnap] = await Promise.all([
        tx.get(settingsRef),
        tx.get(entriesRef),
      ]);
      const currentDoc = entriesSnap.docs.find((doc) => doc.id === entryRef.id);
      if (!currentDoc || currentDoc.data().voided) {
        const error = new Error("This bookkeeping transaction could not be found.");
        error.statusCode = 404;
        throw error;
      }
      const updatedEntries = entriesSnap.docs
        .filter((doc) => doc.id !== entryRef.id)
        .map((doc) => ({ id: doc.id, ...doc.data() }));
      const validationError = validateSavingsSequence(
        settingsSnap.exists ? settingsSnap.data() : {},
        updatedEntries,
      );
      if (validationError) {
        const error = new Error(validationError);
        error.statusCode = 409;
        throw error;
      }
      tx.update(entryRef, {
        voided: true,
        voidedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    return res.json({ status: true, message: "Transaction removed from your active cashbook." });
  } catch (error) {
    if (error.statusCode) return fail(res, error.statusCode, error.message);
    console.error("Bookkeeping void entry error:", error.message || error);
    return fail(res, 500, "Unable to remove this transaction.");
  }
};


function planningRefs(uid) {
  const userRef = db.collection("users").doc(uid);
  return {
    budgetsRef: userRef.collection("bookkeepingBudgets"),
    goalsRef: userRef.collection("bookkeepingSavingsGoals"),
  };
}

function safeAmount(value, allowZero = false) {
  return Number.isSafeInteger(value) && (allowZero ? value >= 0 : value > 0);
}

function periodRange(period, date = new Date()) {
  const d = new Date(`${date.toISOString().slice(0, 10)}T00:00:00.000Z`);
  if (period === "weekly") {
    const weekday = d.getUTCDay();
    const diff = weekday === 0 ? -6 : 1 - weekday;
    d.setUTCDate(d.getUTCDate() + diff);
  } else {
    d.setUTCDate(1);
  }
  const start = d.toISOString().slice(0, 10);
  const endDate = new Date(d);
  if (period === "weekly") endDate.setUTCDate(endDate.getUTCDate() + 6);
  else endDate.setUTCMonth(endDate.getUTCMonth() + 1, 0);
  return { start, end: endDate.toISOString().slice(0, 10) };
}

function goalBalances(goals, entries) {
  const balances = new Map(goals.map((goal) => [goal.id, 0]));
  for (const entry of entries.filter((item) => !item.voided)) {
    const allocations = Array.isArray(entry.goalAllocations) ? entry.goalAllocations : [];
    for (const allocation of allocations) {
      const id = String(allocation.goalId || "");
      if (!balances.has(id)) continue;
      balances.set(id, balances.get(id) + Number(allocation.amountKobo || 0));
    }
  }
  return balances;
}

exports.getBookkeepingPlanning = async (req, res) => {
  try {
    const uid = userId(req);
    if (!uid) return fail(res, 401, "Please sign in to access your budgets and savings goals.");
    const { budgetsRef, goalsRef } = planningRefs(uid);
    const { entriesRef } = userRefs(uid);
    const [budgetsSnap, goalsSnap, entriesSnap] = await Promise.all([
      budgetsRef.get(), goalsRef.get(), entriesRef.get(),
    ]);
    const entries = entriesSnap.docs.map((doc) => ({ id: doc.id, ...doc.data() }))
      .filter((entry) => !entry.voided);
    const goals = goalsSnap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    const balances = goalBalances(goals, entries);
    const requestedDate = String(req.query.date || new Date().toISOString().slice(0, 10));
    if (!validDate(requestedDate)) return fail(res, 400, "The budget summary date is invalid.");
    const planningDate = new Date(`${requestedDate}T12:00:00.000Z`);
    const budgets = budgetsSnap.docs.map((doc) => {
      const budget = { id: doc.id, ...doc.data() };
      const range = periodRange(budget.period, planningDate);
      const category = String(budget.category || "all").trim().toLowerCase();
      const spentKobo = entries.reduce((sum, entry) => {
        if (entry.type !== "expense" || entry.entryDate < range.start || entry.entryDate > range.end) return sum;
        if (category !== "all" && String(entry.category || "").trim().toLowerCase() !== category) return sum;
        return sum + Number(entry.amountKobo || 0);
      }, 0);
      return { ...budget, periodStart: range.start, periodEnd: range.end, spentKobo,
        remainingKobo: Number(budget.limitKobo || 0) - spentKobo,
        percentUsed: Number(budget.limitKobo || 0) > 0 ? spentKobo / Number(budget.limitKobo) : 0 };
    });
    return res.json({
      status: true,
      data: {
        budgets,
        goals: goals.map((goal) => {
          const savedKobo = balances.get(goal.id) || 0;
          const targetKobo = Number(goal.targetKobo || 0);
          return { ...goal, savedKobo, remainingKobo: targetKobo - savedKobo,
            percentComplete: targetKobo > 0 ? savedKobo / targetKobo : 0 };
        }),
      },
    });
  } catch (error) {
    console.error("Bookkeeping planning error:", error.message || error);
    return fail(res, 500, "Unable to load budgets and savings goals.");
  }
};

exports.createBookkeepingBudget = async (req, res) => {
  try {
    const uid = userId(req);
    if (!uid) return fail(res, 401, "Please sign in to create a budget.");
    const name = cleanText(req.body?.name, 80);
    const category = cleanText(req.body?.category || "all", 60) || "all";
    const period = String(req.body?.period || "");
    const limitKobo = req.body?.limitKobo;
    if (!name || !["weekly", "monthly"].includes(period) || !safeAmount(limitKobo)) {
      return fail(res, 400, "Enter a budget name, valid weekly or monthly period, and a limit greater than zero.");
    }
    const { budgetsRef } = planningRefs(uid);
    const ref = budgetsRef.doc();
    await ref.set({
      name, category, period, limitKobo, currency: "NGN",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return res.status(201).json({ status: true, message: "Budget created.", data: { id: ref.id } });
  } catch (error) {
    console.error("Create bookkeeping budget error:", error.message || error);
    return fail(res, 500, "Unable to create this budget.");
  }
};

exports.updateBookkeepingBudget = async (req, res) => {
  try {
    const uid = userId(req);
    if (!uid) return fail(res, 401, "Please sign in to update a budget.");
    const { budgetsRef } = planningRefs(uid);
    const ref = budgetsRef.doc(String(req.params.id || ""));
    const name = cleanText(req.body?.name, 80);
    const category = cleanText(req.body?.category || "all", 60) || "all";
    const period = String(req.body?.period || "");
    const limitKobo = req.body?.limitKobo;
    if (!name || !["weekly", "monthly"].includes(period) || !safeAmount(limitKobo)) {
      return fail(res, 400, "Enter a budget name, valid weekly or monthly period, and a limit greater than zero.");
    }
    const snap = await ref.get();
    if (!snap.exists) return fail(res, 404, "Budget not found.");
    await ref.update({ name, category, period, limitKobo, updatedAt: admin.firestore.FieldValue.serverTimestamp() });
    return res.json({ status: true, message: "Budget updated." });
  } catch (error) {
    console.error("Update bookkeeping budget error:", error.message || error);
    return fail(res, 500, "Unable to update this budget.");
  }
};

exports.deleteBookkeepingBudget = async (req, res) => {
  try {
    const uid = userId(req);
    if (!uid) return fail(res, 401, "Please sign in to delete a budget.");
    const { budgetsRef } = planningRefs(uid);
    const ref = budgetsRef.doc(String(req.params.id || ""));
    const snap = await ref.get();
    if (!snap.exists) return fail(res, 404, "Budget not found.");
    await ref.delete();
    return res.json({ status: true, message: "Budget deleted." });
  } catch (error) {
    console.error("Delete bookkeeping budget error:", error.message || error);
    return fail(res, 500, "Unable to delete this budget.");
  }
};

exports.createBookkeepingSavingsGoal = async (req, res) => {
  try {
    const uid = userId(req);
    if (!uid) return fail(res, 401, "Please sign in to create a savings target.");
    const name = cleanText(req.body?.name, 80);
    const targetKobo = req.body?.targetKobo;
    const targetDate = req.body?.targetDate ? String(req.body.targetDate) : "";
    if (!name || !safeAmount(targetKobo) || (targetDate && !validDate(targetDate))) {
      return fail(res, 400, "Enter a goal name, a target amount greater than zero, and a valid optional target date.");
    }
    const { goalsRef } = planningRefs(uid);
    const ref = goalsRef.doc();
    await ref.set({
      name, targetKobo, targetDate: targetDate || null, status: "active", currency: "NGN",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return res.status(201).json({ status: true, message: "Savings target created.", data: { id: ref.id } });
  } catch (error) {
    console.error("Create savings goal error:", error.message || error);
    return fail(res, 500, "Unable to create this savings target.");
  }
};

exports.updateBookkeepingSavingsGoal = async (req, res) => {
  try {
    const uid = userId(req);
    if (!uid) return fail(res, 401, "Please sign in to update a savings target.");
    const { goalsRef } = planningRefs(uid);
    const ref = goalsRef.doc(String(req.params.id || ""));
    const name = cleanText(req.body?.name, 80);
    const targetKobo = req.body?.targetKobo;
    const targetDate = req.body?.targetDate ? String(req.body.targetDate) : "";
    const status = String(req.body?.status || "active");
    if (!name || !safeAmount(targetKobo) || (targetDate && !validDate(targetDate)) ||
        !["active", "paused", "completed"].includes(status)) {
      return fail(res, 400, "Enter valid savings target details.");
    }
    const snap = await ref.get();
    if (!snap.exists) return fail(res, 404, "Savings target not found.");
    await ref.update({
      name, targetKobo, targetDate: targetDate || null, status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return res.json({ status: true, message: "Savings target updated." });
  } catch (error) {
    console.error("Update savings goal error:", error.message || error);
    return fail(res, 500, "Unable to update this savings target.");
  }
};

exports.deleteBookkeepingSavingsGoal = async (req, res) => {
  try {
    const uid = userId(req);
    if (!uid) return fail(res, 401, "Please sign in to delete a savings target.");
    const { goalsRef } = planningRefs(uid);
    const { entriesRef } = userRefs(uid);
    const ref = goalsRef.doc(String(req.params.id || ""));
    await db.runTransaction(async (tx) => {
      const [goalSnap, entriesSnap] = await Promise.all([
        tx.get(ref), tx.get(entriesRef),
      ]);
      if (!goalSnap.exists) {
        const error = new Error("Savings target not found.");
        error.statusCode = 404;
        throw error;
      }
      const hasMovements = entriesSnap.docs.some((doc) =>
        !doc.data().voided && Array.isArray(doc.data().goalAllocations) &&
        doc.data().goalAllocations.some((item) => item.goalId === ref.id)
      );
      if (hasMovements) {
        const error = new Error("This target has savings activity. Pause it instead of deleting it so its history remains available.");
        error.statusCode = 409;
        throw error;
      }
      tx.delete(ref);
    });
    return res.json({ status: true, message: "Savings target deleted." });
  } catch (error) {
    if (error.statusCode) return fail(res, error.statusCode, error.message);
    console.error("Delete savings goal error:", error.message || error);
    return fail(res, 500, "Unable to delete this savings target.");
  }
};

exports.createBookkeepingGoalMovement = async (req, res) => {
  try {
    const uid = userId(req);
    if (!uid) return fail(res, 401, "Please sign in to record a savings contribution or withdrawal.");
    const movement = String(req.body?.movement || "");
    const type = movement === "withdrawal" ? "savings_withdrawal" : "savings_deposit";
    if (!["contribution", "withdrawal"].includes(movement)) {
      return fail(res, 400, "Choose contribution or withdrawal.");
    }
    const description = cleanText(req.body?.description || (movement === "withdrawal" ? "Savings goal withdrawal" : "Savings goal contribution"), 120);
    const entryDate = String(req.body?.entryDate || "");
    const amountKobo = req.body?.amountKobo;
    const allocations = Array.isArray(req.body?.allocations) ? req.body.allocations : [];
    if (!validDate(entryDate) || !safeAmount(amountKobo) || allocations.length === 0 || allocations.length > 30) {
      return fail(res, 400, "Enter a valid date, amount, and at least one savings goal allocation.");
    }
    const normalized = allocations.map((item) => ({
      goalId: String(item?.goalId || ""),
      amountKobo: item?.amountKobo,
    }));
    if (normalized.some((item) => !item.goalId || !safeAmount(item.amountKobo)) ||
        normalized.reduce((sum, item) => sum + item.amountKobo, 0) !== amountKobo ||
        new Set(normalized.map((item) => item.goalId)).size !== normalized.length) {
      return fail(res, 400, "Goal allocations must be positive, unique, and add up exactly to the savings transaction amount.");
    }

    const { settingsRef, entriesRef } = userRefs(uid);
    const { goalsRef } = planningRefs(uid);
    const entryRef = entriesRef.doc();
    await db.runTransaction(async (tx) => {
      const [settingsSnap, entriesSnap, goalsSnap] = await Promise.all([
        tx.get(settingsRef), tx.get(entriesRef), tx.get(goalsRef),
      ]);
      if (!settingsSnap.exists) {
        const error = new Error("Set your opening balances before recording savings activity.");
        error.statusCode = 409;
        throw error;
      }
      const allEntries = entriesSnap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
      const goals = goalsSnap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
      const goalById = new Map(goals.map((goal) => [goal.id, goal]));
      const balances = goalBalances(goals, allEntries);
      for (const item of normalized) {
        const goal = goalById.get(item.goalId);
        if (!goal || (movement === "contribution" && goal.status !== "active")) {
          const error = new Error("One of the selected savings targets is unavailable or paused.");
          error.statusCode = 400;
          throw error;
        }
        if (movement === "withdrawal" && (balances.get(item.goalId) || 0) < item.amountKobo) {
          const error = new Error(`The withdrawal exceeds the amount saved toward ${goal.name}.`);
          error.statusCode = 400;
          throw error;
        }
      }
      const signedAllocations = normalized.map((item) => ({
        goalId: item.goalId,
        amountKobo: movement === "withdrawal" ? -item.amountKobo : item.amountKobo,
      }));
      const candidate = {
        id: entryRef.id, type, description, category: "Savings goal",
        notes: "", entryDate, amountKobo, createdAt: admin.firestore.Timestamp.now(),
        voided: false,
      };
      const validationError = validateSavingsSequence(settingsSnap.data(), [...allEntries, candidate]);
      if (validationError) {
        const error = new Error(validationError);
        error.statusCode = 400;
        throw error;
      }
      tx.create(entryRef, {
        type, description, category: "Savings goal", notes: "", entryDate, amountKobo,
        goalAllocations: signedAllocations,
        voided: false,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });
    return res.status(201).json({
      status: true,
      message: movement === "withdrawal" ? "Savings withdrawal recorded." : "Savings contribution recorded.",
      data: { id: entryRef.id },
    });
  } catch (error) {
    if (error.statusCode) return fail(res, error.statusCode, error.message);
    console.error("Savings goal movement error:", error.message || error);
    return fail(res, 500, "Unable to record this savings activity.");
  }
};
