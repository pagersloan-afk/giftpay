import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            "GiftPay Privacy Policy",
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
            "This Privacy Policy explains how GiftPay collects, uses, stores, and protects your "
            "personal information when you use our mobile application and services. By using GiftPay, "
            "you consent to the practices described in this policy.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // INFORMATION WE COLLECT
          Text(
            "2. Information We Collect",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "We may collect the following types of information:\n\n"
            "• Personal Information: Name, email address, phone number, date of birth.\n"
            "• Account Information: Login credentials, authentication details.\n"
            "• Transaction Data: Wallet activity, payments, purchases, gift card trades.\n"
            "• Device Information: IP address, device model, OS version, app usage data.\n"
            "• Location Data: For fraud prevention and regulatory compliance.\n"
            "• Support Interactions: Messages, emails, and chat history with our support team.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // HOW WE USE INFORMATION
          Text(
            "3. How We Use Your Information",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "GiftPay uses your information to:\n\n"
            "• Provide and improve our services.\n"
            "• Process payments, transactions, and wallet operations.\n"
            "• Verify your identity and prevent fraud.\n"
            "• Communicate updates, alerts, and support responses.\n"
            "• Comply with legal and regulatory requirements.\n"
            "• Personalize your app experience.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // SHARING INFORMATION
          Text(
            "4. How We Share Your Information",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "We do not sell your personal information. However, we may share data with:\n\n"
            "• Payment processors and financial partners.\n"
            "• Identity verification and fraud prevention services.\n"
            "• Regulatory authorities when required by law.\n"
            "• Service providers who help us operate the app.\n\n"
            "All partners are required to protect your data and use it only for authorized purposes.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // DATA SECURITY
          Text(
            "5. Data Security",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "We implement industry‑standard security measures including encryption, secure servers, "
            "multi‑factor authentication, and continuous monitoring to protect your information. "
            "While we strive to safeguard your data, no system is completely immune to risks.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // YOUR RIGHTS
          Text(
            "6. Your Rights",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Depending on your location, you may have the right to:\n\n"
            "• Access the personal data we hold about you.\n"
            "• Request corrections to inaccurate information.\n"
            "• Request deletion of your data (subject to legal requirements).\n"
            "• Opt out of marketing communications.\n"
            "• Withdraw consent for data processing.\n\n"
            "To exercise these rights, contact us at support@giftpayhq.com.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // DATA RETENTION
          Text(
            "7. Data Retention",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "We retain your information only as long as necessary to provide our services, comply with "
            "legal obligations, resolve disputes, and enforce our agreements.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // CHANGES TO POLICY
          Text(
            "8. Changes to This Privacy Policy",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "We may update this Privacy Policy periodically. Continued use of GiftPay after updates "
            "indicates acceptance of the revised policy.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // CONTACT
          Text(
            "9. Contact Us",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "If you have questions or concerns about this Privacy Policy, please contact us at:\n"
            "support@giftpayhq.com",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 50),
        ],
      ),
    );
  }
}
