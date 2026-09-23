// core/fees/fee_engine.js

class FeeEngine {
  // ============================================================
  // AIRTIME
  // ============================================================
  // No customer-facing fee.
  // ClubKonnect compensates GiftPay for these transactions.

  static airtime(amount) {
    return { userPays: amount, fee: 0 };
  }

  // ============================================================
  // DATA
  // ============================================================
  static data(amount) {
    return { userPays: amount, fee: 0 };
  }

  // ============================================================
  // ELECTRICITY
  // ============================================================
  static electricity(amount) {
    return { userPays: amount, fee: 0 };
  }

  // ============================================================
  // CABLE / TV
  // ============================================================
  static cable(amount) {
    return { userPays: amount, fee: 0 };
  }

  // ============================================================
  // BETTING
  // ============================================================
  static betting(amount) {
    return { userPays: amount, fee: 0 };
  }

  // ============================================================
  // WITHDRAWAL
  // ============================================================
  static withdrawal(amount) {
    const fee = 25;
    return { debitAmount: amount + fee, fee };
  }

  // ============================================================
  // WALLET FUNDING
  // ============================================================
  static walletFunding(method, amount) {
    if (method === "bank") {
      return { userPays: amount, fee: 0 };
    }

    if (method === "card") {
      let fee = amount * 0.015;
      if (fee > 200) fee = 200;
      return { userPays: amount + fee, fee };
    }

    return { userPays: amount, fee: 0 };
  }

  // ============================================================
  // GIFT CARD BUY
  // ============================================================
  // Prestmit amount is the provider cost. GiftPay adds 3% internally.
  // The customer sees only the final customerDebitAmount.
  static giftCardBuy(providerAmount) {
    const amount = Number(providerAmount);

    if (!Number.isFinite(amount) || amount < 0) {
      throw new Error("Gift card BUY provider amount must be a valid number");
    }

    const fee = Math.round(amount * 0.03 * 100) / 100;
    const customerDebitAmount = Math.round((amount + fee) * 100) / 100;

    return {
      providerAmount: amount,
      giftPayMarkup: fee,
      customerDebitAmount,
      fee,
    };
  }

  // ============================================================
  // GIFT CARD SELL
  // ============================================================
  // Prestmit payout is the provider amount. GiftPay retains 5%.
  // The customer sees only the final customerPayout.
  static giftCardSellRate(providerRate, marginPercent = 5) {
    const rate = Number(providerRate);
    const margin = Number(marginPercent);

    if (!Number.isFinite(rate) || rate < 0) {
      throw new Error("Gift card SELL provider rate must be a valid number");
    }

    if (!Number.isFinite(margin) || margin < 0 || margin >= 100) {
      throw new Error("Gift card SELL margin percent must be between 0 and 100");
    }

    const customerRate = Math.round(rate * (1 - margin / 100) * 100) / 100;

    return { providerRate: rate, customerRate, marginPercent: margin };
  }

  static giftCardSell(providerPayout, marginPercent = 5) {
    const amount = Number(providerPayout);
    const margin = Number(marginPercent);

    if (!Number.isFinite(amount) || amount < 0) {
      throw new Error("Gift card SELL provider payout must be a valid number");
    }

    if (!Number.isFinite(margin) || margin < 0 || margin >= 100) {
      throw new Error("Gift card SELL margin percent must be between 0 and 100");
    }

    const fee = Math.round(amount * (margin / 100) * 100) / 100;
    const customerPayout = Math.round((amount - fee) * 100) / 100;

    return { providerPayout: amount, giftPayMargin: fee, customerPayout, fee };
  }

  // ============================================================
  // EXISTING GIFT CARD PAYOUT
  // ============================================================
  // Existing GiftPay business logic.
  static giftCardPayout(cardType, dollarValue) {
    const rates = {
      apple: 1200,
      steam: 900,
      amazon: 850,
      google: 700,
      ps: 750,
      xbox: 700,
    };

    const normalizedCardType = cardType.toLowerCase();
    const rate = rates[normalizedCardType];

    if (!rate) {
      throw new Error(`Unsupported gift card type: ${cardType}`);
    }

    const payout = dollarValue * rate;
    return { payout, rate };
  }

  // ============================================================
  // CASHBACK
  // ============================================================
  static cashback(type, amount) {
    return 0;
  }
}

module.exports = FeeEngine;
