import 'package:flutter/material.dart';

class LifestyleBenefitsSection extends StatelessWidget {
  const LifestyleBenefitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: Wrap(
        spacing: 30,
        runSpacing: 30,
        children: [
          _benefit(
            "GiftPay Rewards",
            "Earn cashback on every utility purchase.",
          ),
          _benefit("GiftPay Travel", "Redeem rewards for flights and hotels."),
          _benefit("GiftPay Shopping", "Get exclusive deals and discounts."),
        ],
      ),
    );
  }

  Widget _benefit(String title, String subtitle) {
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
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }
}
