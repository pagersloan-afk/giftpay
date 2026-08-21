import 'dart:ui';

import 'package:flutter/material.dart';

/// GiftPay — Why GiftPay Section
///
/// Purpose:
/// - Explain why users choose GiftPay.
/// - Differentiate GiftPay without unsupported claims.
/// - Present GiftPay as a connected everyday-services ecosystem.
/// - Work naturally inside the light GiftPay landing-page environment.
/// - Maintain the existing luxury / glassmorphism visual language.
///
/// This section is self-contained:
/// - It does not control scrolling.
/// - It does not control routing.
/// - It does not create its own page background.
/// - It can be placed directly inside the landing-page Column.
class WhyGiftPaySection extends StatelessWidget {
  const WhyGiftPaySection({super.key});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF75A1FF);
  static const Color _softBlue = Color(0xFFEAF0FF);
  static const Color _surface = Color(0xFFF7F9FD);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool isMobile = width < 760;
    final bool isTablet = width >= 760 && width < 1100;

    final double horizontalPadding = isMobile
        ? 20
        : isTablet
        ? 34
        : 64;

    final double verticalPadding = isMobile ? 72 : 105;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile),

              SizedBox(height: isMobile ? 32 : 46),

              _buildMainPanel(context, isMobile: isMobile, isTablet: isTablet),

              SizedBox(height: isMobile ? 18 : 22),

              _buildValueGrid(isMobile: isMobile, isTablet: isTablet),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('WHY GIFTPAY'),

        const SizedBox(height: 16),

        Text(
          'One platform for more of everyday life.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: isMobile ? 34 : 54,
            height: 1.02,
            fontWeight: FontWeight.w800,
            letterSpacing: isMobile ? -1.2 : -2.5,
            color: _navy,
          ),
        ),

        const SizedBox(height: 14),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            'GiftPay brings payments, everyday services, digital commerce, '
            'mobility, travel, and business tools into one connected experience.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isMobile ? 15 : 18,
              height: 1.65,
              fontWeight: FontWeight.w400,
              color: _navy.withOpacity(0.58),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // MAIN EXPERIENCE PANEL
  // ===========================================================================

  Widget _buildMainPanel(
    BuildContext context, {
    required bool isMobile,
    required bool isTablet,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isMobile ? 26 : 32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 22 : 38),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMobile ? 26 : 32),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.90),
                Colors.white.withOpacity(0.70),
                _softBlue.withOpacity(0.48),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.95),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _navy.withOpacity(0.08),
                blurRadius: 45,
                offset: const Offset(0, 22),
              ),
              BoxShadow(
                color: _blue.withOpacity(0.055),
                blurRadius: 70,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildMainCopy(),
                    const SizedBox(height: 28),
                    _buildEcosystemVisual(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: isTablet ? 6 : 57, child: _buildMainCopy()),
                    SizedBox(width: isTablet ? 24 : 42),
                    Expanded(
                      flex: isTablet ? 4 : 43,
                      child: _buildEcosystemVisual(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ===========================================================================
  // MAIN COPY
  // ===========================================================================

  Widget _buildMainCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _miniLabel('THE GIFTPAY EXPERIENCE'),

        const SizedBox(height: 13),

        const Text(
          'Built around the way people actually live.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 29,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.1,
            color: _navy,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'Instead of treating payments, utilities, shopping, travel, '
          'mobility, and digital services as separate experiences, GiftPay '
          'is designed to bring them together in one place.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 13.5,
            height: 1.7,
            color: _navy.withOpacity(0.58),
          ),
        ),

        const SizedBox(height: 24),

        _buildStatement(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Everyday convenience',
          description:
              'Handle everyday digital transactions and services from one familiar experience.',
        ),

        const SizedBox(height: 15),

        _buildStatement(
          icon: Icons.business_outlined,
          title: 'Built for people and businesses',
          description:
              'Support personal use while giving businesses access to useful digital workflows.',
        ),

        const SizedBox(height: 15),

        _buildStatement(
          icon: Icons.extension_outlined,
          title: 'An expanding ecosystem',
          description:
              'New services and integrations can become part of the wider GiftPay experience.',
        ),
      ],
    );
  }

  // ===========================================================================
  // STATEMENT
  // ===========================================================================

  Widget _buildStatement({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_blue.withOpacity(0.13), _highlight.withOpacity(0.07)],
            ),
            border: Border.all(color: _blue.withOpacity(0.10)),
          ),
          child: Icon(icon, size: 19, color: _blue),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                description,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 11.5,
                  height: 1.45,
                  color: _navy.withOpacity(0.48),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // ECOSYSTEM VISUAL
  // ===========================================================================

  Widget _buildEcosystemVisual() {
    return AspectRatio(
      aspectRatio: 1.08,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.95,
            colors: [
              _blue.withOpacity(0.13),
              _softBlue.withOpacity(0.40),
              Colors.white.withOpacity(0.18),
            ],
          ),
          border: Border.all(color: _blue.withOpacity(0.075)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Large orbit.
            _orbit(size: 250, opacity: 0.10),

            // Medium orbit.
            _orbit(size: 178, opacity: 0.13),

            // Small orbit.
            _orbit(size: 118, opacity: 0.16),

            // Subtle radial glow.
            Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _blue.withOpacity(0.12),
                    blurRadius: 65,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),

            // Center GiftPay node.
            Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_blue, _navy],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.75),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _blue.withOpacity(0.28),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 39,
                color: Colors.white,
              ),
            ),

            // Top-left.
            _floatingIcon(
              icon: Icons.payments_outlined,
              label: 'Payments',
              alignment: const Alignment(-0.78, -0.54),
            ),

            // Top-right.
            _floatingIcon(
              icon: Icons.flight_takeoff_rounded,
              label: 'Travel',
              alignment: const Alignment(0.78, -0.54),
            ),

            // Bottom-left.
            _floatingIcon(
              icon: Icons.storefront_outlined,
              label: 'Shopping',
              alignment: const Alignment(-0.78, 0.54),
            ),

            // Bottom-right.
            _floatingIcon(
              icon: Icons.bolt_outlined,
              label: 'Utilities',
              alignment: const Alignment(0.78, 0.54),
            ),

            // Left middle.
            _floatingIcon(
              icon: Icons.directions_car_filled_outlined,
              label: 'Mobility',
              alignment: const Alignment(-0.94, 0.0),
              compact: true,
            ),

            // Right middle.
            _floatingIcon(
              icon: Icons.business_center_outlined,
              label: 'Business',
              alignment: const Alignment(0.94, 0.0),
              compact: true,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ORBIT
  // ===========================================================================

  Widget _orbit({required double size, required double opacity}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _blue.withOpacity(opacity), width: 1),
      ),
    );
  }

  // ===========================================================================
  // FLOATING ECOSYSTEM ICON
  // ===========================================================================

  Widget _floatingIcon({
    required IconData icon,
    required String label,
    required Alignment alignment,
    bool compact = false,
  }) {
    final double size = compact ? 42 : 48;

    return Align(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(compact ? 13 : 15),
              color: Colors.white.withOpacity(0.78),
              border: Border.all(color: Colors.white.withOpacity(0.95)),
              boxShadow: [
                BoxShadow(
                  color: _blue.withOpacity(0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, size: compact ? 18 : 20, color: _blue),
          ),

          const SizedBox(height: 5),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.62),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: compact ? 7 : 7.5,
                fontWeight: FontWeight.w700,
                color: _navy.withOpacity(0.62),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // VALUE GRID
  // ===========================================================================

  Widget _buildValueGrid({required bool isMobile, required bool isTablet}) {
    final items = [
      const _WhyItem(
        icon: Icons.layers_outlined,
        eyebrow: 'CONNECTED',
        title: 'More than a payment screen.',
        description:
            'GiftPay is designed as a broader digital-services platform, connecting payments with the services people use around them.',
      ),
      const _WhyItem(
        icon: Icons.devices_outlined,
        eyebrow: 'ONE EXPERIENCE',
        title: 'Designed to feel simple.',
        description:
            'Different services can live inside a familiar GiftPay experience instead of forcing users to navigate unrelated platforms.',
      ),
      const _WhyItem(
        icon: Icons.storefront_outlined,
        eyebrow: 'BUSINESS READY',
        title: 'Useful beyond consumers.',
        description:
            'Businesses can use the ecosystem for transactions, utilities, digital services, and operational workflows.',
      ),
      const _WhyItem(
        icon: Icons.flight_takeoff_outlined,
        eyebrow: 'EXPANDING',
        title: 'Built to grow with integrations.',
        description:
            'Travel, ride booking, commerce, utilities, and other services can be connected as the GiftPay ecosystem expands.',
      ),
    ];

    final int columns = isMobile
        ? 1
        : isTablet
        ? 2
        : 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - 16) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: items.map((item) {
            return SizedBox(
              width: cardWidth,
              height: isMobile ? 180 : 190,
              child: _ValueCard(item: item),
            );
          }).toList(),
        );
      },
    );
  }

  // ===========================================================================
  // SECTION LABEL
  // ===========================================================================

  Widget _sectionLabel(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _highlight,
          ),
        ),

        const SizedBox(width: 9),

        Text(
          text,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: _blue,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // MINI LABEL
  // ===========================================================================

  Widget _miniLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'SegoeUI',
        fontSize: 8.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.8,
        color: _blue,
      ),
    );
  }
}

