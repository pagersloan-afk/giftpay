import 'package:flutter/material.dart';

class FeatureCardsSection extends StatelessWidget {
  const FeatureCardsSection({super.key});

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
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _card(
              icon: Icons.flash_on,
              title: "Electricity Tokens",
              subtitle:
                  "Buy instant prepaid electricity with fast token delivery.",
              action: "Buy Electricity",
              isMobile: isMobile,
            ),
            _card(
              icon: Icons.wifi,
              title: "Airtime & Data",
              subtitle: "Top up airtime or data instantly across all networks.",
              action: "Top Up Now",
              isMobile: isMobile,
            ),
            _card(
              icon: Icons.card_giftcard,
              title: "Gift Cards",
              subtitle: "Shop global gift cards with instant delivery.",
              action: "Explore Cards",
              isMobile: isMobile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required String subtitle,
    required String action,
    required bool isMobile,
  }) {
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
          Icon(icon, size: 40, color: const Color(0xFFB31B1B)),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 13 : 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            action,
            style: TextStyle(
              fontFamily: 'Inter',
              color: const Color(0xFFB31B1B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
