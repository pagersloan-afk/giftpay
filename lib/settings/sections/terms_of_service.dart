import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        title: const Text("Terms of Service"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            "GiftPay Terms of Service",
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
            "Welcome to GiftPay. By accessing or using the GiftPay mobile application, "
            "you agree to be bound by these Terms of Service. These terms govern your "
            "use of our services including wallet payments, airtime and data purchases, "
            "electricity bills, gift card trading, and all other features provided within the app.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // ELIGIBILITY
          Text(
            "2. Eligibility",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "To use GiftPay, you must be at least 18 years old and legally capable of "
            "entering into binding agreements. By using the app, you confirm that the "
            "information you provide is accurate and complete.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // ACCOUNT RESPONSIBILITY
          Text(
            "3. Account Responsibility",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "You are responsible for maintaining the confidentiality of your login details. "
            "Any activity performed through your account will be considered authorized by you. "
            "GiftPay is not liable for losses resulting from unauthorized access caused by your negligence.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // WALLET & PAYMENTS
          Text(
            "4. Wallet & Payments",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "GiftPay provides a digital wallet for transactions such as airtime, data, electricity, "
            "gift cards, and other supported services. All payments are final once processed. "
            "Refunds for failed transactions will be issued automatically or after verification.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // GIFT CARD TRADING
          Text(
            "5. Gift Card Trading",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "By trading gift cards on GiftPay, you confirm that the cards belong to you and are "
            "legally obtained. Fraudulent or invalid cards will be rejected, and your account may "
            "be suspended pending investigation.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // PROHIBITED USES
          Text(
            "6. Prohibited Uses",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "You agree not to use GiftPay for any unlawful activities including money laundering, "
            "fraud, unauthorized transactions, or any activity that violates Nigerian laws or "
            "international regulations.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // LIMITATION OF LIABILITY
          Text(
            "7. Limitation of Liability",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "GiftPay is provided on an \"as-is\" basis. While we strive to ensure smooth and secure "
            "operations, we are not liable for service interruptions, delays, or losses caused by "
            "third-party providers, network issues, or user error.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // CHANGES TO TERMS
          Text(
            "8. Changes to Terms",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "GiftPay may update these Terms of Service at any time. Continued use of the app after "
            "changes are published constitutes acceptance of the updated terms.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // CONTACT
          Text(
            "9. Contact Information",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "For questions or concerns regarding these Terms of Service, please contact us at:\n"
            "support@gifttechnologyltd.com",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 50),
        ],
      ),
    );
  }
}
