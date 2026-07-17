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
      "icon": Icons.bolt, // ⚡ Electricity
    },
    {
      "title": "Airtime & Data",
      "items": [
        "Network rate (no markup)",
        "Processing fee: ₦0–₦10",
        "Instant delivery",
      ],
      "icon": Icons.network_cell, // 📶 Airtime/Data
    },
    {
      "title": "Wallet Funding",
      "items": [
        "Bank transfer: Free",
        "Card payments: Gateway fees apply",
        "Instant wallet credit",
      ],
      "icon": Icons.account_balance_wallet, // 👛 Wallet
    },
    {
      "title": "Gift Cards",
      "items": [
        "Starting from ₦7,000",
        "Processing fee: ₦0–₦20",
        "Instant digital delivery",
      ],
      "icon": Icons.card_giftcard, // 🎁 Gift Cards
    },
    {
      "title": "Transfers",
      "items": [
        "Send to any Nigerian bank",
        "Fee: ₦10–₦25",
        "Instant settlement",
      ],
      "icon": Icons.send, // 💸 Transfers
    },
    {
      "title": "Business Solutions",
      "items": [
        "Bulk utilities automation",
        "Custom pricing available",
        "Dedicated business support",
      ],
      "icon": Icons.business_center, // 🏢 Business
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
        color: const Color(0xFFF9F9F9),

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
                          child: _pricingCard(
                            title: item["title"],
                            items: List<String>.from(item["items"]),
                            iconData: item["icon"],
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

  Widget _pricingCard({
    required String title,
    required List<String> items,
    required IconData iconData,
    required bool isMobile,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: GiftPayTheme.primaryBlue.withOpacity(0.12),
          width: 1.1,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: GiftPayTheme.primaryBlue.withOpacity(0.08),
                ),
                child: Icon(
                  iconData,
                  size: 22,
                  color: GiftPayTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 17 : 19,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "• $item",
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: isMobile ? 13 : 15,
                  color: Colors.black54,
                  height: 1.45,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
