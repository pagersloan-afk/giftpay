import 'package:flutter/material.dart';

class CorporateDataFeaturesSection extends StatelessWidget {
  const CorporateDataFeaturesSection({super.key});

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

        _FeatureItem("Automated monthly data allowances"),
        _FeatureItem("Supports all major networks"),
        _FeatureItem("Device‑level provisioning"),
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
