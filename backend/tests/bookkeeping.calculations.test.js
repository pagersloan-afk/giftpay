const assert = require("node:assert/strict");
const { calculateLedger, validateSavingsSequence, summarizeDay } = require("../src/services/bookkeeping.calculations");

const settings = { openingCashKobo: 5_000_000, openingSavingsKobo: 0 };
const entries = [
  { id: "salary", type: "income", amountKobo: 10_000_000, entryDate: "2026-11-10", createdAt: new Date("2026-11-10T08:00:00Z") },
  { id: "food", type: "expense", amountKobo: 1_500_000, entryDate: "2026-11-10", createdAt: new Date("2026-11-10T09:00:00Z") },
  { id: "transport", type: "expense", amountKobo: 500_000, entryDate: "2026-11-10", createdAt: new Date("2026-11-10T10:00:00Z") },
  { id: "savings", type: "savings_deposit", amountKobo: 2_000_000, entryDate: "2026-11-10", createdAt: new Date("2026-11-10T11:00:00Z") },
];

const result = calculateLedger(settings, entries);
assert.equal(result.summary.cashBalanceKobo, 11_000_000, "cash balance should include income less expenses and savings contributions");
assert.equal(result.summary.savingsBalanceKobo, 2_000_000, "savings should be tracked separately");
assert.equal(result.summary.totalExpenseKobo, 2_000_000, "savings contributions must not count as ordinary expenses");
assert.equal(result.summary.totalIncomeKobo, 10_000_000);
assert.equal(result.summary.totalAvailableAndSavedKobo, 13_000_000);
assert.equal(result.entries.at(-1).cashBalanceAfterKobo, 11_000_000);
const dayOne = summarizeDay(settings, result.entries, "2026-11-10");
assert.equal(dayOne.openingCashKobo, 5_000_000);
assert.equal(dayOne.closingCashKobo, 11_000_000);
assert.equal(dayOne.totalCreditKobo, 10_000_000);
assert.equal(dayOne.totalDebitKobo, 4_000_000);
assert.equal(dayOne.closingSavingsKobo, 2_000_000);

const withWithdrawal = [...entries, {
  id: "withdrawal", type: "savings_withdrawal", amountKobo: 500_000,
  entryDate: "2026-11-11", createdAt: new Date("2026-11-11T08:00:00Z"),
}];
const withdrawalResult = calculateLedger(settings, withWithdrawal);
assert.equal(withdrawalResult.summary.cashBalanceKobo, 11_500_000);
assert.equal(withdrawalResult.summary.savingsBalanceKobo, 1_500_000);
const dayTwo = summarizeDay(settings, withdrawalResult.entries, "2026-11-11");
assert.equal(dayTwo.openingCashKobo, 11_000_000);
assert.equal(dayTwo.closingCashKobo, 11_500_000);
assert.equal(dayTwo.openingSavingsKobo, 2_000_000);
assert.equal(dayTwo.closingSavingsKobo, 1_500_000);
assert.equal(validateSavingsSequence(settings, withWithdrawal), null);
assert.match(
  validateSavingsSequence(settings, [{ id: "bad", type: "savings_withdrawal", amountKobo: 1, entryDate: "2026-11-10", createdAt: new Date() }]),
  /exceeds the savings available/,
);

const voided = calculateLedger(settings, [...entries, {
  id: "voided", type: "income", amountKobo: 99_000_000,
  entryDate: "2026-11-12", voided: true,
}]);
assert.equal(voided.summary.cashBalanceKobo, 11_000_000, "voided entries must not affect balances");

console.log("Bookkeeping calculation tests passed.");
