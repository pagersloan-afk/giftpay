import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class RewardsTiersSection extends StatelessWidget {
  const RewardsTiersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final List<Map<String, dynamic>> tiers = [
      {
        "title": "Blue Tier",
        "description": "Earn up to 2% cashback on all purchases.",
        "icon": Icons.star_border,
      },
      {
        "title": "Silver Tier",
        "description": "Earn 4% cashback + bonus points.",
        "icon": Icons.star_half,
      },
      {
        "title": "Gold Tier",
        "description": "Earn 6% cashback + exclusive partner rewards.",
        "icon": Icons.star,
      },
      {
        "title": "Platinum Tier",
        "description": "Earn 10% cashback + VIP perks and early access.",
        "icon": Icons.workspace_premium,
      },
    ];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            "Reward Tiers",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: isMobile ? 22 : 26,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: isMobile ? 16 : 20,
            runSpacing: isMobile ? 16 : 20,
            alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
            children: tiers.map((tier) {
              return _TierCard(
                title: tier["title"]!,
                description: tier["description"]!,
                icon: tier["icon"] as IconData,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _TierCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: isMobile ? double.infinity : 260,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.70),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: GiftPayTheme.primaryBlue),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: isMobile ? 15 : 17,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 13 : 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
