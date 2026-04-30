// core/fees/fee_engine.js

class FeeEngine {
  // Airtime: 1% markup (Opay-level)
  static airtime(amount) {
    const markup = amount * 0.01;
    return {
      userPays: amount + markup,
      fee: markup
    };
  }

  // Data: 2% markup (Opay-level)
  static data(amount) {
    const markup = amount * 0.02;
    return {
      userPays: amount + markup,
      fee: markup
    };
  }

  // Electricity: ₦15 flat (Opay-level)
  static electricity(amount) {
    const fee = 15;
    return {
      userPays: amount + fee,
      fee
    };
  }

  // Cable: ₦20 flat (Opay-level)
  static cable(amount) {
    const fee = 20;
    return {
      userPays: amount + fee,
      fee
    };
  }

  // Betting: ₦10 flat (Opay-level)
  static betting(amount) {
    const fee = 10;
    return {
      userPays: amount + fee,
      fee
    };
  }

  // Withdrawal: ₦25 flat (Opay-level)
  static withdrawal(amount) {
    const fee = 25;
    return {
      debitAmount: amount + fee,
      fee
    };
  }

  // Wallet funding:
  // Bank = ₦0
  // Card = 1.5% capped at ₦200 (Opay-level)
  static walletFunding(method, amount) {
    if (method === "bank") {
      return { userPays: amount, fee: 0 };
    }

    if (method === "card") {
      let fee = amount * 0.015;
      if (fee > 200) fee = 200; // cap at ₦200
      return { userPays: amount + fee, fee };
    }
  }

  // Gift card payout (unchanged — your business logic)
  static giftCardPayout(cardType, dollarValue) {
    const rates = {
      apple: 1200,
      steam: 900,
      amazon: 850,
      google: 700,
      ps: 750,
      xbox: 700
    };

    const rate = rates[cardType.toLowerCase()];
    const payout = dollarValue * rate;

    return {
      payout,
      rate
    };
  }

  // Cashback (Opay-style)
  static cashback(type, amount) {
    const rules = {
      airtime: 0.01,      // 1%
      data: 0.02,         // 2%
      electricity: 5,     // ₦5
      cable: 10           // ₦10
    };

    const rule = rules[type];

    if (typeof rule === "number") {
      return rule; // flat cashback
    }

    return amount * rule; // percentage cashback
  }
}

module.exports = FeeEngine;
