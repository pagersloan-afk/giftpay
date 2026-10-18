const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");
const multer = require("multer");
const {
  getMenu, getMerchantAccess, getRestaurantSettings, updateRestaurantSettings,
  listMerchantMenu, uploadMenuImage, createMenuItem, updateMenuItem,
  placeOrder, listMyOrders, getMyOrder, listMerchantOrders,
  updateOrderStatus, confirmDelivery,
} = require("../controllers/food.controller");
const { getPublicRestaurantProfile } = require("../controllers/food.public.controller");
const router = express.Router();

const foodImageUpload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024, files: 1 },
  fileFilter: (_req, file, callback) => {
    const allowed = new Set(["image/jpeg", "image/png", "image/webp"]);
    if (!allowed.has(String(file.mimetype || "").toLowerCase())) {
      return callback(new Error("Only JPG, PNG, and WebP images are supported"));
    }
    callback(null, true);
  },
});
const parseFoodImage = (req, res, next) => {
  foodImageUpload.single("image")(req, res, (err) => {
    if (err) return res.status(400).json({ status: false, message: err.message || "Unable to accept this image" });
    next();
  });
};

// All food endpoints require a verified Firebase ID token.
router.use(authMiddleware);
router.get("/menu", getMenu);
router.get("/restaurant/profile", getPublicRestaurantProfile);
router.post("/orders", placeOrder);
router.get("/orders", listMyOrders);
router.get("/orders/:orderId", getMyOrder);
router.post("/orders/:orderId/confirm-delivery", confirmDelivery);
router.get("/merchant/access", getMerchantAccess);
router.get("/merchant/settings", getRestaurantSettings);
router.patch("/merchant/settings", updateRestaurantSettings);
router.get("/merchant/menu", listMerchantMenu);
router.post("/merchant/menu-image", parseFoodImage, uploadMenuImage);
router.get("/merchant/orders", listMerchantOrders);
router.patch("/merchant/orders/:orderId/status", updateOrderStatus);
router.post("/merchant/menu", createMenuItem);
router.patch("/merchant/menu/:itemId", updateMenuItem);
module.exports = router;
