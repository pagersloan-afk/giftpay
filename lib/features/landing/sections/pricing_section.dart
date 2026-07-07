import 'package:flutter/material.dart';

class PricingSection extends StatelessWidget {
  const PricingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 24 : 40,
        ),
        color: const Color(0xFFF9F9F9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pricing",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 22 : 28,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "GiftPay is built on clear, simple, and predictable pricing. No hidden fees. Every transaction shows its cost upfront before you pay.",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isMobile ? 13 : 15,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                _pricingCard("Electricity Tokens", [
                  "Instant token delivery",
                  "Service fee: ₦10–₦25",
                  "Minimum purchase: ₦100",
                ], isMobile),
                _pricingCard("Airtime & Data", [
                  "Network rate (no markup)",
                  "Processing fee: ₦0–₦10",
                  "Instant delivery",
                ], isMobile),
                _pricingCard("Wallet Funding", [
                  "Bank transfer: Free",
                  "Card payments: Gateway fees apply",
                  "Instant wallet credit",
                ], isMobile),
                _pricingCard("Gift Cards", [
                  "Starting from ₦7,000",
                  "Processing fee: ₦0–₦20",
                  "Instant digital delivery",
                ], isMobile),
                _pricingCard("Transfers", [
                  "Send to any Nigerian bank",
                  "Fee: ₦10–₦25",
                  "Instant settlement",
                ], isMobile),
                _pricingCard("Business Solutions", [
                  "Bulk utilities automation",
                  "Custom pricing available",
                  "Dedicated business support",
                ], isMobile),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pricingCard(String title, List<String> items, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 16 : 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "• $item",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 13 : 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
