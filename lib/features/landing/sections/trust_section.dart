import 'dart:ui';

import 'package:flutter/material.dart';

/// GiftPay Trust / Credibility Section.
///
/// Purpose:
/// - Establish confidence immediately after the Hero.
/// - Explain the areas users should feel confident about.
/// - Reinforce GiftPay as a product backed by Gift Technology Ltd.
/// - Avoid unsupported certifications, uptime percentages, or security claims.
///
/// This section is intentionally self-contained and does not control:
/// - page navigation
/// - scrolling
/// - routing
/// - the landing-page background
///
/// It is designed to sit directly after [HeroSection].
class TrustSection extends StatelessWidget {
  const TrustSection({super.key});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool isMobile = width < 700;
    final bool isTablet = width >= 700 && width < 1050;

    final double horizontalPadding = isMobile
        ? 20
        : isTablet
        ? 34
        : 64;

    final double verticalPadding = isMobile ? 68 : 92;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeading(isMobile),

              SizedBox(height: isMobile ? 30 : 42),

              _buildTrustPanel(context, isMobile: isMobile),

              SizedBox(height: isMobile ? 22 : 28),

              _buildCompanyStrip(isMobile: isMobile),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION HEADING
  // ===========================================================================

  Widget _buildHeading(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('WHY USERS CHOOSE GIFTPAY'),

        const SizedBox(height: 16),

        Text(
          'Built to make everyday digital transactions feel dependable.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: isMobile ? 31 : 48,
            height: 1.08,
            fontWeight: FontWeight.w800,
            letterSpacing: isMobile ? -1.1 : -2.0,
            color: _navy,
          ),
        ),

        const SizedBox(height: 12),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            'GiftPay brings everyday digital services together in one '
            'connected experience, backed by Gift Technology Ltd.',
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
  // TRUST PANEL
  // ===========================================================================

