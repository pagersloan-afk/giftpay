import 'package:flutter/material.dart';

class PromoSection extends StatelessWidget {
  const PromoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 24 : 40,
        ),
        color: const Color(0xFFF9F9F9),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _promoText(isMobile),
                  const SizedBox(height: 24),
                  _promoImage(isMobile),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _promoText(isMobile)),
                  const SizedBox(width: 40),
                  Expanded(child: _promoImage(isMobile)),
                ],
              ),
      ),
    );
  }

  Widget _promoText(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Fast, Secure & Global Digital Payments",
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 22 : 28,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Transfer money, fund your wallet, buy utilities, and enjoy instant rewards — all in one place.",
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: isMobile ? 13 : 15,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 32,
          runSpacing: 16,
          children: [
            _stat("5M+", "Transactions Processed"),
            _stat("Instant", "Wallet Funding"),
            _stat("24/7", "Transfers & Support"),
            _stat("100%", "Token Delivery"),
          ],
        ),
      ],
    );
  }

  Widget _promoImage(bool isMobile) {
    return Container(
      alignment: Alignment.center,
      child: Image.asset(
        "assets/images/financial-app-promo.webp",
        fit: BoxFit.contain,
        height: isMobile ? 240 : 380,
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
