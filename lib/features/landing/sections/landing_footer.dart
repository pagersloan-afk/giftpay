import 'package:flutter/material.dart';

class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      width: double.infinity,
      color: const Color(0xFF0A0F1F), // ⭐ DARK NIGHT BACKGROUND
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
                    SizedBox(width: 320, child: _regulatoryColumn()),
                    const SizedBox(width: 60),
                    Expanded(child: _columnsWrap(context)),
                  ],
                ),
        ),
      ),
    );
  }

  // ⭐ REGULATORY COLUMN
  Widget _regulatoryColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "GiftPay is operated by Gift Technology Ltd and complies with Nigerian financial regulations. "
          "Deposits and wallet balances are secured using industry‑standard encryption and protected infrastructure.",
          style: TextStyle(
            fontFamily: 'Inter',
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
        color: const Color(0xFF111827), // ⭐ Dark card
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
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ FOUR COLUMNS
  Widget _columnsWrap(BuildContext context) {
    return Wrap(
      spacing: 40,
      runSpacing: 40,
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
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          for (final item in items)
            Padding(padding: const EdgeInsets.only(bottom: 8), child: item),
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
          fontFamily: 'Inter',
          fontSize: 14,
          color: Colors.white70,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
