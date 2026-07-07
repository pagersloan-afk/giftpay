import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';
import 'package:utilityhub/core/widgets/app_header.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftPayBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppHeader(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Contact GiftPay",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "We’re here to help. Reach out to our support or business team anytime.",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                Wrap(
                  spacing: 40,
                  runSpacing: 40,
                  children: [
                    _contactCard(
                      title: "Support",
                      lines: [
                        "support@giftpay.com.ng",
                        "24/7 customer support",
                      ],
                    ),
                    _contactCard(
                      title: "Business & Partnerships",
                      lines: ["business@giftpay.com.ng", "Mon–Fri, 9am–5pm"],
                    ),
                    _contactCard(title: "Phone", lines: ["+234 810 000 0000"]),
                    _contactCard(
                      title: "Office Address",
                      lines: [
                        "Gift Technology Ltd",
                        "6th Avenue, SARS Road",
                        "Rukpoku, Port Harcourt",
                        "Rivers State, Nigeria",
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Get Support",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _contactCard({required String title, required List<String> lines}) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                line,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
