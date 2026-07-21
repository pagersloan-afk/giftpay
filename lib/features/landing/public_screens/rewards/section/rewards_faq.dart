import 'package:flutter/material.dart';

class RewardsFAQSection extends StatelessWidget {
  const RewardsFAQSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final List<Map<String, String>> faqs = [
      {
        "q": "How do I earn rewards?",
        "a":
            "Rewards are earned automatically on every GiftPay purchase — utilities, gift cards, data, airtime, and more.",
      },
      {
        "q": "Where can I redeem my points?",
        "a":
            "Points can be redeemed for discounts, vouchers, gift cards, and exclusive partner offers inside the Rewards section.",
      },
      {
        "q": "Do my rewards expire?",
        "a":
            "GiftPay rewards do not expire. Some partner‑specific bonuses may have validity periods.",
      },
      {
        "q": "How do I move to a higher tier?",
        "a":
            "Your tier increases automatically based on your monthly and yearly spending activity.",
      },
      {
        "q": "Can I earn rewards on gift card purchases?",
        "a": "Yes. Gift card purchases earn both cashback and loyalty points.",
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
