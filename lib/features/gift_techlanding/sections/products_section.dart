import 'package:flutter/material.dart';
import 'package:utilityhub/features/landing/widgets/parent_overlay_card.dart';
import 'hero_section.dart'; // For AnimatedLiftCard reuse
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class ProductsSection extends StatelessWidget {
  const ProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 40 : 80,
      ),
      child: ParentOverlayCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------------------
            // SECTION TITLE
            // ------------------------------------------------------------
            Text(
              "Our Products & Services",
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 26 : 34,
                fontWeight: FontWeight.w800,
                color: const Color.fromARGB(255, 20, 40, 80),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Explore the platforms, tools, and digital services we build to empower individuals, businesses, and communities across Africa.",
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 15 : 17,
                height: 1.6,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 40),

            // ------------------------------------------------------------
            // PRODUCT GRID
            // ------------------------------------------------------------
            _productGrid(context, isMobile),
          ],
        ),
      ),
    );
  }

  // ⭐ PRODUCT GRID
  Widget _productGrid(BuildContext context, bool isMobile) {
    final List<Map<String, dynamic>> products = [
      {
        "name": "GiftPay",
        "route": "/giftpay",
        "icon": Icons.account_balance_wallet,
      },
      {"name": "Kponkios", "route": "/kponkios", "icon": Icons.music_note},
      {"name": "TheVoice", "route": "/thevoice", "icon": Icons.mic},
      {
        "name": "E‑Voting System",
        "route": "/evoting",
        "icon": Icons.how_to_vote,
      },
      {
        "name": "GiftBusiness",
        "route": "/business",
        "icon": Icons.business_center,
      },
      {"name": "GiftWallet", "route": "/wallets", "icon": Icons.wallet},
      {"name": "GiftPOS", "route": "/pos", "icon": Icons.point_of_sale},
      {
        "name": "GiftCard Marketplace",
        "route": "/giftcardss",
        "icon": Icons.card_giftcard,
      },
      {"name": "Utilities Hub", "route": "/utilities", "icon": Icons.bolt},
      {
        "name": "Corporate Data Plans",
        "route": "/corporate-datas",
        "icon": Icons.wifi,
      },
      {
        "name": "Bulk Electricity Tokens",
        "route": "/bulk-electricityy",
        "icon": Icons.flash_on,
      },
      {
        "name": "Airtime Distribution",
        "route": "/airtime-distributions",
        "icon": Icons.phone_android,
      },
    ];

    return Wrap(
      spacing: isMobile ? 16 : 24,
      runSpacing: isMobile ? 16 : 24,
      alignment: WrapAlignment.center,
      children: products.map((p) {
        return _productCard(
          context,
          title: p["name"],
          route: p["route"],
          icon: p["icon"],
        );
      }).toList(),
    );
  }

  // ⭐ PRODUCT CARD — LUXURY FINTECH STYLE
  Widget _productCard(
    BuildContext context, {
    required String title,
    required String route,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: AnimatedLiftCard(
        child: Container(
          width: 240,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.30),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 40, color: GiftPayTheme.primaryBlue),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
