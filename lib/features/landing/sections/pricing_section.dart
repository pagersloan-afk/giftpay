import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class PricingSection extends StatefulWidget {
  const PricingSection({super.key});

  @override
  State<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<PricingSection> {
  int currentPage = 0;

  final List<Map<String, dynamic>> pricingItems = [
    {
      "title": "Electricity Tokens",
      "items": [
        "Instant token delivery",
        "Service fee: ₦10–₦25",
        "Minimum purchase: ₦100",
      ],
      "icon": Icons.bolt,
      "gradient": [const Color(0xFF273D68), const Color(0xFF4A6BB8)],
    },
    {
      "title": "Airtime & Data",
      "items": [
        "Network rate (no markup)",
        "Processing fee: ₦0–₦10",
        "Instant delivery",
      ],
      "icon": Icons.network_cell,
      "gradient": [const Color(0xFF0033CC), const Color(0xFF4A6BB8)],
    },
    {
      "title": "Wallet Funding",
      "items": [
        "Bank transfer: Free",
        "Card payments: Gateway fees apply",
        "Instant wallet credit",
      ],
      "icon": Icons.account_balance_wallet,
      "gradient": [const Color(0xFF4A6BB8), const Color(0xFF273D68)],
    },
    {
      "title": "Gift Cards",
      "items": [
        "Starting from ₦7,000",
        "Processing fee: ₦0–₦20",
        "Instant digital delivery",
      ],
      "icon": Icons.card_giftcard,
      "gradient": [const Color(0xFF273D68), const Color(0xFF0033CC)],
    },
    {
      "title": "Transfers",
      "items": [
        "Send to any Nigerian bank",
        "Fee: ₦10–₦25",
        "Instant settlement",
      ],
      "icon": Icons.send,
      "gradient": [const Color(0xFF0033CC), const Color(0xFF4A6BB8)],
    },
    {
      "title": "Business Solutions",
      "items": [
        "Bulk utilities automation",
        "Custom pricing available",
        "Dedicated business support",
      ],
      "icon": Icons.business_center,
      "gradient": [const Color(0xFF4A6BB8), const Color(0xFF0033CC)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    final visibleCount = isMobile ? 1 : 3;
    final totalPages = (pricingItems.length / visibleCount).ceil();

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 24 : 40,
        ),

        // ⭐ Luxury gradient background (instead of solid gray)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.90),
              const Color(0xFFF0F0F0).withOpacity(0.85),
              const Color(0xFFE8E8E8).withOpacity(0.80),
            ],
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pricing",
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 22 : 28,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              "GiftPay is built on clear, simple, and predictable pricing. No hidden fees. Every transaction shows its cost upfront before you pay.",
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 13 : 15,
                color: Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // ⭐ SINGLE ROW CAROUSEL
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: GiftPayTheme.primaryBlue,
                  onPressed: () {
                    setState(() {
                      if (currentPage > 0) currentPage--;
                    });
                  },
                ),

                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(visibleCount, (i) {
                      final index = currentPage * visibleCount + i;

                      if (index >= pricingItems.length) {
                        return const SizedBox.shrink();
                      }

                      final item = pricingItems[index];

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: AnimatedPricingCard(
                            title: item["title"],
                            items: List<String>.from(item["items"]),
                            iconData: item["icon"],
                            gradientColors: List<Color>.from(item["gradient"]),
                            isMobile: isMobile,
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  color: GiftPayTheme.primaryBlue,
                  onPressed: () {
                    setState(() {
                      if (currentPage < totalPages - 1) currentPage++;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalPages, (index) {
                final active = index == currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? GiftPayTheme.primaryBlue : Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ⭐ Animated Pricing Card
class AnimatedPricingCard extends StatefulWidget {
  final String title;
  final List<String> items;
  final IconData iconData;
  final List<Color> gradientColors;
  final bool isMobile;

  const AnimatedPricingCard({
    super.key,
    required this.title,
    required this.items,
    required this.iconData,
    required this.gradientColors,
    required this.isMobile,
  });

  @override
  State<AnimatedPricingCard> createState() => _AnimatedPricingCardState();
}

class _AnimatedPricingCardState extends State<AnimatedPricingCard> {
  double hoverScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hoverScale = 1.03),
      onExit: (_) => setState(() => hoverScale = 1.0),
      child: AnimatedScale(
        scale: hoverScale,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,

        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.20),
              width: 1.2,
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.20),
                    ),
                    child: Icon(widget.iconData, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: 'SegoeUI',
                        fontWeight: FontWeight.w700,
                        fontSize: widget.isMobile ? 17 : 19,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              for (final item in widget.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "• $item",
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: widget.isMobile ? 13 : 15,
                      color: Colors.white.withOpacity(0.90),
                      height: 1.45,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
