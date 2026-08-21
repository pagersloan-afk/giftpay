import 'package:flutter/material.dart';

import 'package:utilityhub/features/landing/public_screens/products/screens/sections/airtime/airtime_cta_section.dart';
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/airtime/airtime_features_section.dart';
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/airtime/airtime_hero_section.dart';

import 'package:utilityhub/features/landing/sections/landing_footer.dart';
import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

class AirtimeDistributionPage extends StatelessWidget {
  const AirtimeDistributionPage({super.key});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color background = Color(0xFFF8FAFD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: const LandingHeader(),
      body: LandingResponsiveLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            AirtimeHeroSection(),

            SizedBox(height: 72),

            AirtimeFeaturesSection(),

            SizedBox(height: 72),

            _AirtimeHighlightSection(),

            SizedBox(height: 72),

            AirtimeCTASection(),

            SizedBox(height: 72),

            LandingFooter(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HIGHLIGHT SECTION
// ============================================================

class _AirtimeHighlightSection extends StatelessWidget {
  const _AirtimeHighlightSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < 760) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HighlightCard(
                icon: Icons.speed_rounded,
                title: 'Instant distribution',
                description:
                    'Deliver airtime to employees, agents, customers and teams without manual processing.',
              ),
              SizedBox(height: 16),
              _HighlightCard(
                icon: Icons.account_balance_wallet_rounded,
                title: 'GiftPay Wallet powered',
                description:
                    'Use your GiftPay business wallet to manage airtime distribution with a simple and secure workflow.',
              ),
              SizedBox(height: 16),
              _HighlightCard(
                icon: Icons.analytics_rounded,
                title: 'Built for visibility',
                description:
                    'Keep your business organized with clear transaction records and a centralized distribution experience.',
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: _HighlightCard(
                icon: Icons.speed_rounded,
                title: 'Instant distribution',
                description:
                    'Deliver airtime to employees, agents, customers and teams without manual processing.',
              ),
            ),
            SizedBox(width: width >= 1100 ? 24 : 16),
            const Expanded(
              child: _HighlightCard(
                icon: Icons.account_balance_wallet_rounded,
                title: 'GiftPay Wallet powered',
                description:
                    'Use your GiftPay business wallet to manage airtime distribution with a simple and secure workflow.',
              ),
            ),
            SizedBox(width: width >= 1100 ? 24 : 16),
            const Expanded(
              child: _HighlightCard(
                icon: Icons.analytics_rounded,
                title: 'Built for visibility',
                description:
                    'Keep your business organized with clear transaction records and a centralized distribution experience.',
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// HIGHLIGHT CARD
// ============================================================

class _HighlightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EAF3)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.055),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: blue.withOpacity(0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: blue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: navy,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 14,
                    height: 1.55,
                    color: Color(0xFF687386),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
