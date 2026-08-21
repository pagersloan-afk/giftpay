import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

// Shared Landing Header + Footer
import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';

// Business Sections
import 'package:utilityhub/features/landing/public_screens/business_section/business_cta_section.dart';
import 'package:utilityhub/features/landing/public_screens/business_section/business_hero_section.dart';
import 'package:utilityhub/features/landing/public_screens/business_section/business_insight_section.dart';
import 'package:utilityhub/features/landing/public_screens/business_section/business_production_section.dart';
import 'package:utilityhub/features/landing/public_screens/business_section/business_resource_section.dart';

// Landing Responsive Layout
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

class BusinessPage extends StatefulWidget {
  const BusinessPage({super.key});

  @override
  State<BusinessPage> createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late final AnimationController _animController;

  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;

    // Avoid unnecessary rebuilds for tiny scroll changes.
    if ((offset - _scrollOffset).abs() < 2) return;

    setState(() {
      _scrollOffset = offset;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double parallaxShift = (_scrollOffset / (size.height * 1.2)).clamp(
      0.0,
      1.0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: const LandingHeader(),
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final t = _animController.value;

          return Stack(
            children: [
              // ------------------------------------------------------------
              // GLOBAL BUSINESS BACKGROUND
              // ------------------------------------------------------------
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1 + parallaxShift * 0.35, -1),
                      end: Alignment(1, 1 - parallaxShift * 0.25),
                      colors: const [
                        Color(0xFFF7F9FD),
                        Color(0xFFEEF3FA),
                        Color(0xFFF9FBFE),
                      ],
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------------------
              // SOFT LIGHT / GLOW
              // ------------------------------------------------------------
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _BusinessGlowPainter(
                      shift: t,
                      scrollShift: parallaxShift,
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------------------
              // FLOATING PARTICLES
              // ------------------------------------------------------------
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _BusinessParticlesPainter(t)),
                ),
              ),

              // ------------------------------------------------------------
              // CONTENT
              // ------------------------------------------------------------
              LandingResponsiveLayout(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: const [
                      SizedBox(height: 24),

                      BusinessHeroSection(),

                      SizedBox(height: 64),

                      BusinessProductsSection(),

                      SizedBox(height: 64),

                      BusinessInsightsSection(),

                      SizedBox(height: 64),

                      BusinessResourcesSection(),

                      SizedBox(height: 64),

                      BusinessCTASection(),

                      SizedBox(height: 56),

                      LandingFooter(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// BUSINESS GLOW PAINTER
// ============================================================================

class _BusinessGlowPainter extends CustomPainter {
  final double shift;
  final double scrollShift;

  const _BusinessGlowPainter({required this.shift, required this.scrollShift});

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = 0.5 + (0.5 * math.sin(shift * 2 * math.pi));

    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);

    // Top-left blue glow.
    paint.color = const Color(0xFF4A6BB8).withOpacity(0.10 + (pulse * 0.07));

    canvas.drawCircle(
      Offset(size.width * (0.12 + scrollShift * 0.04), size.height * 0.12),
      210,
      paint,
    );

    // Center-right glow.
    paint.color = const Color(0xFF7D9BDD).withOpacity(0.07 + (pulse * 0.05));

    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * (0.38 + scrollShift * 0.08)),
      180,
      paint,
    );

    // Bottom navy glow.
    paint.color = const Color(0xFF273D68).withOpacity(0.06 + (pulse * 0.04));

    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.92),
      230,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BusinessGlowPainter oldDelegate) {
    return oldDelegate.shift != shift || oldDelegate.scrollShift != scrollShift;
  }
}

// ============================================================================
// BUSINESS PARTICLES
// ============================================================================

class _BusinessParticlesPainter extends CustomPainter {
  final double t;

  const _BusinessParticlesPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < 22; i++) {
      final progress = (t + (i * 0.047)) % 1.0;

      final x = size.width * (0.04 + (0.92 * ((i * 0.37) % 1.0)));

      final y = size.height * (0.08 + (0.84 * progress));

      final radius = 1.2 + ((i % 3) * 0.65);

      final opacity = 0.08 + ((i % 4) * 0.025);

      paint.color = Colors.white.withOpacity(opacity);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BusinessParticlesPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
