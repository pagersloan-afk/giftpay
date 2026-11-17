function millis(value) {
  if (!value) return 0;
  if (typeof value.toMillis === "function") return value.toMillis();
  const parsed = new Date(value).getTime();
  return Number.isFinite(parsed) ? parsed : 0;
}

function sortEntries(entries) {
  return [...entries].sort((a, b) => {
    const dateOrder = String(a.entryDate || "").localeCompare(String(b.entryDate || ""));
    if (dateOrder !== 0) return dateOrder;
    const timeOrder = millis(a.createdAt) - millis(b.createdAt);
    if (timeOrder !== 0) return timeOrder;
    return String(a.id || "").localeCompare(String(b.id || ""));
  });
}

function calculateLedger(settings = {}, rawEntries = []) {
  const openingCashKobo = Number(settings.openingCashKobo || 0);
  const openingSavingsKobo = Number(settings.openingSavingsKobo || 0);
  let cashBalanceKobo = openingCashKobo;
  let savingsBalanceKobo = openingSavingsKobo;
  let totalIncomeKobo = 0;
  let totalExpenseKobo = 0;
  let savingsDepositsKobo = 0;
  let savingsWithdrawalsKobo = 0;
  const entries = [];

  for (const entry of sortEntries(rawEntries).filter((item) => !item.voided)) {
    const amount = Number(entry.amountKobo || 0);
    switch (entry.type) {
      case "income":
        cashBalanceKobo += amount;
        totalIncomeKobo += amount;
        break;
      case "expense":
        cashBalanceKobo -= amount;
        totalExpenseKobo += amount;
        break;
      case "savings_deposit":
        cashBalanceKobo -= amount;
        savingsBalanceKobo += amount;
        savingsDepositsKobo += amount;
        break;
      case "savings_withdrawal":
        cashBalanceKobo += amount;
        savingsBalanceKobo -= amount;
        savingsWithdrawalsKobo += amount;
        break;
      default:
        break;
    }
    entries.push({
      ...entry,
      cashBalanceAfterKobo: cashBalanceKobo,
      savingsBalanceAfterKobo: savingsBalanceKobo,
    });
  }

  return {
    entries,
    summary: {
      openingCashKobo,
      openingSavingsKobo,
      totalIncomeKobo,
      totalExpenseKobo,
      savingsDepositsKobo,
      savingsWithdrawalsKobo,
      cashBalanceKobo,
      savingsBalanceKobo,
      totalAvailableAndSavedKobo: cashBalanceKobo + savingsBalanceKobo,
      netCashMovementKobo: totalIncomeKobo - totalExpenseKobo - savingsDepositsKobo + savingsWithdrawalsKobo,
      transactionCount: entries.length,
    },
  };
}

function validateSavingsSequence(settings = {}, entries = []) {
  let savings = Number(settings.openingSavingsKobo || 0);
  for (const entry of sortEntries(entries).filter((item) => !item.voided)) {
    const amount = Number(entry.amountKobo || 0);
    if (entry.type === "savings_deposit") savings += amount;
    if (entry.type === "savings_withdrawal") {
      savings -= amount;
      if (savings < 0) {
        return `This savings withdrawal exceeds the savings available on ${entry.entryDate}.`;
      }
    }
  }
  return null;
}


function summarizeDay(settings = {}, ledgerEntries = [], date) {
  const priorEntries = ledgerEntries.filter((entry) => entry.entryDate < date);
  const dayEntries = ledgerEntries.filter((entry) => entry.entryDate === date);
  const prior = priorEntries.length ? priorEntries[priorEntries.length - 1] : null;
  const lastToday = dayEntries.length ? dayEntries[dayEntries.length - 1] : null;
  const openingCashKobo = prior
    ? Number(prior.cashBalanceAfterKobo || 0)
    : Number(settings.openingCashKobo || 0);
  const openingSavingsKobo = prior
    ? Number(prior.savingsBalanceAfterKobo || 0)
    : Number(settings.openingSavingsKobo || 0);

  let incomeKobo = 0;
  let expenseKobo = 0;
  let savingsDepositsKobo = 0;
  let savingsWithdrawalsKobo = 0;
  for (const entry of dayEntries) {
    const amount = Number(entry.amountKobo || 0);
    if (entry.type === "income") incomeKobo += amount;
    if (entry.type === "expense") expenseKobo += amount;
    if (entry.type === "savings_deposit") savingsDepositsKobo += amount;
    if (entry.type === "savings_withdrawal") savingsWithdrawalsKobo += amount;
  }

  const closingCashKobo = lastToday
    ? Number(lastToday.cashBalanceAfterKobo || 0)
    : openingCashKobo;
  const closingSavingsKobo = lastToday
    ? Number(lastToday.savingsBalanceAfterKobo || 0)
    : openingSavingsKobo;

  return {
    date,
    openingCashKobo,
    incomeKobo,
    expenseKobo,
    savingsDepositsKobo,
    savingsWithdrawalsKobo,
    totalCreditKobo: incomeKobo + savingsWithdrawalsKobo,
    totalDebitKobo: expenseKobo + savingsDepositsKobo,
    closingCashKobo,
    openingSavingsKobo,
    closingSavingsKobo,
    transactionCount: dayEntries.length,
  };
}

module.exports = { calculateLedger, validateSavingsSequence, sortEntries, summarizeDay };
