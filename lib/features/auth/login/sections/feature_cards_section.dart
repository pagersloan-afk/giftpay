import 'package:flutter/material.dart';

class FeatureCardsSection extends StatelessWidget {
  const FeatureCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: Colors.blueAccent),
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
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
