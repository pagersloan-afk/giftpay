import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';
import 'package:utilityhub/core/widgets/app_header.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftPayBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppHeader(), // ⭐ AppHeader now included
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ⭐ PAGE TITLE
                const Text(
                  "About GiftPay",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 20),

                // ⭐ SUBTITLE WITH RC NUMBER
                const Text(
                  "Built by Gift Technology Ltd — RC 9607125",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),

                // ⭐ MAIN GLASS CARD
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          // ⭐ INTRO
                          Text(
                            "Who We Are",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),

                          Text(
                            "GiftPay is a modern digital payments platform created by Gift Technology Ltd, a Nigerian‑registered technology company focused on delivering fast, secure, and globally scalable financial services. We help individuals and businesses access essential utilities — electricity, airtime, data, wallet funding, and digital services — through a seamless, reliable experience.",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 32),

                          // ⭐ MISSION
                          Text(
                            "Our Mission",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),

                          Text(
                            "To empower millions of users with instant, secure, and transparent digital payments, while building a financial ecosystem that supports everyday life, business operations, and long‑term digital growth.",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 32),

                          // ⭐ VISION
                          Text(
                            "Our Vision",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),

                          Text(
                            "To become Africa’s most trusted digital utility and payments platform — connecting people, businesses, and essential services through technology that is simple, fast, and globally scalable.",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ⭐ CORE VALUES SECTION
                const Text(
                  "Our Core Values",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                Wrap(
                  spacing: 30,
                  runSpacing: 30,
                  children: [
                    _valueCard(
                      title: "Security",
                      subtitle:
                          "Every transaction is encrypted and protected with industry‑grade security.",
                    ),
                    _valueCard(
                      title: "Speed",
                      subtitle:
                          "Instant processing for electricity tokens, airtime, data, and wallet funding.",
                    ),
                    _valueCard(
                      title: "Transparency",
                      subtitle:
                          "Clear pricing, real‑time notifications, and no hidden charges.",
                    ),
                    _valueCard(
                      title: "Support",
                      subtitle:
                          "24/7 assistance for individuals and businesses across Nigeria.",
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // ⭐ COMPANY FOOTER BADGE
                Center(
                  child: Text(
                    "Gift Technology Ltd — RC 9607125 — Registered in Nigeria",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.65),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ⭐ VALUE CARD WIDGET
  Widget _valueCard({required String title, required String subtitle}) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
