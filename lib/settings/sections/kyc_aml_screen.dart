import 'package:flutter/material.dart';

class KycAmlScreen extends StatelessWidget {
  const KycAmlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        title: const Text("KYC / AML Compliance"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            "GiftPay KYC / AML Compliance Statement",
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
            "GiftPay is committed to complying with all applicable Know Your Customer (KYC) "
            "and Anti‑Money Laundering (AML) regulations. These measures help protect our users, "
            "prevent fraud, and ensure the integrity of financial transactions conducted on our platform.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // REGULATORY FRAMEWORK
          Text(
            "2. Regulatory Framework",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "GiftPay adheres to the following regulations and guidelines:\n\n"
            "• Central Bank of Nigeria (CBN) KYC/AML Regulations.\n"
            "• Nigeria Financial Intelligence Unit (NFIU) guidelines.\n"
            "• NDPR (Nigeria Data Protection Regulation).\n"
            "• FATF (Financial Action Task Force) global AML standards.\n\n"
            "These frameworks guide how we verify users and monitor transactions.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // KYC REQUIREMENTS
          Text(
            "3. KYC Verification Requirements",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "To comply with regulatory requirements, GiftPay may request the following information:\n\n"
            "• Full name.\n"
            "• Date of birth.\n"
            "• Phone number and email address.\n"
            "• Government‑issued ID (NIN, BVN, Driver’s License, Voter’s Card, etc.).\n"
            "• Selfie or biometric verification.\n"
            "• Residential address.\n\n"
            "This information is used solely for identity verification and fraud prevention.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // AML MONITORING
          Text(
            "4. Anti‑Money Laundering (AML) Monitoring",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "GiftPay actively monitors transactions to detect and prevent:\n\n"
            "• Money laundering.\n"
            "• Terrorist financing.\n"
            "• Fraudulent activities.\n"
            "• Suspicious or unusual transaction patterns.\n\n"
            "We may temporarily restrict or review accounts involved in suspicious activity.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // REPORTING OBLIGATIONS
          Text(
            "5. Reporting Obligations",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "GiftPay may report suspicious transactions to the Nigeria Financial Intelligence Unit (NFIU) "
            "or other regulatory authorities as required by law. These reports are confidential and "
            "do not require user notification.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // DATA PROTECTION
          Text(
            "6. Data Protection & Privacy",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "All KYC and AML data collected by GiftPay is securely stored and protected in accordance "
            "with NDPR and global data protection standards. We do not sell or misuse your personal data.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // USER RESPONSIBILITIES
          Text(
            "7. User Responsibilities",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Users agree to:\n\n"
            "• Provide accurate and truthful information.\n"
            "• Update their details when changes occur.\n"
            "• Avoid fraudulent or illegal transactions.\n"
            "• Cooperate with verification requests.\n\n"
            "Failure to comply may result in account restrictions or closure.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // CHANGES
          Text(
            "8. Changes to This Compliance Statement",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "GiftPay may update this KYC/AML Compliance Statement at any time. Continued use of the "
            "platform after updates indicates acceptance of the revised terms.",
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
            "For questions regarding KYC or AML compliance, please contact us at:\n"
            "support@giftpayhq.com",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 50),
        ],
      ),
    );
  }
}
