import 'package:flutter/material.dart';

class CookiePolicyScreen extends StatelessWidget {
  const CookiePolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        title: const Text("Cookie Policy"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            "GiftPay Cookie Policy",
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
            "This Cookie Policy explains how GiftPay uses cookies and similar technologies "
            "to enhance your experience when using our mobile application. By using GiftPay, "
            "you consent to the use of cookies as described in this policy.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // WHAT COOKIES ARE
          Text(
            "2. What Are Cookies?",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Cookies are small text files stored on your device to help apps and websites "
            "remember information about your visit. Cookies improve functionality, security, "
            "and personalization.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // TYPES OF COOKIES
          Text(
            "3. Types of Cookies We Use",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "GiftPay uses the following types of cookies:\n\n"
            "• **Essential Cookies** – Required for the app to function properly.\n"
            "• **Security Cookies** – Used to detect fraud, protect your account, and ensure safe usage.\n"
            "• **Performance Cookies** – Help us understand app performance and fix issues.\n"
            "• **Analytics Cookies** – Provide insights into how users interact with GiftPay.\n"
            "• **Preference Cookies** – Remember your settings such as theme, language, and preferences.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // WHY WE USE COOKIES
          Text(
            "4. Why We Use Cookies",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "We use cookies to:\n\n"
            "• Keep your account secure.\n"
            "• Improve app performance and reliability.\n"
            "• Personalize your experience.\n"
            "• Analyze usage patterns to enhance features.\n"
            "• Remember your preferences and settings.\n"
            "• Provide faster and smoother navigation.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // THIRD PARTY COOKIES
          Text(
            "5. Third‑Party Cookies",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "GiftPay may use trusted third‑party services such as analytics providers, "
            "payment processors, and fraud‑prevention tools. These partners may place "
            "their own cookies to support their services. All partners are required to "
            "protect your data and comply with privacy regulations.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // MANAGING COOKIES
          Text(
            "6. Managing Cookies",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "You can manage or disable cookies through your device settings. However, "
            "disabling essential cookies may affect the functionality of GiftPay and "
            "prevent certain features from working correctly.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // CHANGES TO POLICY
          Text(
            "7. Changes to This Cookie Policy",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "We may update this Cookie Policy from time to time. Continued use of GiftPay "
            "after updates indicates acceptance of the revised policy.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 30),

          // CONTACT
          Text(
            "8. Contact Us",
            style: TextStyle(
              color: Color(0xFF0AC8FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "If you have questions about this Cookie Policy, please contact us at:\n"
            "support@giftpayhq.com",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          SizedBox(height: 50),
        ],
      ),
    );
  }
}
