// core/fees/fee_engine.js

class FeeEngine {
  // ============================================================
  // AIRTIME
  // ============================================================
  // No customer-facing fee.
  // ClubKonnect compensates GiftPay for these transactions.

  static airtime(amount) {
    return {
      userPays: amount,
      fee: 0
    };
  }

  // ============================================================
  // DATA
  // ============================================================
  // No customer-facing fee.
  // ClubKonnect compensates GiftPay for these transactions.

  static data(amount) {
    return {
      userPays: amount,
      fee: 0
    };
  }

  // ============================================================
  // ELECTRICITY
  // ============================================================
  // No customer-facing fee.
  // ClubKonnect compensates GiftPay for these transactions.

  static electricity(amount) {
    return {
      userPays: amount,
      fee: 0
    };
  }

  // ============================================================
  // CABLE / TV
  // ============================================================
  // No customer-facing fee.
  // ClubKonnect compensates GiftPay for these transactions.

  static cable(amount) {
    return {
      userPays: amount,
      fee: 0
    };
  }

  // ============================================================
  // BETTING
  // ============================================================
  // No customer-facing fee.
  // ClubKonnect compensates GiftPay for these transactions.

  static betting(amount) {
    return {
      userPays: amount,
      fee: 0
    };
  }

  // ============================================================
  // WITHDRAWAL
  // ============================================================
  // ₦25 flat withdrawal fee.

  static withdrawal(amount) {
    const fee = 25;

    return {
      debitAmount: amount + fee,
      fee
    };
  }

  // ============================================================
  // WALLET FUNDING
  // ============================================================
  // Bank = ₦0
  // Card = 1.5% capped at ₦200

  static walletFunding(method, amount) {
    if (method === "bank") {
      return {
        userPays: amount,
        fee: 0
      };
    }

    if (method === "card") {
      let fee = amount * 0.015;

      if (fee > 200) {
        fee = 200;
      }

      return {
        userPays: amount + fee,
        fee
      };
    }

    return {
      userPays: amount,
      fee: 0
    };
  }

  // ============================================================
  // GIFT CARD PAYOUT
  // ============================================================
  // Existing GiftPay business logic.
  // This determines the NGN payout value for a traded gift card.

  static giftCardPayout(cardType, dollarValue) {
    const rates = {
      apple: 1200,
      steam: 900,
      amazon: 850,
      google: 700,
      ps: 750,
      xbox: 700
    };

    const normalizedCardType = cardType.toLowerCase();
    const rate = rates[normalizedCardType];

    if (!rate) {
      throw new Error(`Unsupported gift card type: ${cardType}`);
    }

    const payout = dollarValue * rate;

    return {
      payout,
      rate
    };
  }

  // ============================================================
  // CASHBACK
  // ============================================================
  // No automatic cashback for ClubKonnect services.
  //
  // GiftPay receives provider compensation on these transactions,
  // so cashback should not be automatically deducted from the
  // customer's transaction unless a separate promotional campaign
  // explicitly enables it.

  static cashback(type, amount) {
    return 0;
  }
}

module.exports = FeeEngine;