const PrestmitService = require("../services/prestmit.service");

const {
  processPrestmitPurchase,
} = require("../services/prestmit.purchase.processor");

const {
  processPrestmitSell,
} = require("../services/prestmit.sell.processor");

/**
 * Prestmit webhook handler.
 *
 * IMPORTANT:
 * server.js MUST register this endpoint with
 * express.raw() BEFORE express.json().
 *
 * BUY events:
 * - giftcard-trade.buy.approved
 * - giftcard-trade.buy.rejected
 *
 * SELL events:
 * - giftcard-trade.sell.approved
 * - giftcard-trade.sell.rejected
 */
exports.prestmitWebhook = async (req, res) => {
  try {
    const signature = req.get("x-prestmit-signature");
    const rawBody = req.body;

    /**
     * Prestmit signature verification must use
     * the original raw request body.
     */
    if (!Buffer.isBuffer(rawBody)) {
      console.error(
        "[PRESTMIT WEBHOOK] Raw request body unavailable"
      );

      return res.status(400).json({
        status: false,
        message:
          "Prestmit webhook raw body is unavailable",
      });
    }

    /**
     * Verify Prestmit webhook signature BEFORE
     * parsing or processing the payload.
     */
    const isValid =
      PrestmitService.verifyWebhookSignature(
        rawBody,
        signature
      );

    if (!isValid) {
      console.warn(
        "[PRESTMIT WEBHOOK] Invalid signature"
      );

      return res.status(401).json({
        status: false,
        message:
          "Invalid Prestmit webhook signature",
      });
    }

    /**
     * Parse the verified raw body.
     */
    let payload;

    try {
      payload = JSON.parse(
        rawBody.toString("utf8")
      );
    } catch (error) {
      console.error(
        "[PRESTMIT WEBHOOK] JSON parse error:",
        error.message
      );

      return res.status(400).json({
        status: false,
        message:
          "Invalid Prestmit webhook JSON",
      });
    }

    const event = payload?.event;

    /**
     * Prestmit's reference can appear in
     * slightly different locations depending
     * on the webhook payload.
     */
    const reference =
      payload?.data?.reference ||
      payload?.data?.transactionReference ||
      payload?.reference ||
      payload?.transactionReference;

    console.log(
      "[PRESTMIT WEBHOOK] Event:",
      event || "UNKNOWN"
    );

    console.log(
      "[PRESTMIT WEBHOOK] Reference:",
      reference || "NOT FOUND"
    );

    /**
     * =========================================================
     * BUY APPROVED
     * =========================================================
     */
    if (
      event === "giftcard-trade.buy.approved" &&
      reference
    ) {
      try {
        const result =
          await processPrestmitPurchase(
            reference
          );

        console.log(
          "[PRESTMIT WEBHOOK] BUY approved result:",
          JSON.stringify(
            {
              reference,
              status: result?.status,
              processed: result?.processed,
              alreadyProcessed:
                result?.alreadyProcessed,
            },
            null,
            2
          )
        );
      } catch (error) {
        /**
         * The webhook itself is valid.
         *
         * BUY processing can be reconciled later
         * because the existing BUY processor is
         * idempotent.
         */
        console.error(
          "[PRESTMIT WEBHOOK] BUY processing failed:",
          error.message
        );
      }
    }

    /**
     * =========================================================
     * BUY REJECTED
     * =========================================================
     */
    else if (
      event === "giftcard-trade.buy.rejected" &&
      reference
    ) {
      try {
        const result =
          await processPrestmitPurchase(
            reference
          );

        console.log(
          "[PRESTMIT WEBHOOK] BUY rejected result:",
          JSON.stringify(
            {
              reference,
              status: result?.status,
              processed: result?.processed,
              alreadyProcessed:
                result?.alreadyProcessed,
            },
            null,
            2
          )
        );
      } catch (error) {
        console.error(
          "[PRESTMIT WEBHOOK] BUY rejection processing failed:",
          error.message
        );
      }
    }

    /**
     * =========================================================
     * SELL APPROVED
     * =========================================================
     */
    else if (
      event === "giftcard-trade.sell.approved" &&
      reference
    ) {
      try {
        const result =
          await processPrestmitSell(
            reference
          );

        console.log(
          "[PRESTMIT WEBHOOK] SELL approved result:",
          JSON.stringify(
            {
              reference,
              status: result?.status,
              providerStatus:
                result?.providerStatus,
              processed: result?.processed,
              walletCredited:
                result?.walletCredited,
              alreadyProcessed:
                result?.alreadyProcessed,
              payout: result?.payout,
            },
            null,
            2
          )
        );
      } catch (error) {
        /**
         * Do not reject the provider webhook merely
         * because local processing failed.
         *
         * The SELL transaction can be recovered
         * through the requery endpoint.
         */
        console.error(
          "[PRESTMIT WEBHOOK] SELL approved processing failed:",
          error.message
        );
      }
    }

    /**
     * =========================================================
     * SELL REJECTED
     * =========================================================
     */
    else if (
      event === "giftcard-trade.sell.rejected" &&
      reference
    ) {
      try {
        const result =
          await processPrestmitSell(
            reference
          );

        console.log(
          "[PRESTMIT WEBHOOK] SELL rejected result:",
          JSON.stringify(
            {
              reference,
              status: result?.status,
              providerStatus:
                result?.providerStatus,
              rejectionReason:
                result?.rejectionReason,
              processed: result?.processed,
            },
            null,
            2
          )
        );
      } catch (error) {
        console.error(
          "[PRESTMIT WEBHOOK] SELL rejection processing failed:",
          error.message
        );
      }
    }

    /**
     * =========================================================
     * UNKNOWN / OTHER EVENT
     * =========================================================
     */
    else {
      console.log(
        "[PRESTMIT WEBHOOK] Event acknowledged:",
        event || "UNKNOWN"
      );

      if (!reference) {
        console.log(
          "[PRESTMIT WEBHOOK] No transaction reference found"
        );
      }
    }

    /**
     * Signature was already verified successfully.
     * Acknowledge the webhook.
     */
    return res.status(200).json({
      status: true,
      message: "Prestmit webhook received",
    });
  } catch (error) {
    console.error(
      "[PRESTMIT WEBHOOK] Unexpected error:",
      error.message
    );

    return res.status(500).json({
      status: false,
      message:
        "Prestmit webhook processing failed",
    });
  }
};