import 'package:flutter/material.dart';

class GiftPayPersonalFeaturesSection extends StatelessWidget {
  const GiftPayPersonalFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          "Why GiftPay Personal?",
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 39, 61, 104),
          ),
        ),
        SizedBox(height: 20),

        _FeatureItem("Buy electricity tokens instantly"),
        _FeatureItem("Top‑up airtime for any network"),
        _FeatureItem("Purchase data bundles in seconds"),
        _FeatureItem("Track all purchases in one wallet"),
        _FeatureItem("Fast, secure, and reliable payments"),
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
