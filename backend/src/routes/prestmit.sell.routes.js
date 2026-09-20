const express = require("express");
const multer = require("multer");

const controller = require("../controllers/prestmit.sell.controller");

const router = express.Router();

/**
 * Store uploaded gift card images in memory.
 *
 * They are forwarded directly to Prestmit.
 * We do not permanently store them in the server filesystem.
 */
const upload = multer({
  storage: multer.memoryStorage(),

  limits: {
    fileSize: 5 * 1024 * 1024,
    files: 20,
  },

  fileFilter: (req, file, callback) => {
    const allowedTypes = [
      "image/jpeg",
      "image/png",
    ];

    if (!allowedTypes.includes(file.mimetype)) {
      return callback(
        new Error(
          "Only JPG and PNG gift card images are allowed"
        )
      );
    }

    callback(null, true);
  },
});

/**
 * SELL rate/configuration.
 */
router.get(
  "/rates",
  controller.getSellRates
);

/**
 * SELL payout methods.
 */
router.get(
  "/payout-methods",
  controller.getSellPayoutMethods
);

/**
 * Gift card lookup endpoints.
 */
router.get(
  "/categories",
  controller.getSellGiftcardCategories
);

router.get(
  "/subcategories",
  controller.getSellGiftcardSubcategories
);

router.get(
  "/filters",
  controller.getSellGiftcardFilters
);

router.get(
  "/countries",
  controller.getSellGiftcardCountries
);

/**
 * Create SELL trade.
 *
 * multipart/form-data
 *
 * attachments[] = up to 20 JPG/PNG files
 */
router.post(
  "/create",
  upload.array("attachments[]", 20),
  controller.createSell
);

/**
 * Customer's GiftPay SELL history.
 */
router.get(
  "/history",
  controller.getSellHistory
);

/**
 * Requery a specific transaction.
 */
router.post(
  "/requery/:reference",
  controller.requerySell
);

/**
 * Get one transaction.
 *
 * Keep this route after the named routes above.
 */
router.get(
  "/:reference",
  controller.getSellTransaction
);

module.exports = router;