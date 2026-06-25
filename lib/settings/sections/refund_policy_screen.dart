import 'package:flutter/material.dart';

class RefundPolicyScreen extends StatelessWidget {
  const RefundPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        title: const Text("Refund Policy"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            "GiftPay Refund Policy",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 20),

          Text(
            "Last Updated: January 2026",
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),

          SizedBox(height: 30),

          // INTRODUCTION
          Text(
            "1. Introduction",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "This Refund Policy explains how refunds are handled on the GiftPay platform. "
            "By using GiftPay, you agree to the terms outlined in this policy. Refunds apply "
            "to wallet transactions, electricity vending, airtime/data purchases, gift card trades, "
            "and other supported services.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // GENERAL REFUND RULES
          Text(
            "2. General Refund Rules",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "• Refunds are issued only for failed or incomplete transactions.\n"
            "• Successful transactions are final and non‑refundable.\n"
            "• Refunds are returned to your GiftPay wallet balance.\n"
            "• Refunds do not go back to your bank account unless explicitly stated.\n"
            "• Processing time for refunds may vary depending on the service provider.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // ELECTRICITY PURCHASES
          Text(
            "3. Electricity Purchases",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "If you purchase electricity and do not receive a token:\n\n"
            "• GiftPay will automatically requery the transaction.\n"
            "• If the vending fails, your full amount (including fees) is refunded instantly.\n"
            "• If the vending succeeds later, the token will be delivered to your app.\n"
            "• Refunds are not issued for successful vending, even if delayed.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // AIRTIME & DATA
          Text(
            "4. Airtime & Data Purchases",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Airtime and data purchases are usually instant. Refunds apply only when:\n\n"
            "• The network provider fails to deliver the airtime/data.\n"
            "• The transaction is marked as failed by the provider.\n\n"
            "Refunds are processed automatically within minutes.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // GIFT CARDS
          Text(
            "5. Gift Card Transactions",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Gift card trades are final once verified. Refunds are not issued for:\n\n"
            "• Successfully verified cards.\n"
            "• Cards that have already been redeemed.\n"
            "• Invalid or tampered cards.\n\n"
            "If a card cannot be verified, it will be rejected and no deduction will occur.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // WALLET FUNDING
          Text(
            "6. Wallet Funding",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "If your wallet funding is successful but not reflected:\n\n"
            "• GiftPay will automatically verify the payment.\n"
            "• If confirmed, your wallet will be credited.\n"
            "• If the payment fails, your bank may reverse the funds within 24–72 hours.\n\n"
            "GiftPay cannot speed up bank reversals.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // TIMELINE
          Text(
            "7. Refund Timeline",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Refunds are typically processed:\n\n"
            "• Instantly for electricity, airtime, and data failures.\n"
            "• Within minutes for wallet‑based reversals.\n"
            "• Within 24–72 hours for bank‑related issues.\n\n"
            "Delays may occur due to network or provider issues.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // CONTACT
          Text(
            "8. Contact Support",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "If you believe you are eligible for a refund or have questions about a transaction, "
            "please contact us at:\n"
            "support@giftpayhq.com\n\n"
            "Include your transaction ID for faster resolution.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 50),
        ],
      ),
    );
  }
}
