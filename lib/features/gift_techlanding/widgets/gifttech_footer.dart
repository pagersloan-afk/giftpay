import 'package:flutter/material.dart';

class GiftTechFooter extends StatelessWidget {
  const GiftTechFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 900;
    final bool isTablet = width >= 900 && width < 1200;

    return Container(
      width: double.infinity,

      // ⭐ Full‑bleed luxury gradient (Meta-style)
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0F1F), Color(0xFF111827)],
        ),
      ),

      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 40 : 60,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------------
          // TOP ROW: LOGO + SOCIAL ICONS
          // ------------------------------------------------------------
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo + Social Icons
                Row(
                  children: [
                    // ⭐ Gift Technology Ltd Logo (Text-based for now)
                    const Text(
                      "Gift Technology Ltd",
                      style: TextStyle(
                        fontFamily: 'SegoeUI',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 24),

                    // ⭐ Social Icons (Meta-style)
                    Row(
                      children: [
                        _socialIcon(Icons.facebook),
                        const SizedBox(width: 12),
                        _socialIcon(Icons.music_note), // Kponkios
                        const SizedBox(width: 12),
                        _socialIcon(Icons.mic), // TheVoice
                        const SizedBox(width: 12),
                        _socialIcon(Icons.public), // X/Twitter
                        const SizedBox(width: 12),
                        _socialIcon(Icons.play_circle_fill), // YouTube
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ------------------------------------------------------------
                // META-STYLE MULTI-COLUMN FOOTER
                // ------------------------------------------------------------
                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [_columnsWrap(context)],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Expanded(child: _columnsWrap(context))],
                      ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // ⭐ Divider
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.white.withOpacity(0.08),
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------------------
          // COPYRIGHT
          // ------------------------------------------------------------
          Text(
            "© 2026 Gift Technology Ltd. All rights reserved.",
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isMobile ? 12 : 13,
              color: Colors.white.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SOCIAL ICON BUTTON
  // ------------------------------------------------------------
  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  // ------------------------------------------------------------
  // META-STYLE COLUMNS WRAPPER
  // ------------------------------------------------------------
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
        // ⭐ Column 1 — Store (Meta Store equivalent)
        _column("Gift Technology Store", [
          _item(context, "GiftPay Wallet", "/giftpay"),
          _item(context, "GiftPOS", "/pos"),
          _item(context, "GiftCard Marketplace", "/giftcards"),
          _item(context, "Utilities Hub", "/utilities"),
          _item(context, "Bulk Electricity Tokens", "/bulk-electricity"),
          _item(context, "Corporate Data Plans", "/corporate-data"),
          _item(context, "Airtime Distribution", "/airtime-distribution"),
        ]),

        // ⭐ Column 2 — Support & Legal
        _column("Support & Legal", [
          _item(context, "Help Center", "/help-center"),
          _item(context, "Order Status", "/orders"),
          _item(context, "Returns", "/returns"),
          _item(context, "Find a Store", "/stores"),
          _item(context, "Legal", "/legal"),
          _item(context, "Terms of Sale", "/terms-sale"),
          _item(context, "Safety Center", "/safety"),
        ]),

        // ⭐ Column 3 — Community
        _column("Community", [
          _item(context, "Creators", "/creators"),
          _item(context, "Developers", "/developers"),
          _item(context, "Businesses", "/business"),
          _item(context, "Non-profits", "/nonprofits"),
          _item(context, "Download SDKs", "/sdks"),
          _item(context, "Partner Program", "/partners"),
          _item(context, "Tech for Good", "/tech-for-good"),
        ]),

        // ⭐ Column 4 — Our Actions
        _column("Our Actions", [
          _item(context, "Data & Privacy", "/privacy"),
          _item(context, "Responsible Practices", "/responsibility"),
          _item(context, "Accessibility", "/accessibility"),
          _item(context, "Elections", "/elections"),
        ]),

        // ⭐ Column 5 — About Us
        _column("About Us", [
          _item(context, "About Gift Technology Ltd", "/about"),
          _item(context, "Company Info", "/company-info"),
          _item(context, "Careers", "/careers"),
          _item(context, "Media Gallery", "/media"),
          _item(context, "Brand Resources", "/brand"),
          _item(context, "Investors", "/investors"),
          _item(context, "Newsroom", "/newsroom"),
        ]),

        // ⭐ Column 6 — Policies
        _column("Site Terms & Policies", [
          _item(context, "Community Standards", "/community-standards"),
          _item(context, "Privacy Policy", "/privacy-policy"),
          _item(context, "Terms", "/terms"),
          _item(context, "Cookie Policy", "/cookies"),
        ]),
      ],
    );
  }

  // ------------------------------------------------------------
  // COLUMN BUILDER
  // ------------------------------------------------------------
  Widget _column(String title, List<Widget> items) {
    return SizedBox(
      width: 200,
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

  // ------------------------------------------------------------
  // FOOTER LINK ITEM
  // ------------------------------------------------------------
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
