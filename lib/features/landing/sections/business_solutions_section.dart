import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

/// GiftPay Business Solutions Section
///
/// Designed to work correctly both:
/// - As a standalone responsive section
/// - Inside the FinancialBusinessShowcaseRow carousel
///
/// Important:
/// This widget uses LayoutBuilder/constraints as its source of truth.
/// It does NOT use the full screen width to determine its internal layout.
/// This prevents horizontal overflow when the widget is placed inside
/// a narrower carousel card.
class BusinessSolutionsSection extends StatefulWidget {
  const BusinessSolutionsSection({super.key});

  @override
  State<BusinessSolutionsSection> createState() =>
      _BusinessSolutionsSectionState();
}

class _BusinessSolutionsSectionState extends State<BusinessSolutionsSection> {
  bool _hovered = false;

  // ===========================================================================
  // THEME
  // ===========================================================================

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);
  static const Color _surface = Color(0xFFF6F8FC);

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        // ---------------------------------------------------------------------
        // IMPORTANT:
        // The widget's AVAILABLE WIDTH is the source of truth.
        //
        // When this widget is inside the carousel, width may be around
        // 500–650px even though the browser itself is 1400px+ wide.
        // ---------------------------------------------------------------------

        final bool isNarrow = width < 620;
        final bool isMobile = width < 700;
        final bool isCompact = width < 900;

        return MouseRegion(
          cursor: SystemMouseCursors.basic,
          onEnter: (_) {
            if (!mounted) return;

            setState(() {
              _hovered = true;
            });
          },
          onExit: (_) {
            if (!mounted) return;

            setState(() {
              _hovered = false;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isNarrow ? 22 : 30),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, _surface, _blue.withOpacity(.035)],
              ),
              border: Border.all(
                color: _navy.withOpacity(_hovered ? .10 : .065),
              ),
              boxShadow: [
                BoxShadow(
                  color: _navy.withOpacity(_hovered ? .075 : .045),
                  blurRadius: _hovered ? 40 : 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isNarrow ? 22 : 30),
              child: Stack(
                children: [
                  // ===========================================================
                  // BACKGROUND GLOW
                  // ===========================================================
                  Positioned(
                    top: -110,
                    right: -110,
                    child: IgnorePointer(
                      child: Container(
                        width: isNarrow ? 230 : 330,
                        height: isNarrow ? 230 : 330,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _blue.withOpacity(.10),
                              _blue.withOpacity(.025),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -120,
                    left: -110,
                    child: IgnorePointer(
                      child: Container(
                        width: isNarrow ? 230 : 330,
                        height: isNarrow ? 230 : 330,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _lightBlue.withOpacity(.07),
                              _lightBlue.withOpacity(.018),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ===========================================================
                  // CONTENT
                  // ===========================================================
                  Padding(
                    padding: EdgeInsets.all(
                      isNarrow
                          ? 16
                          : isCompact
                          ? 20
                          : 30,
                    ),
                    child: isMobile
                        ? _buildMobileLayout(isCompact: isCompact)
                        : _buildDesktopLayout(
                            isCompact: isCompact,
                            isNarrow: isNarrow,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // DESKTOP / TABLET
  // ===========================================================================

  Widget _buildDesktopLayout({
    required bool isCompact,
    required bool isNarrow,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ---------------------------------------------------------------------
        // IMAGE
        // ---------------------------------------------------------------------
        Expanded(
          flex: isCompact ? 8 : 10,
          child: _buildImagePanel(isMobile: false, isCompact: isCompact),
        ),

        SizedBox(width: isCompact ? 18 : 34),

        // ---------------------------------------------------------------------
        // CONTENT
        // ---------------------------------------------------------------------
        Expanded(
          flex: isCompact ? 10 : 9,
          child: _buildContent(isMobile: false, isCompact: isCompact),
        ),
      ],
    );
  }

  // ===========================================================================
  // MOBILE
  // ===========================================================================

  Widget _buildMobileLayout({required bool isCompact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildImagePanel(isMobile: true, isCompact: true),

        const SizedBox(height: 18),

        _buildContent(isMobile: true, isCompact: true),
      ],
    );
  }

  // ===========================================================================
  // IMAGE PANEL
  // ===========================================================================

  Widget _buildImagePanel({required bool isMobile, required bool isCompact}) {
    final double imageHeight = isMobile
        ? 165
        : isCompact
        ? 235
        : 330;

    return AnimatedScale(
      scale: _hovered ? 1.012 : 1,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: Container(
        width: double.infinity,
        height: imageHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMobile ? 18 : 24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(.94),
              _blue.withOpacity(.045),
              _lightBlue.withOpacity(.025),
            ],
          ),
          border: Border.all(color: _blue.withOpacity(.10)),
          boxShadow: [
            BoxShadow(
              color: _blue.withOpacity(.055),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isMobile ? 18 : 24),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ---------------------------------------------------------------
              // IMAGE BACKGROUND GLOW
              // ---------------------------------------------------------------
              Positioned(
                top: -55,
                right: -55,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _blue.withOpacity(.055),
                  ),
                ),
              ),

              Positioned(
                bottom: -65,
                left: -55,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _lightBlue.withOpacity(.035),
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              // TOP LABEL
              // ---------------------------------------------------------------
              Positioned(
                top: isMobile ? 11 : 14,
                left: isMobile ? 11 : 14,
                child: _buildImageBadge(
                  icon: Icons.business_center_rounded,
                  label: 'BUSINESS',
                  compact: isCompact,
                ),
              ),

              // ---------------------------------------------------------------
              // PRODUCT IMAGE
              // ---------------------------------------------------------------
              Padding(
                padding: EdgeInsets.only(
                  left: isMobile ? 12 : 16,
                  right: isMobile ? 12 : 16,
                  top: isMobile ? 30 : 36,
                  bottom: isMobile ? 30 : 36,
                ),
                child: Image.asset(
                  'assets/illustrations/business_solutions.png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImageFallback();
                  },
                ),
              ),

              // ---------------------------------------------------------------
              // BOTTOM STATUS
              // ---------------------------------------------------------------
              Positioned(
                bottom: isMobile ? 11 : 14,
                left: isMobile ? 11 : 14,
                child: _buildConnectedBadge(compact: isCompact),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // IMAGE BADGE
  // ===========================================================================

  Widget _buildImageBadge({
    required IconData icon,
    required String label,
    required bool compact,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.86),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.90)),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(.055),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 11 : 13, color: _blue),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: compact ? 6.5 : 8,
              fontWeight: FontWeight.w800,
              letterSpacing: compact ? .9 : 1.2,
              color: _blue,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CONNECTED BADGE
  // ===========================================================================

  Widget _buildConnectedBadge({required bool compact}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _navy.withOpacity(.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 5 : 6,
            height: compact ? 5 : 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF45B879),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'BUILT FOR BUSINESS',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: compact ? 6.2 : 7.5,
              fontWeight: FontWeight.w800,
              letterSpacing: compact ? .7 : 1.0,
              color: _navy.withOpacity(.50),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // IMAGE FALLBACK
  // ===========================================================================

  Widget _buildImageFallback() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _blue.withOpacity(.07),
            border: Border.all(color: _blue.withOpacity(.12)),
          ),
          child: const Icon(Icons.business_rounded, size: 27, color: _blue),
        ),
        const SizedBox(height: 10),
        Text(
          'Business Solutions',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _navy.withOpacity(.48),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // CONTENT
  // ===========================================================================

  Widget _buildContent({required bool isMobile, required bool isCompact}) {
    final double titleSize = isMobile
        ? 25
        : isCompact
        ? 29
        : 40;

    final double descriptionSize = isMobile
        ? 12.5
        : isCompact
        ? 13
        : 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ---------------------------------------------------------------------
        // SECTION LABEL
        // ---------------------------------------------------------------------
        _buildSectionLabel(compact: isCompact),

        SizedBox(
          height: isMobile
              ? 9
              : isCompact
              ? 10
              : 15,
        ),

        // ---------------------------------------------------------------------
        // TITLE
        // ---------------------------------------------------------------------
        Text(
          'GiftPay for Business',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: titleSize,
            height: 1.04,
            fontWeight: FontWeight.w800,
            letterSpacing: isCompact ? -.8 : -1.4,
            color: _navy,
          ),
        ),

        SizedBox(
          height: isMobile
              ? 10
              : isCompact
              ? 11
              : 15,
        ),

        // ---------------------------------------------------------------------
        // DESCRIPTION
        // ---------------------------------------------------------------------
        Text(
          'Simplify everyday business payments with a connected '
          'platform built for teams, organizations, and growing '
          'businesses.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: descriptionSize,
            height: isCompact ? 1.45 : 1.6,
            fontWeight: FontWeight.w400,
            color: _navy.withOpacity(.55),
          ),
        ),

        SizedBox(
          height: isMobile
              ? 15
              : isCompact
              ? 16
              : 22,
        ),

        // ---------------------------------------------------------------------
        // FEATURES
        // ---------------------------------------------------------------------
        _buildFeature(
          icon: Icons.bolt_rounded,
          title: 'Fast business payments',
          description:
              'Handle recurring and bulk payment needs from one place.',
          compact: isCompact,
        ),

        SizedBox(height: isCompact ? 8 : 12),

        _buildFeature(
          icon: Icons.groups_rounded,
          title: 'Built for teams',
          description:
              'Designed for organizations managing multiple users and needs.',
          compact: isCompact,
        ),

        SizedBox(height: isCompact ? 8 : 12),

        _buildFeature(
          icon: Icons.account_balance_wallet_rounded,
          title: 'One connected platform',
          description:
              'Keep essential business payment services together in one ecosystem.',
          compact: isCompact,
        ),

        SizedBox(
          height: isMobile
              ? 18
              : isCompact
              ? 18
              : 26,
        ),

        // ---------------------------------------------------------------------
        // BUTTON
        // ---------------------------------------------------------------------
        _buildActionButton(isMobile: isMobile, compact: isCompact),
      ],
    );
  }

  // ===========================================================================
  // SECTION LABEL
  // ===========================================================================

  Widget _buildSectionLabel({required bool compact}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 6 : 7,
          height: compact ? 6 : 7,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _lightBlue,
          ),
        ),
        SizedBox(width: compact ? 7 : 9),
        Text(
          'BUSINESS SOLUTIONS',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: compact ? 7 : 9,
            fontWeight: FontWeight.w800,
            letterSpacing: compact ? 1.3 : 2,
            color: _blue,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // FEATURE
  // ===========================================================================

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
    required bool compact,
  }) {
    final double iconSize = compact ? 31 : 38;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 9 : 12),
            color: _blue.withOpacity(.065),
            border: Border.all(color: _blue.withOpacity(.10)),
          ),
          child: Icon(icon, size: compact ? 15 : 18, color: _blue),
        ),

        SizedBox(width: compact ? 8 : 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: compact ? 11.5 : 13.5,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                description,
                maxLines: compact ? 2 : null,
                overflow: compact
                    ? TextOverflow.ellipsis
                    : TextOverflow.visible,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: compact ? 9.5 : 11.5,
                  height: compact ? 1.3 : 1.4,
                  fontWeight: FontWeight.w400,
                  color: _navy.withOpacity(.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // ACTION BUTTON
  // ===========================================================================

  Widget _buildActionButton({required bool isMobile, required bool compact}) {
    return SizedBox(
      width: isMobile ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.arrow_forward_rounded, size: compact ? 14 : 17),
        label: Text(
          'Explore Business Solutions',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontWeight: FontWeight.w700,
            fontSize: compact ? 11.5 : 13.5,
            letterSpacing: .1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: GiftPayTheme.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 15 : 24,
            vertical: compact ? 11 : 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(compact ? 10 : 12),
          ),
        ),
      ),
    );
  }
}
