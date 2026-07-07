import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      color: Colors.black.withOpacity(0.2),
      child: isMobile
          // Mobile: stack vertically
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _regulatoryColumn(),
                const SizedBox(height: 40),
                _columnsWrap(context),
              ],
            )
          // Desktop: Moniepoint-style row
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT: regulatory + store buttons (first column)
                SizedBox(width: 280, child: _regulatoryColumn()),
                const SizedBox(width: 40),
                // RIGHT: your 4 columns
                Expanded(child: _columnsWrap(context)),
              ],
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
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            // App Store
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.apple, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "App Store",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Google Play
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.android, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Google Play",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _columnsWrap(BuildContext context) {
    return Wrap(
      spacing: 20, // reduced from 80
      runSpacing: 20,
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
          color: Colors.white70,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
