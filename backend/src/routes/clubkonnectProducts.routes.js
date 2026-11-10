const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");
const controller = require("../controllers/clubkonnectProducts.controller");
const router = express.Router();

router.use(authMiddleware);
router.get("/catalog", controller.catalog);
router.get("/data-pin-plans/:network", controller.dataPinPlans);
router.post("/verify-smile", controller.verifySmile);
router.post("/verify-jamb", controller.verifyJamb);
router.post("/purchase", controller.purchase);
router.get("/requery/:reference", controller.requery);

module.exports = router;
