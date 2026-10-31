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
    if (method === "bank") return { userPays: amount, fee: 0 };
    if (method === "card") {
      let fee = amount * 0.015;
      if (fee > 200) fee = 200;
      return { userPays: amount + fee, fee };
    }
    return { userPays: amount, fee: 0 };
  }

  // ============================================================
  // FOOD ORDER COMMISSION
  // ============================================================
  // Commission is charged ONLY on the food subtotal. Delivery fees are
  // excluded from the commission base and are passed to the merchant.
  // One rate applies to the entire food subtotal (not progressive bands).
  static foodOrder(foodSubtotal) {
    const subtotal = Number(foodSubtotal);
    if (!Number.isFinite(subtotal) || subtotal < 0) {
      throw new Error("Food order subtotal must be a valid non-negative number");
    }

    let commissionRate;
    if (subtotal < 10000) commissionRate = 8;
    else if (subtotal < 50000) commissionRate = 6;
    else if (subtotal < 100000) commissionRate = 5;
    else if (subtotal < 200000) commissionRate = 4;
    else commissionRate = 3;

    const commissionAmount = Math.round((subtotal * commissionRate / 100 + Number.EPSILON) * 100) / 100;
    const merchantFoodEarnings = Math.round((subtotal - commissionAmount + Number.EPSILON) * 100) / 100;

    return {
      foodSubtotal: subtotal,
      commissionRate,
      commissionAmount,
      merchantFoodEarnings,
    };
  }

  // ============================================================
  // GIFT CARD BUY
  // ============================================================
  // Prestmit amount is the provider cost. GiftPay adds 3% internally.
  static giftCardBuy(providerAmount) {
    const amount = Number(providerAmount);
    if (!Number.isFinite(amount) || amount < 0) {
      throw new Error("Gift card BUY provider amount must be a valid number");
    }
    const fee = Math.round(amount * 0.03 * 100) / 100;
    const customerDebitAmount = Math.round((amount + fee) * 100) / 100;
    return { providerAmount: amount, giftPayMarkup: fee, customerDebitAmount, fee };
  }

  // ============================================================
  // GIFT CARD SELL
  // ============================================================
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
    if (!rate) throw new Error(`Unsupported gift card type: ${cardType}`);
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
