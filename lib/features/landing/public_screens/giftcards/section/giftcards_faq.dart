import 'package:flutter/material.dart';

class GiftCardsFAQSection extends StatelessWidget {
  const GiftCardsFAQSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final faqs = [
      {
        "q": "How do I redeem a GiftPay gift card?",
        "a":
            "Open the GiftPay app, go to Gift Cards, select the card, and tap Redeem.",
      },
      {
        "q": "Can I send gift cards to others?",
        "a":
            "Yes. You can send digital gift cards instantly to any GiftPay user.",
      },
      {
        "q": "Do gift cards expire?",
        "a":
            "Most GiftPay gift cards do not expire. Some partner cards may have validity periods.",
      },
      {
        "q": "Can I earn rewards from gift card purchases?",
        "a": "Yes. Every gift card purchase earns cashback and loyalty points.",
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
            "Frequently Asked Questions",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: isMobile ? 22 : 26,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          ...faqs.map((faq) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(isMobile ? 14 : 18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.70),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.35),
                  width: 1.2,
                ),
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
                children: [
                  Text(
                    faq["q"]!,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: isMobile ? 15 : 17,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    faq["a"]!,
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
          }).toList(),
        ],
      ),
    );
  }
}
