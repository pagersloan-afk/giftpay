import 'package:flutter/material.dart';

class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 900;
    final bool isTablet = width >= 900 && width < 1200;

    return Container(
      width: double.infinity,
      color: const Color(0xFF0A0F1F),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 40 : 60,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _regulatoryColumn(),
                    const SizedBox(height: 40),
                    _columnsWrap(context),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 300, child: _regulatoryColumn()),
                    const SizedBox(width: 40),
                    Expanded(child: _columnsWrap(context)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _regulatoryColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "GiftPay is operated by Gift Technology Ltd and complies with Nigerian financial regulations. "
          "Deposits and wallet balances are secured using industry‑standard encryption and protected infrastructure.",
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 14,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _storeButton(Icons.apple, "App Store"),
            const SizedBox(width: 12),
            _storeButton(Icons.android, "Google Play"),
          ],
        ),
      ],
    );
  }

  Widget _storeButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _columnsWrap(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 900;
    final bool isTablet = width >= 900 && width < 1200;

    final double spacing = isMobile ? 12 : (isTablet ? 20 : 24);
    final double runSpacing = isMobile ? 20 : 28;

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        _column("Products", [
          _item(context, "Electricity", "/"),
          _item(context, "Airtime & Data", "/"),
          _item(context, "Gift Cards", "/"),
          _item(context, "Rewards", "/"),
          _item(context, "Business", "/business"),
        ]),
        _column("Company", [
          _item(context, "About GiftPay", "/about"),
          _item(context, "Careers", "/"),
          _item(context, "Press", "/"),
          _item(context, "Security", "/"),
        ]),
        _column("Support", [
          _item(context, "Help Center", "/help-center"),
          _item(context, "Contact Us", "/contact"),
          _item(context, "FAQs", "/faqs"),
        ]),
        _column("Legal", [
          _item(context, "Privacy Policy", "/privacy-policy"),
          _item(context, "Terms & Conditions", "/terms-and-conditions"),
          _item(context, "Refund Policy", "/refund-policy"),
        ]),
      ],
    );
  }

  Widget _column(String title, List<Widget> items) {
    return SizedBox(
      width: 180, // ⭐ tightened from 200 → 180
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          for (final item in items)
            Padding(padding: const EdgeInsets.only(bottom: 6), child: item),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'SegoeUI',
          fontSize: 14,
          color: Colors.white70,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
