import 'package:flutter/material.dart';

class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        title: const Text("User Agreement"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            "GiftPay User Agreement",
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
            "This User Agreement outlines the terms governing your use of the GiftPay mobile "
            "application and services. By creating an account or using GiftPay, you agree to "
            "comply with this Agreement, our Terms of Service, Privacy Policy, and Refund Policy.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // ACCOUNT CREATION
          Text(
            "2. Account Creation & Verification",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "To use GiftPay, you must create an account and provide accurate information. "
            "You agree to complete any required identity verification (KYC) steps. Failure to "
            "provide accurate information may result in account suspension or termination.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // USER RESPONSIBILITIES
          Text(
            "3. User Responsibilities",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "You agree to:\n\n"
            "• Use GiftPay only for lawful purposes.\n"
            "• Keep your login credentials secure.\n"
            "• Notify us immediately of unauthorized account access.\n"
            "• Provide accurate information during transactions.\n"
            "• Comply with all applicable laws and regulations.\n\n"
            "You are responsible for all activity performed through your account.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // PROHIBITED ACTIVITIES
          Text(
            "4. Prohibited Activities",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "You agree not to engage in:\n\n"
            "• Fraudulent transactions.\n"
            "• Money laundering or illegal financial activity.\n"
            "• Trading stolen or unauthorized gift cards.\n"
            "• Attempting to bypass security systems.\n"
            "• Using GiftPay for harmful or abusive behavior.\n\n"
            "Violation of these rules may result in account suspension or legal action.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // SERVICE AVAILABILITY
          Text(
            "5. Service Availability & Limitations",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "GiftPay strives to provide uninterrupted service, but we do not guarantee "
            "continuous availability. Services may be affected by maintenance, network issues, "
            "third‑party providers, or regulatory requirements.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // ACCOUNT SUSPENSION
          Text(
            "6. Account Suspension & Termination",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "GiftPay may suspend or terminate your account if:\n\n"
            "• You violate this Agreement or any GiftPay policy.\n"
            "• Fraudulent or suspicious activity is detected.\n"
            "• Required KYC/AML information is not provided.\n"
            "• You misuse the platform or engage in illegal activity.\n\n"
            "You may also request account closure at any time.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // LIABILITY
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
            "GiftPay is not liable for losses resulting from:\n\n"
            "• Unauthorized access caused by your negligence.\n"
            "• Network or provider outages.\n"
            "• Incorrect information provided by you.\n"
            "• Third‑party service failures.\n\n"
            "Your use of GiftPay is at your own risk.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // CHANGES
          Text(
            "8. Changes to This Agreement",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "GiftPay may update this User Agreement at any time. Continued use of the app "
            "after updates indicates acceptance of the revised terms.",
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
            "If you have questions about this User Agreement, please contact us at:\n"
            "support@giftpayhq.com",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 50),
        ],
      ),
    );
  }
}
