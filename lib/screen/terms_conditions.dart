import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';
import 'package:utilityhub/core/widgets/app_header.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftPayBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppHeader(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Terms & Conditions",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 24),

                      Text(
                        "These Terms & Conditions govern your use of GiftPay, a digital payments platform operated by Gift Technology Ltd (RC 9607125). "
                        "By accessing or using GiftPay, you agree to these terms.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 32),

                      _sectionTitle("1. Eligibility"),
                      _sectionBody(
                        "You must be at least 18 years old and legally capable of entering into binding agreements to use GiftPay.",
                      ),

                      _sectionTitle("2. Account Responsibility"),
                      _sectionBody(
                        "You are responsible for maintaining the confidentiality of your login credentials and all activities under your account.",
                      ),

                      _sectionTitle("3. Prohibited Activities"),
                      _sectionBody(
                        "You may not use GiftPay for fraudulent transactions, unauthorized access, money laundering, or any illegal activity.",
                      ),

                      _sectionTitle("4. Service Availability"),
                      _sectionBody(
                        "GiftPay may experience occasional downtime due to maintenance or third‑party service interruptions. We do not guarantee uninterrupted access.",
                      ),

                      _sectionTitle("5. Limitation of Liability"),
                      _sectionBody(
                        "GiftPay is not liable for losses resulting from user negligence, third‑party failures, or unauthorized access caused by compromised credentials.",
                      ),

                      _sectionTitle("6. Updates to Terms"),
                      _sectionBody(
                        "We may update these Terms & Conditions at any time. Continued use of GiftPay constitutes acceptance of updated terms.",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _sectionTitle extends StatelessWidget {
  final String text;
  const _sectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _sectionBody extends StatelessWidget {
  final String text;
  const _sectionBody(this.text);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