// ============================================================================
// WHY ITEM MODEL
// ============================================================================

class _WhyItem {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;

  const _WhyItem({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
  });
}

// ============================================================================
// VALUE CARD
// ============================================================================

class _ValueCard extends StatefulWidget {
  final _WhyItem item;

  const _ValueCard({required this.item});

  @override
  State<_ValueCard> createState() => _ValueCardState();
}

class _ValueCardState extends State<_ValueCard> {
  bool _hovered = false;

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) {
        if (mounted) {
          setState(() {
            _hovered = true;
          });
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() {
            _hovered = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -5 : 0, 0),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _hovered
                ? [Colors.white, Colors.white.withOpacity(0.90)]
                : [
                    Colors.white.withOpacity(0.84),
                    Colors.white.withOpacity(0.64),
                  ],
          ),
          border: Border.all(
            color: _hovered
                ? _highlight.withOpacity(0.28)
                : _navy.withOpacity(0.065),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: _blue.withOpacity(0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ]
              : [
                  BoxShadow(
                    color: _navy.withOpacity(0.045),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------------------------------
            // TOP ROW
            // -----------------------------------------------------------------
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _blue.withOpacity(_hovered ? 0.16 : 0.10),
                        _highlight.withOpacity(_hovered ? 0.10 : 0.055),
                      ],
                    ),
                    border: Border.all(
                      color: _highlight.withOpacity(_hovered ? 0.20 : 0.10),
                    ),
                  ),
                  child: Icon(widget.item.icon, size: 19, color: _blue),
                ),

                const Spacer(),

                Text(
                  widget.item.eyebrow,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: _blue.withOpacity(0.56),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // -----------------------------------------------------------------
            // TITLE
            // -----------------------------------------------------------------
            Text(
              widget.item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 16,
                height: 1.15,
                fontWeight: FontWeight.w800,
                color: _navy,
              ),
            ),

            const SizedBox(height: 7),

            // -----------------------------------------------------------------
            // DESCRIPTION
            // -----------------------------------------------------------------
            Text(
              widget.item.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 11.5,
                height: 1.5,
                color: _navy.withOpacity(0.48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
