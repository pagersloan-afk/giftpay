const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const bills = require("../services/monnifyBills.service");
const clubkonnect = require("../controllers/clubkonnectBills.controller");

function useClubKonnect() {
  return String(process.env.BILL_PAYMENT_PROVIDER || "monnify").trim().toLowerCase() === "clubkonnect";
}

router.use(authMiddleware);

function asyncRoute(handler) {
  return (req, res) => {
    Promise.resolve(handler(req, res)).catch((error) => {
      console.error(
        "[MONNIFY BILLS]",
        error.response?.data || error.message || error
      );

      const status =
        error.status ||
        error.response?.status ||
        502;

      return res.status(status).json({
        status: false,
        message:
          error.response?.data?.responseMessage ||
          error.message ||
          "Monnify Bills request failed",
        provider: error.response?.data || null,
      });
    });
  };
}

// GET /api/monnify/bills/categories
router.get(
  "/categories",
  asyncRoute(async (req, res) => {
    const result = await bills.getCategories(req.query);
    return res.json(result);
  })
);

// GET /api/monnify/bills/billers?category_code=ELECTRICITY
router.get(
  "/billers",
  asyncRoute(async (req, res) => {
    const result = await bills.getBillers(req.query);
    return res.json(result);
  })
);

// GET /api/monnify/bills/products?biller_code=IKEDC
router.get(
  "/products",
  asyncRoute(async (req, res) => {
    const result = await bills.getProducts(req.query);
    return res.json(result);
  })
);

// POST /api/monnify/bills/validate-customer
router.post(
  "/validate-customer",
  asyncRoute(async (req, res) => {
    const result = await bills.validateCustomer(req.body);
    return res.json(result);
  })
);

// POST /api/monnify/bills/vend
//
// Provider call only. Wallet debit/refund handling must be
// connected before this endpoint is enabled for customer payments.
router.post(
  "/vend",
  asyncRoute(async (req, res) => {
    const result = await bills.vend(req.body);
    return res.json(result);
  })
);

// GET /api/monnify/bills/requery?reference=...
// The URL remains unchanged for the Flutter airtime processing screen.
router.get("/requery", async (req, res) => {
  const reference = req.query.reference;
  if (!reference) {
    return res.status(400).json({ status: false, message: "reference is required" });
  }
  if (useClubKonnect()) {
    return clubkonnect.requeryBills(req, res);
  }
  try {
    const result = await bills.requery(reference);
    return res.json(result);
  } catch (error) {
    console.error("[MONNIFY BILLS REQUERY]", error.response?.data || error.message || error);
    return res.status(error.status || error.response?.status || 502).json({
      status: false,
      message: error.response?.data?.responseMessage || error.message || "Monnify Bills requery failed",
      provider: error.response?.data || null,
    });
  }
});

module.exports = router;