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
 * server.js MUST register this endpoint with express.raw()
 * before express.json().
 *
 * BUY:
 * - giftcard-trade.buy.approved
 * - giftcard-trade.buy.rejected
 *
 * SELL:
 * - giftcard-trade.sell.approved
 * - giftcard-trade.sell.rejected
 */
exports.prestmitWebhook = async (req, res) => {
  try {
    const signature =
      req.get("x-prestmit-signature");

    const rawBody = req.body;

    /**
     * Prestmit requires verification against the raw
     * request body.
     */
    if (!Buffer.isBuffer(rawBody)) {
      console.error(
        "Prestmit webhook error: raw request body unavailable"
      );

      return res.status(400).json({
        status: false,
        message:
          "Prestmit webhook raw body is unavailable",
      });
    }

    const isValid =
      PrestmitService.verifyWebhookSignature(
        rawBody,
        signature
      );

    if (!isValid) {
      console.warn(
        "Prestmit webhook rejected: invalid signature"
      );

      return res.status(401).json({
        status: false,
        message:
          "Invalid Prestmit webhook signature",
      });
    }

    let payload;

    try {
      payload = JSON.parse(
        rawBody.toString("utf8")
      );
    } catch (error) {
      console.error(
        "Prestmit webhook JSON parse error:",
        error.message
      );

      return res.status(400).json({
        status: false,
        message:
          "Invalid Prestmit webhook JSON",
      });
    }

    const event =
      payload?.event;

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
      event ===
        "giftcard-trade.buy.approved" &&
      reference
    ) {
      try {
        const result =
          await processPrestmitPurchase(
            reference
          );

        console.log(
          "[PRESTMIT WEBHOOK] Purchase processor result:",
          JSON.stringify(
            {
              reference,
              status: result?.status,
              processed:
                result?.processed,
              alreadyProcessed:
                result?.alreadyProcessed,
            },
            null,
            2
          )
        );
      } catch (error) {
        /**
         * Keep returning 200 after a verified webhook.
         *
         * The BUY processor is idempotent and can be
         * reconciled later.
         */
        console.error(
          "[PRESTMIT WEBHOOK] Purchase processing failed:",
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
      event ===
        "giftcard-trade.buy.rejected"
    ) {
      if (reference) {
        try {
          await processPrestmitPurchase(
            reference
          );
        } catch (error) {
          console.error(
            "[PRESTMIT WEBHOOK] Rejected purchase update failed:",
            error.message
          );
        }
      }
    }

    /**
     * =========================================================
     * SELL APPROVED
     * =========================================================
     */
    else if (
      event ===
        "giftcard-trade.sell.approved" &&
      reference
    ) {
      try {
        const result =
          await processPrestmitSell(
            reference
          );

        console.log(
          "[PRESTMIT WEBHOOK] SELL processor result:",
          JSON.stringify(
            {
              reference,
              status:
                result?.status,
              providerStatus:
                result?.providerStatus,
              processed:
                result?.processed,
              walletCredited:
                result?.walletCredited,
              alreadyProcessed:
                result?.alreadyProcessed,
              payout:
                result?.payout,
            },
            null,
            2
          )
        );
      } catch (error) {
        /**
         * The webhook was authenticated successfully,
         * but processing failed.
         *
         * We still acknowledge the provider request.
         * The transaction can be recovered through
         * /requery/:reference.
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
      event ===
        "giftcard-trade.sell.rejected" &&
      reference
    ) {
      try {
        const result =
          await processPrestmitSell(
            reference
          );

        console.log(
          "[PRESTMIT WEBHOOK] SELL rejection processor result:",
          JSON.stringify(
            {
              reference,
              status:
                result?.status,
              providerStatus:
                result?.providerStatus,
                rejectionReason:
                  result?.rejectionReason,
              processed:
                result?.processed,
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
     * UNKNOWN / OTHER PRESTMIT EVENT
     * =========================================================
     */
    else {
      console.log(
        "[PRESTMIT WEBHOOK] Event acknowledged:",
        event || "UNKNOWN"
      );
    }

    /**
     * The signature has already been verified.
     */
    return res.status(200).json({
      status: true,
      message:
        "Prestmit webhook received",
    });
  } catch (error) {
    console.error(
      "Prestmit webhook error:",
      error.message
    );

    return res.status(500).json({
      status: false,
      message:
        "Prestmit webhook processing failed",
    });
  }
};