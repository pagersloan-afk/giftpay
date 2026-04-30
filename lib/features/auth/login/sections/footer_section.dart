import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      color: Colors.black.withOpacity(0.2),
      child: Wrap(
        spacing: 80,
        runSpacing: 40,
        children: [
          _column("Products", [
            "Electricity",
            "Airtime & Data",
            "Gift Cards",
            "Rewards",
            "Business",
          ]),
          _column("Company", ["About GiftPay", "Careers", "Press", "Security"]),
          _column("Support", ["Help Center", "Contact Us", "FAQs"]),
          _column("Legal", ["Privacy Policy", "Terms & Conditions"]),
        ],
      ),
    );
  }

  Widget _column(String title, List<String> items) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(item, style: const TextStyle(color: Colors.white70)),
            ),
        ],
      ),
    );
  }
}
