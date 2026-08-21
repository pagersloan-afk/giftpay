import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

// Shared Landing Header + Footer
import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';

// Responsive Layout
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

// Sections
import 'package:utilityhub/features/landing/public_screens/rewards/section/rewards_hero.dart';
import 'package:utilityhub/features/landing/public_screens/rewards/section/rewards_benefits.dart';
import 'package:utilityhub/features/landing/public_screens/rewards/section/rewards_tiers.dart';
import 'package:utilityhub/features/landing/public_screens/rewards/section/rewards_faq.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late final AnimationController _animationController;

  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;

    // Avoid rebuilding the entire page for insignificant scroll changes.
    if ((offset - _scrollOffset).abs() < 1) return;

    setState(() {
      _scrollOffset = offset;
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();

    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final parallax = (_scrollOffset / 900).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF273D68),
      appBar: const LandingHeader(),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final t = _animationController.value;

            return Stack(
              fit: StackFit.expand,
              children: [
                // ---------------------------------------------------------
                // PREMIUM BACKGROUND
                // ---------------------------------------------------------
                _buildBackground(size: size, t: t, parallax: parallax),

                // ---------------------------------------------------------
                // CONTENT
                // ---------------------------------------------------------
                LandingResponsiveLayout(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: const [
                        SizedBox(height: 32),

                        RewardsHeroSection(),

                        SizedBox(height: 56),

                        RewardsBenefitsSection(),

                        SizedBox(height: 56),

                        RewardsTiersSection(),

                        SizedBox(height: 56),

                        RewardsFAQSection(),

                        SizedBox(height: 56),

                        LandingFooter(),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // ---------------------------------------------------------
                // SUBTLE TOP / BOTTOM VIGNETTE
                // ---------------------------------------------------------
                IgnorePointer(child: _VignetteOverlay()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackground({
    required Size size,
    required double t,
    required double parallax,
  }) {
    final wave = math.sin(t * math.pi * 2);
    final wave2 = math.sin((t * math.pi * 2) + 1.8);

    final topGlowX = 0.18 + (wave * 0.08);
    final topGlowY = 0.16 + (parallax * 0.04);

    final bottomGlowX = 0.82 + (wave2 * 0.07);
    final bottomGlowY = 0.82 - (parallax * 0.03);

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base background.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF172947),
                  Color(0xFF273D68),
                  Color(0xFF314C80),
                  Color(0xFF1A2B4A),
                ],
                stops: [0.0, 0.35, 0.68, 1.0],
              ),
            ),
          ),

          // Animated ambient glows.
          Positioned.fill(
            child: CustomPaint(
              painter: _RewardsAmbientPainter(
                topGlow: Offset(size.width * topGlowX, size.height * topGlowY),
                bottomGlow: Offset(
                  size.width * bottomGlowX,
                  size.height * bottomGlowY,
                ),
                pulse: 0.5 + (0.5 * wave),
              ),
            ),
          ),

          // Fine glass-like light wash.
          Positioned.fill(
            child: IgnorePointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0.2, sigmaY: 0.2),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.025),
                        Colors.transparent,
                        Colors.black.withOpacity(0.08),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Floating particles.
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _RewardsParticlesPainter(t: t, scrollOffset: parallax),
              ),
            ),
          ),

          // Very subtle horizontal light streaks.
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _RewardsStreakPainter(t: t)),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// AMBIENT GLOW
// ===========================================================================

class _RewardsAmbientPainter extends CustomPainter {
  final Offset topGlow;
  final Offset bottomGlow;
  final double pulse;

  const _RewardsAmbientPainter({
    required this.topGlow,
    required this.bottomGlow,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final topPaint = Paint()
      ..color = const Color(0xFF4A6BB8).withOpacity(0.20 + (pulse * 0.07))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);

    final bottomPaint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.07 + (pulse * 0.035))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 110);

    canvas.drawCircle(
      topGlow,
      math.min(size.width, size.height) * 0.25,
      topPaint,
    );

    canvas.drawCircle(
      bottomGlow,
      math.min(size.width, size.height) * 0.32,
      bottomPaint,
    );

    // Small central glow gives the page a more premium depth.
    final centerPaint = Paint()
      ..color = Colors.white.withOpacity(0.018)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);

    canvas.drawCircle(
      Offset(size.width * 0.52, size.height * 0.48),
      math.min(size.width, size.height) * 0.28,
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RewardsAmbientPainter oldDelegate) {
    return oldDelegate.topGlow != topGlow ||
        oldDelegate.bottomGlow != bottomGlow ||
        oldDelegate.pulse != pulse;
  }
}

// ===========================================================================
// FLOATING PARTICLES
// ===========================================================================

class _RewardsParticlesPainter extends CustomPainter {
  final double t;
  final double scrollOffset;

  const _RewardsParticlesPainter({required this.t, required this.scrollOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final particlePaint = Paint();

    for (int i = 0; i < 28; i++) {
      final seed = i * 0.6180339887;

      final xFactor = (seed * 1.73) % 1.0;

      final speed = 0.18 + ((i % 5) * 0.035);

      final progress = (t * speed + seed + (scrollOffset * 0.08)) % 1.0;

      final yFactor = (progress + (i * 0.031)) % 1.0;

      final x = size.width * (0.04 + (xFactor * 0.92));

      final y = size.height * (0.04 + (yFactor * 0.92));

      final radius = 0.7 + ((i % 4) * 0.45);

      final opacity = 0.08 + ((i % 6) * 0.025);

      particlePaint.color = Colors.white.withOpacity(opacity);

      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RewardsParticlesPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.scrollOffset != scrollOffset;
  }
}

// ===========================================================================
// LIGHT STREAKS
// ===========================================================================

class _RewardsStreakPainter extends CustomPainter {
  final double t;

  const _RewardsStreakPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 3; i++) {
      final phase = (t + (i * 0.33)) % 1.0;

      final y = size.height * (0.22 + (i * 0.28));

      final startX = size.width * (phase - 0.25);

      final endX = startX + size.width * 0.34;

      paint.color = Colors.white.withOpacity(0.018);

      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RewardsStreakPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}

// ===========================================================================
// VIGNETTE
// ===========================================================================

class _VignetteOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.08),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.10),
            ],
            stops: const [0.0, 0.18, 0.78, 1.0],
          ),
        ),
      ),
    );
  }
}
