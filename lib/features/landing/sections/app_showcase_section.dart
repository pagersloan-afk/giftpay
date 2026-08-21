import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class AppShowcaseSection extends StatefulWidget {
  const AppShowcaseSection({super.key});

  @override
  State<AppShowcaseSection> createState() => _AppShowcaseSectionState();
}

class _AppShowcaseSectionState extends State<AppShowcaseSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bgShift;

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF75A1FF);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _bgShift = Tween<double>(
      begin: -1,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool isMobile = screenWidth < 700;
    final bool isTablet = screenWidth >= 700 && screenWidth < 1050;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile
              ? 16
              : isTablet
              ? 28
              : 54,
          vertical: isMobile ? 34 : 58,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isMobile ? 26 : 34),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const [
                      Color(0xFFF8FAFF),
                      Color(0xFFF1F5FC),
                      Color(0xFFEAF0FB),
                    ],
                  ),
                  border: Border.all(color: _navy.withOpacity(0.065)),
                  boxShadow: [
                    BoxShadow(
                      color: _navy.withOpacity(0.045),
                      blurRadius: 34,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // =========================================================
                    // AMBIENT BACKGROUND GLOWS
                    // =========================================================
                    Positioned(
                      top: -170,
                      right: -110,
                      child: IgnorePointer(
                        child: _GlowOrb(size: 390, color: _blue, opacity: 0.12),
                      ),
                    ),

                    Positioned(
                      bottom: -180,
                      left: -130,
                      child: IgnorePointer(
                        child: _GlowOrb(
                          size: 420,
                          color: _lightBlue,
                          opacity: 0.09,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 100,
                      left: -150,
                      child: IgnorePointer(
                        child: _GlowOrb(
                          size: 280,
                          color: _blue,
                          opacity: 0.045,
                        ),
                      ),
                    ),

                    // =========================================================
                    // SUBTLE MOVING LIGHT
                    // =========================================================
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _ShowcaseGlowPainter(
                            progress: _bgShift.value,
                          ),
                        ),
                      ),
                    ),

                    // =========================================================
                    // CONTENT
                    // =========================================================
                    Padding(
                      padding: EdgeInsets.all(
                        isMobile
                            ? 20
                            : isTablet
                            ? 28
                            : 36,
                      ),
                      child: _ShowcaseContent(
                        isMobile: isMobile,
                        isTablet: isTablet,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SHOWCASE CONTENT
// ============================================================================

class _ShowcaseContent extends StatefulWidget {
  final bool isMobile;
  final bool isTablet;

  const _ShowcaseContent({required this.isMobile, required this.isTablet});

  @override
  State<_ShowcaseContent> createState() => _ShowcaseContentState();
}

class _ShowcaseContentState extends State<_ShowcaseContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;

  bool _hovered = false;

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF75A1FF);

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMobile) {
      return _buildMobile();
    }

    return _buildDesktop();
  }

  // ==========================================================================
  // DESKTOP / TABLET
  // ==========================================================================

  Widget _buildDesktop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 6, child: _buildCopy()),

        SizedBox(width: widget.isTablet ? 26 : 46),

        Expanded(flex: 4, child: _buildVisualPanel()),
      ],
    );
  }

  // ==========================================================================
  // MOBILE
  // ==========================================================================

  Widget _buildMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildCopy(), const SizedBox(height: 26), _buildVisualPanel()],
    );
  }

  // ==========================================================================
  // COPY
  // ==========================================================================

  Widget _buildCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Eyebrow
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _lightBlue,
              ),
            ),
            const SizedBox(width: 9),
            const Text(
              'EVERYTHING IN ONE PLACE',
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
                color: _blue,
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // Main title
        Text(
          'Digital tools built\nfor everyday ease.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: widget.isMobile
                ? 31
                : widget.isTablet
                ? 38
                : 46,
            height: 1.05,
            fontWeight: FontWeight.w800,
            letterSpacing: widget.isMobile ? -1.0 : -1.8,
            color: _navy,
          ),
        ),

        const SizedBox(height: 14),

        // Description
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            'Track utilities, manage rewards, receive instant '
            'notifications, and automate payments — all from '
            'one beautifully simple GiftPay experience.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: widget.isMobile ? 14 : 16,
              height: 1.65,
              fontWeight: FontWeight.w400,
              color: _navy.withOpacity(0.55),
            ),
          ),
        ),

        const SizedBox(height: 22),

        // Feature chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _FeatureChip(icon: Icons.bolt_rounded, label: 'Instant'),
            _FeatureChip(icon: Icons.security_rounded, label: 'Secure'),
            _FeatureChip(icon: Icons.auto_awesome_rounded, label: 'Simple'),
          ],
        ),

        const SizedBox(height: 28),

        // CTA
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) {
            if (!mounted) return;
            setState(() => _hovered = true);
            _hoverController.forward();
          },
          onExit: (_) {
            if (!mounted) return;
            setState(() => _hovered = false);
            _hoverController.reverse();
          },
          child: AnimatedBuilder(
            animation: _hoverController,
            builder: (context, child) {
              final double scale = 1.0 + (_hoverController.value * 0.025);

              return Transform.scale(
                scale: scale,
                alignment: Alignment.centerLeft,
                child: child,
              );
            },
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {},
                child: Ink(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isMobile ? 20 : 24,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_blue, _navy],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                    boxShadow: [
                      BoxShadow(
                        color: _blue.withOpacity(_hovered ? 0.26 : 0.16),
                        blurRadius: _hovered ? 24 : 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Explore GiftPay',
                        style: TextStyle(
                          fontFamily: 'SegoeUI',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 180),
                        offset: _hovered ? const Offset(0.12, 0) : Offset.zero,
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 17,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // VISUAL PANEL
  // ==========================================================================

  Widget _buildVisualPanel() {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) {
        if (!mounted) return;
        setState(() => _hovered = true);
      },
      onExit: (_) {
        if (!mounted) return;
        setState(() => _hovered = false);
      },
      child: AnimatedScale(
        scale: _hovered ? 1.015 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: Container(
          constraints: BoxConstraints(minHeight: widget.isMobile ? 240 : 300),
          padding: EdgeInsets.all(widget.isMobile ? 18 : 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.isMobile ? 21 : 25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_navy, _blue, const Color(0xFF3659A8)],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(_hovered ? 0.28 : 0.16),
            ),
            boxShadow: [
              BoxShadow(
                color: _navy.withOpacity(_hovered ? 0.20 : 0.13),
                blurRadius: _hovered ? 32 : 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Decorative glow
              Positioned(
                top: -80,
                right: -70,
                child: IgnorePointer(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _lightBlue.withOpacity(0.30),
                          _lightBlue.withOpacity(0.04),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white.withOpacity(0.13),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.20),
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GiftPay',
                              style: TextStyle(
                                fontFamily: 'SegoeUI',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Your everyday utility hub',
                              style: TextStyle(
                                fontFamily: 'SegoeUI',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF8DE0A7),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Text(
                    'Everything you need,\nright at your fingertips.',
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: widget.isMobile ? 19 : 23,
                      height: 1.12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Utility mini cards
                  Row(
                    children: [
                      Expanded(
                        child: _MiniUtilityCard(
                          icon: Icons.bolt_rounded,
                          label: 'Utilities',
                          value: 'Instant',
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _MiniUtilityCard(
                          icon: Icons.card_giftcard_rounded,
                          label: 'Rewards',
                          value: 'Ready',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 9),

                  Row(
                    children: [
                      Expanded(
                        child: _MiniUtilityCard(
                          icon: Icons.notifications_active_rounded,
                          label: 'Alerts',
                          value: 'Live',
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _MiniUtilityCard(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'Wallet',
                          value: 'Secure',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.10),
                  ),

                  const SizedBox(height: 13),

                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _lightBlue,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const Text(
                        'BUILT FOR EVERYDAY LIFE',
                        style: TextStyle(
                          fontFamily: 'SegoeUI',
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.35,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// FEATURE CHIP
// ============================================================================

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _blue.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _blue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MINI UTILITY CARD
// ============================================================================

class _MiniUtilityCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniUtilityCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.095),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: Colors.white.withOpacity(0.10),
            ),
            child: Icon(icon, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 8.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// GLOW ORB
// ============================================================================

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(opacity),
            color.withOpacity(opacity * 0.25),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SUBTLE ANIMATED LIGHT PAINTER
// ============================================================================

class _ShowcaseGlowPainter extends CustomPainter {
  final double progress;

  const _ShowcaseGlowPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    final double x = size.width * (0.35 + (progress * 0.18));

    final double y = size.height * (0.25 + math.sin(progress * math.pi) * 0.12);

    final Rect rect = Rect.fromCircle(
      center: Offset(x, y),
      radius: size.width * 0.32,
    );

    paint.shader = RadialGradient(
      colors: [const Color(0xFF75A1FF).withOpacity(0.035), Colors.transparent],
    ).createShader(rect);

    canvas.drawCircle(Offset(x, y), size.width * 0.32, paint);
  }

  @override
  bool shouldRepaint(covariant _ShowcaseGlowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
