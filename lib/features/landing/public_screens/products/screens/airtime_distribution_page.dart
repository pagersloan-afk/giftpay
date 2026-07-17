import 'package:flutter/material.dart';

class AirtimeDistributionPage extends StatelessWidget {
  const AirtimeDistributionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _heroSection(isMobile),
            const SizedBox(height: 40),
            _featuresSection(),
            const SizedBox(height: 40),
            _ctaSection(context),
          ],
        ),
      ),
    );
  }

  Widget _heroSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 40 : 80,
      ),
      decoration: const BoxDecoration(color: Color.fromARGB(255, 39, 61, 104)),
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: const [
          Text(
            "Airtime Distribution",
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Automate airtime top‑ups for staff, teams, and personal use.",
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuresSection() {
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
        _FeatureItem("Automated monthly airtime allowances"),
        _FeatureItem("Supports MTN, Airtel, Glo, 9Mobile"),
        _FeatureItem("Bulk distribution for teams"),
        _FeatureItem("Instant delivery with GiftPay Wallet"),
      ],
    );
  }

  Widget _ctaSection(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 39, 61, 104),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: const StadiumBorder(),
      ),
      onPressed: () => Navigator.pushNamed(context, '/login'),
      child: const Text(
        "Get Started",
        style: TextStyle(fontFamily: 'SegoeUI', fontSize: 18),
      ),
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
