import 'package:flutter/material.dart';

class BusinessDashboardFeaturesSection extends StatelessWidget {
  const BusinessDashboardFeaturesSection({super.key});

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

        _FeatureItem("Unified view of all utilities"),
        _FeatureItem("Automated workflows for electricity, airtime, data"),
        _FeatureItem("Staff allowance management"),
        _FeatureItem("Real‑time analytics and reporting"),
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
