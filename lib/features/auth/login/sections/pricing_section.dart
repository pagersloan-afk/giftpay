import 'dart:ui';

import 'package:flutter/material.dart';

class PricingSection extends StatelessWidget {
  const PricingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pricing",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "GiftPay is built on clear, simple, and predictable pricing. No hidden fees. "
                  "Every transaction shows its cost upfront before you pay.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                Wrap(
                  spacing: 30,
                  runSpacing: 30,
                  children: [
                    _pricingCard(
                      title: "Electricity Tokens",
                      items: [
                        "Instant token delivery",
                        "Service fee: ₦10–₦25",
                        "Minimum purchase: ₦100",
                      ],
                    ),
                    _pricingCard(
                      title: "Airtime & Data",
                      items: [
                        "Network rate (no markup)",
                        "Processing fee: ₦0–₦10",
                        "Instant delivery",
                      ],
                    ),
                    _pricingCard(
                      title: "Wallet Funding",
                      items: [
                        "Bank transfer: Free",
                        "Card payments: Gateway fees apply",
                        "Instant wallet credit",
                      ],
                    ),
                    _pricingCard(
                      title: "Gift Cards",
                      items: [
                        "Starting from ₦7,000",
                        "Processing fee: ₦0–₦20",
                        "Instant digital delivery",
                      ],
                    ),
                    _pricingCard(
                      title: "Transfers",
                      items: [
                        "Send to any Nigerian bank",
                        "Fee: ₦10–₦25",
                        "Instant settlement",
                      ],
                    ),
                    _pricingCard(
                      title: "Business Solutions",
                      items: [
                        "Bulk utilities automation",
                        "Custom pricing available",
                        "Dedicated business support",
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pricingCard({required String title, required List<String> items}) {
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
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "• $item",
                style: const TextStyle(
                  fontSize: 16,
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
