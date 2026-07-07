import 'package:flutter/material.dart';

class FeatureCardsSection extends StatelessWidget {
  const FeatureCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // ↓ Reduced vertical padding from 60 → 32
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 32,
      ), // ADJUSTED
      child: Wrap(
        spacing: 30,
        runSpacing: 30,
        children: [
          _card(
            icon: Icons.flash_on,
            title: "Electricity Tokens",
            subtitle:
                "Buy instant prepaid electricity with fast token delivery.",
            action: "Buy Electricity",
          ),
          _card(
            icon: Icons.wifi,
            title: "Airtime & Data",
            subtitle: "Top up airtime or data instantly across all networks.",
            action: "Top Up Now",
          ),
          _card(
            icon: Icons.card_giftcard,
            title: "Gift Cards",
            subtitle: "Shop global gift cards with instant delivery.",
            action: "Explore Cards",
          ),
        ],
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required String subtitle,
    required String action,
  }) {
    return Container(
      width: 320,
      // ↓ Reduced inner padding from 24 → 20
      padding: const EdgeInsets.all(20), // ADJUSTED
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: Colors.blueAccent),
          const SizedBox(height: 16), // ↓ Reduced from 20 → 16
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8), // ↓ Reduced from 10 → 8
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 16), // ↓ Reduced from 20 → 16
          Text(
            action,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