  Widget _buildTrustPanel(BuildContext context, {required bool isMobile}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isMobile ? 24 : 30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 18 : 26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMobile ? 24 : 30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.72),
                Colors.white.withOpacity(0.43),
                _blue.withOpacity(0.055),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.72)),
            boxShadow: [
              BoxShadow(
                color: _navy.withOpacity(0.07),
                blurRadius: 40,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double availableWidth = constraints.maxWidth;

              // -----------------------------------------------------------------
              // MOBILE
              // -----------------------------------------------------------------

              if (availableWidth < 700) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < _trustItems.length; i++) ...[
                      _TrustCard(item: _trustItems[i]),
                      if (i != _trustItems.length - 1)
                        const SizedBox(height: 12),
                    ],
                  ],
                );
              }

              // -----------------------------------------------------------------
              // TABLET
              //
              // Increased from 190 to 210 to prevent the card content from
              // touching/overflowing the bottom edge on certain widths.
              // -----------------------------------------------------------------

              if (availableWidth < 1050) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _trustItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 210,
                  ),
                  itemBuilder: (context, index) {
                    return _TrustCard(item: _trustItems[index]);
                  },
                );
              }

              // -----------------------------------------------------------------
              // DESKTOP
              //
              // Previously this was fixed at 190px.
              // The card content can require slightly more than that depending
              // on font rendering and text metrics. 210px gives the content
              // enough vertical breathing room without making the section tall.
              // -----------------------------------------------------------------

              return SizedBox(
                height: 210,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < _trustItems.length; i++) ...[
                      Expanded(child: _TrustCard(item: _trustItems[i])),
                      if (i != _trustItems.length - 1)
                        const SizedBox(width: 12),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // COMPANY CREDIBILITY STRIP
  // ===========================================================================

  Widget _buildCompanyStrip({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 17 : 22,
        vertical: isMobile ? 16 : 19,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _navy.withOpacity(0.045),
        border: Border.all(color: _navy.withOpacity(0.07)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _companyIdentity(),
                const SizedBox(height: 14),
                _companyMessage(),
              ],
            )
          : Row(
              children: [
                Expanded(child: _companyIdentity()),
                const SizedBox(width: 30),
                Expanded(child: _companyMessage()),
              ],
            ),
    );
  }

  Widget _companyIdentity() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_blue.withOpacity(0.18), _highlight.withOpacity(0.08)],
            ),
            border: Border.all(color: _blue.withOpacity(0.10)),
          ),
          child: const Icon(Icons.business_rounded, size: 20, color: _blue),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BACKED BY GIFT TECHNOLOGY LTD',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.45,
                  color: _blue.withOpacity(0.70),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'A connected technology ecosystem.',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _navy.withOpacity(0.82),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _companyMessage() {
    return Text(
      'GiftPay is part of the Gift Technology ecosystem, '
      'bringing payments and everyday digital services together '
      'through a single product experience.',
      style: TextStyle(
        fontFamily: 'SegoeUI',
        fontSize: 11.5,
        height: 1.55,
        color: _navy.withOpacity(0.52),
      ),
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
          width: 5,
          height: 5,
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
            letterSpacing: 1.9,
            color: _blue,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TRUST DATA
  // ===========================================================================

  static const List<_TrustItem> _trustItems = [
    _TrustItem(
      icon: Icons.shield_outlined,
      eyebrow: 'SECURITY',
      title: 'Your transactions matter.',
      description:
          'GiftPay is designed with security-conscious transaction flows '
          'and responsible handling of account activity at its core.',
    ),
    _TrustItem(
      icon: Icons.sync_rounded,
      eyebrow: 'RELIABILITY',
      title: 'Built for everyday use.',
      description:
          'From payments and transfers to utilities and digital services, '
          'GiftPay brings frequently used transactions into one experience.',
    ),
    _TrustItem(
      icon: Icons.support_agent_rounded,
      eyebrow: 'SUPPORT',
      title: 'Help when you need it.',
      description:
          'GiftPay provides support channels for users who need assistance '
          'with their account, transactions, or digital services.',
    ),
    _TrustItem(
      icon: Icons.apartment_rounded,
      eyebrow: 'COMPANY',
      title: 'Part of a wider ecosystem.',
      description:
          'GiftPay is developed within the Gift Technology ecosystem, '
          'connecting consumer and business-focused digital products.',
    ),
  ];
}

// ============================================================================
// TRUST DATA MODEL
// ============================================================================

class _TrustItem {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;

  const _TrustItem({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
  });
}

// ============================================================================
// TRUST CARD
// ============================================================================

class _TrustCard extends StatefulWidget {
  final _TrustItem item;

  const _TrustCard({required this.item});

  @override
  State<_TrustCard> createState() => _TrustCardState();
}

class _TrustCardState extends State<_TrustCard> {
  bool _hovered = false;

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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

        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),

          color: _hovered
              ? Colors.white.withOpacity(0.78)
              : Colors.white.withOpacity(0.48),

          border: Border.all(
            color: _hovered
                ? _highlight.withOpacity(0.20)
                : _navy.withOpacity(0.065),
          ),

          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: _blue.withOpacity(0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // -----------------------------------------------------------------
            // ICON
            // -----------------------------------------------------------------
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _blue.withOpacity(_hovered ? 0.17 : 0.10),
                    _highlight.withOpacity(_hovered ? 0.10 : 0.045),
                  ],
                ),
                border: Border.all(
                  color: _highlight.withOpacity(_hovered ? 0.20 : 0.10),
                ),
              ),
              child: Icon(widget.item.icon, size: 21, color: _blue),
            ),

            const SizedBox(height: 16),

            // -----------------------------------------------------------------
            // EYEBROW
            // -----------------------------------------------------------------
            Text(
              widget.item.eyebrow,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.55,
                color: _blue.withOpacity(0.66),
              ),
            ),

            const SizedBox(height: 6),

            // -----------------------------------------------------------------
            // TITLE
            // -----------------------------------------------------------------
            Text(
              widget.item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 15,
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
                fontSize: 10.8,
                height: 1.45,
                color: _navy.withOpacity(0.50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
