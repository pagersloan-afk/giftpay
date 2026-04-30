import express from "express";
import axios from "axios";

const router = express.Router();

// ======================================================
// STEP 1 — Initialize Payment (Wallet Funding)
// ======================================================
router.post("/initialize", async (req, res) => {
  try {
    const { email, amount } = req.body;

    if (!email || !amount) {
      return res.status(400).json({ status: false, message: "Missing fields" });
    }

    const response = await axios.post(
      "https://api.paystack.co/transaction/initialize",
      {
        email,
        amount,
        callback_url: "https://yourdomain.com/paystack-success",
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.PAYSTACK_SECRET}`,
        },
      }
    );

    return res.json({
      status: true,
      authorization_url: response.data.data.authorization_url,
      reference: response.data.data.reference,
    });
  } catch (err) {
    return res.status(500).json({
      status: false,
      message: err.message,
    });
  }
});

// ======================================================
// STEP 2 — Verify Payment (Mobile + Web)
// ======================================================
router.get("/verify/:reference", async (req, res) => {
  try {
    const { reference } = req.params;

    const response = await axios.get(
      `https://api.paystack.co/transaction/verify/${reference}`,
      {
        headers: {
          Authorization: `Bearer ${process.env.PAYSTACK_SECRET}`,
        },
      }
    );

    return res.json(response.data);
  } catch (err) {
    return res.status(500).json({
      status: false,
      message: err.message,
    });
  }
});

export default router;
