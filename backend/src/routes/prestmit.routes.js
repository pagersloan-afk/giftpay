const express = require("express");

const {
  getCatalog,
  getConfiguration,
  checkAvailability,
  calculatePayment,
  createBuyTransaction,
  requeryPurchase,
  fetchGiftCardCodes,
  getBuyHistory,
  reconcileExistingPurchase,
} = require("../controllers/prestmit.controller");

const router = express.Router();

router.get("/test", (req, res) => {
  return res.json({
    status: true,
    message: "Prestmit route is working",
  });
});

router.get("/catalog", getCatalog);

router.get("/configuration", getConfiguration);

router.post(
  "/check-availability",
  checkAvailability
);

router.post(
  "/calculate-payment",
  calculatePayment
);

router.post(
  "/buy",
  createBuyTransaction
);

// Customer-facing status refresh.
// Flutter polls this while the Prestmit transaction is pending.
router.post(
  "/requery/:reference",
  requeryPurchase
);

router.get(
  "/history",
  getBuyHistory
);

router.get(
  "/codes/:reference",
  fetchGiftCardCodes
);

// Sandbox-only reconciliation helper.
router.post(
  "/reconcile/:reference",
  reconcileExistingPurchase
);

module.exports = router;
