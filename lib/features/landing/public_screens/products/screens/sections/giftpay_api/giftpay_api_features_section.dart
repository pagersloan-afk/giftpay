import 'package:flutter/material.dart';

class GiftPayApiFeaturesSection extends StatelessWidget {
  const GiftPayApiFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          "API Capabilities",
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 39, 61, 104),
          ),
        ),
        SizedBox(height: 20),

        _FeatureItem("Electricity token generation API"),
        _FeatureItem("Airtime top‑up API"),
        _FeatureItem("Data bundle purchase API"),
        _FeatureItem("Wallet debit/credit API"),
        _FeatureItem("Webhook notifications for all transactions"),
        _FeatureItem("Enterprise‑grade authentication & security"),
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
