import 'package:flutter/material.dart';

class LandingFooter extends StatefulWidget {
  const LandingFooter({super.key});

  @override
  State<LandingFooter> createState() => _LandingFooterState();
}

class _LandingFooterState extends State<LandingFooter> {
  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF75A1FF);
  static const Color _deepBackground = Color(0xFF080D1A);
  static const Color _surface = Color(0xFF101827);

  final Set<String> _hoveredLinks = <String>{};

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool isMobile = width < 700;
    final bool isTablet = width >= 700 && width < 1100;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_deepBackground, Color(0xFF0D1526), Color(0xFF111B2D)],
        ),
      ),
      child: Stack(
        children: [
          // ==============================================================
          // BACKGROUND GLOW
          // ==============================================================
          Positioned(
            top: -180,
            right: -120,
            child: IgnorePointer(
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _blue.withOpacity(0.14),
                      _blue.withOpacity(0.035),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -220,
            left: -150,
            child: IgnorePointer(
              child: Container(
                width: 480,
                height: 480,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _lightBlue.withOpacity(0.075),
                      _lightBlue.withOpacity(0.018),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ==============================================================
          // CONTENT
          // ==============================================================
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile
                  ? 20
                  : isTablet
                  ? 30
                  : 44,
              vertical: isMobile
                  ? 42
                  : isTablet
                  ? 52
                  : 64,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  children: [
                    _buildTopSection(
                      context,
                      isMobile: isMobile,
                      isTablet: isTablet,
                    ),

                    SizedBox(
                      height: isMobile
                          ? 38
                          : isTablet
                          ? 46
                          : 54,
                    ),

                    _buildDivider(),

                    SizedBox(
                      height: isMobile
                          ? 32
                          : isTablet
                          ? 38
                          : 44,
                    ),

                    _buildLinkSection(
                      context,
                      isMobile: isMobile,
                      isTablet: isTablet,
                    ),

                    SizedBox(
                      height: isMobile
                          ? 36
                          : isTablet
                          ? 42
                          : 50,
                    ),

                    _buildDivider(),

                    const SizedBox(height: 24),

                    _buildBottomBar(context, isMobile: isMobile),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TOP SECTION
  // ==========================================================================

  Widget _buildTopSection(
    BuildContext context, {
    required bool isMobile,
    required bool isTablet,
  }) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBrandBlock(),

          const SizedBox(height: 34),

          _buildDownloadBlock(isMobile: true),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildBrandBlock()),

        SizedBox(width: isTablet ? 40 : 80),

        _buildDownloadBlock(isMobile: false),
      ],
    );
  }

  // ==========================================================================
  // BRAND BLOCK
  // ==========================================================================

  Widget _buildBrandBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [_lightBlue, _blue]),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'G I F T P A Y',
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 3.2,
                color: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        const Text(
          'Simple digital payments.\nBuilt for everyday life.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 28,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 14),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Pay bills, buy airtime and data, manage your wallet, '
            'and access digital services through one simple experience.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 14,
              height: 1.65,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.58),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.055),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _lightBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/gifttech');
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Text(
                      'A Gift Technology Ltd product',
                      style: TextStyle(
                        fontFamily: 'SegoeUI',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.62),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================================
  // DOWNLOAD BLOCK
  // ==========================================================================

  Widget _buildDownloadBlock({required bool isMobile}) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          'GET GIFT PAY',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
            color: _lightBlue.withOpacity(0.85),
          ),
        ),

        const SizedBox(height: 9),

        Text(
          'Your everyday digital wallet.',
          textAlign: isMobile ? TextAlign.left : TextAlign.right,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _storeButton(
              icon: Icons.apple_rounded,
              eyebrow: 'Download on the',
              label: 'App Store',
            ),
            const SizedBox(width: 10),
            _storeButton(
              icon: Icons.android_rounded,
              eyebrow: 'Get it on',
              label: 'Google Play',
            ),
          ],
        ),
      ],
    );
  }

  Widget _storeButton({
    required IconData icon,
    required String eyebrow,
    required String label,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.055),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.11)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 23),
            const SizedBox(width: 9),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 7.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.52),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // LINK SECTION
  // ==========================================================================

  Widget _buildLinkSection(
    BuildContext context, {
    required bool isMobile,
    required bool isTablet,
  }) {
    final columns = [
      _column('Products', [
        _item(context, 'Electricity', '/bulk-electricity'),
        _item(context, 'Airtime & Data', '/airtime-distribution'),
        _item(context, 'Gift Cards', '/gift-cards'),
        _item(context, 'Rewards', '/rewards'),
        _item(context, 'Business', '/business'),
      ]),
      _column('Company', [
        _item(context, 'About GiftPay', '/about_us'),
        _item(context, 'Careers', '/giftpay-careers'),
        _item(context, 'Press', '/press'),
        _item(context, 'Security', '/security'),
      ]),
      _column('Support', [
        _item(context, 'Help Center', '/help'),
        _item(context, 'Contact Us', '/contact_us'),
        _item(context, 'FAQs', '/giftpay-faq'),
      ]),
      _column('Legal', [
        _item(context, 'Privacy Policy', '/giftpay-privacy'),
        _item(context, 'Terms & Conditions', '/giftpay-terms'),
        _item(context, 'Refund Policy', '/giftpay-refund'),
      ]),
    ];

    // --------------------------------------------------------------------------
    // MOBILE
    // Explicit 2-column grid
    // --------------------------------------------------------------------------
    if (isMobile) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final columnWidth = (availableWidth - 24) / 2;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: columnWidth, child: columns[0]),

                    const SizedBox(height: 34),

                    SizedBox(width: columnWidth, child: columns[2]),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: columnWidth, child: columns[1]),

                    const SizedBox(height: 34),

                    SizedBox(width: columnWidth, child: columns[3]),
                  ],
                ),
              ),
            ],
          );
        },
      );
    }

    // --------------------------------------------------------------------------
    // TABLET / DESKTOP
    // Keep the existing 4-column horizontal layout
    // --------------------------------------------------------------------------

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < columns.length; i++) ...[
          Expanded(child: columns[i]),
          if (i != columns.length - 1) SizedBox(width: isTablet ? 16 : 28),
        ],
      ],
    );
  }

  // ==========================================================================
  // FOOTER COLUMN
  // ==========================================================================

  Widget _column(String title, List<Widget> items, {double? width}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 15),

          for (final item in items)
            Padding(padding: const EdgeInsets.only(bottom: 10), child: item),
        ],
      ),
    );
  }
  // ==========================================================================
  // FOOTER LINK
  // ==========================================================================

  Widget _item(BuildContext context, String label, String route) {
    final bool hovered = _hoveredLinks.contains(label);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hoveredLinks.add(label);
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredLinks.remove(label);
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pushNamed(context, route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: hovered ? 5 : 0,
                height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _lightBlue,
                ),
              ),
              SizedBox(width: hovered ? 7 : 0),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 160),
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 13,
                  fontWeight: hovered ? FontWeight.w600 : FontWeight.w400,
                  color: hovered
                      ? Colors.white
                      : Colors.white.withOpacity(0.55),
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // DIVIDER
  // ==========================================================================

  Widget _buildDivider() {
    return Container(
      height: 1,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.10),
            Colors.white.withOpacity(0.06),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // BOTTOM BAR
  // ==========================================================================

  Widget _buildBottomBar(BuildContext context, {required bool isMobile}) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCopyright(),

          const SizedBox(height: 18),

          _buildBottomLinks(context),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildCopyright(), _buildBottomLinks(context)],
    );
  }

  Widget _buildCopyright() {
    return Text(
      '© 2026 GiftPay. All rights reserved.',
      style: TextStyle(
        fontFamily: 'SegoeUI',
        fontSize: 11.5,
        color: Colors.white.withOpacity(0.42),
      ),
    );
  }

  Widget _buildBottomLinks(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 8,
      children: [
        _bottomLink(context, 'Gift Technology Ltd', '/about'),
        _bottomLink(context, 'Privacy', '/privacy-policy'),
        _bottomLink(context, 'Terms', '/giftpay-terms'),
        _bottomLink(context, 'Security', '/security'),
      ],
    );
  }

  Widget _bottomLink(BuildContext context, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'SegoeUI',
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: Colors.white.withOpacity(0.48),
        ),
      ),
    );
  }
}
