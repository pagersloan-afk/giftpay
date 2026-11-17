const express = require("express");
const router = express.Router();
const controller = require("../controllers/bookkeeping.controller");

router.get("/", controller.getBookkeepingDashboard);
router.get("/entries", controller.getBookkeepingEntries);
router.get("/reports", controller.getBookkeepingReport);
router.get("/planning", controller.getBookkeepingPlanning);
router.put("/opening-balances", controller.setOpeningBalances);
router.post("/reset", controller.resetBookkeeping);
router.post("/entries", controller.createBookkeepingEntry);
router.patch("/entries/:id", controller.updateBookkeepingEntry);
router.delete("/entries/:id", controller.voidBookkeepingEntry);

router.post("/budgets", controller.createBookkeepingBudget);
router.patch("/budgets/:id", controller.updateBookkeepingBudget);
router.delete("/budgets/:id", controller.deleteBookkeepingBudget);

router.post("/savings/goals", controller.createBookkeepingSavingsGoal);
router.patch("/savings/goals/:id", controller.updateBookkeepingSavingsGoal);
router.delete("/savings/goals/:id", controller.deleteBookkeepingSavingsGoal);
router.post("/savings/goal-movements", controller.createBookkeepingGoalMovement);

module.exports = router;
