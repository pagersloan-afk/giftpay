import 'package:flutter/material.dart';

class BulkFeaturesSection extends StatelessWidget {
  const BulkFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          "Key Features",
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 39, 61, 104),
          ),
        ),
        SizedBox(height: 20),

        _FeatureItem("Automated multi‑meter token generation"),
        _FeatureItem("Instant delivery to staff or tenants"),
        _FeatureItem("Supports all major electricity providers"),
        _FeatureItem("Bulk purchase with GiftPay Wallet"),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        "• $text",
        style: const TextStyle(
          fontFamily: 'SegoeUI',
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
    );
  }
}
