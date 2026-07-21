import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

// ⭐ Shared Landing Header + Footer
import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';

// ⭐ Business Sections
import 'package:utilityhub/features/landing/public_screens/business_section/business_cta_section.dart';
import 'package:utilityhub/features/landing/public_screens/business_section/business_hero_section.dart';
import 'package:utilityhub/features/landing/public_screens/business_section/business_insight_section.dart';
import 'package:utilityhub/features/landing/public_screens/business_section/business_production_section.dart';
import 'package:utilityhub/features/landing/public_screens/business_section/business_resource_section.dart';

// ⭐ Landing Responsive Layout
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

class BusinessPage extends StatefulWidget {
  const BusinessPage({super.key});

  @override
  State<BusinessPage> createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double parallaxShift = (_scrollOffset / 800).clamp(0, 1);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const LandingHeader(),

      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final t = _animController.value;

          return Container(
            // ⭐ Business screen gradient (slightly different palette)
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + parallaxShift, -1),
                end: Alignment(1, 1 - parallaxShift),
                colors: [
                  const Color(0xFF1F2D4A).withOpacity(0.95), // deeper navy
                  const Color(0xFF355A8A).withOpacity(0.85), // business blue
                  const Color(0xFFF5F7FA).withOpacity(0.95), // soft white-gray
                ],
              ),
            ),

            child: Stack(
              children: [
                _buildGlowLayer(t),
                _buildParticlesLayer(t),

                LandingResponsiveLayout(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: const [
                        BusinessHeroSection(),
                        SizedBox(height: 40),

                        BusinessProductsSection(),
                        SizedBox(height: 40),

                        BusinessInsightsSection(),
                        SizedBox(height: 40),

                        BusinessResourcesSection(),
                        SizedBox(height: 40),

                        BusinessCTASection(),
                        SizedBox(height: 40),

                        LandingFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ⭐ Glow layer (business tone)
  Widget _buildGlowLayer(double t) {
    final double glowShift = (0.5 + 0.5 * math.sin(2 * math.pi * t));

    return IgnorePointer(
      child: CustomPaint(
        painter: _BusinessGlowPainter(glowShift),
        child: const SizedBox.expand(),
      ),
    );
  }

  // ⭐ Particles layer
  Widget _buildParticlesLayer(double t) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _BusinessParticlesPainter(t),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ⭐ Glow painter (business variant)
class _BusinessGlowPainter extends CustomPainter {
  final double shift;
  _BusinessGlowPainter(this.shift);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    // Top-left glow (business blue)
    paint.color = const Color(0xFF355A8A).withOpacity(0.25);
    canvas.drawCircle(
      Offset(size.width * (0.22 + 0.1 * shift), size.height * 0.22),
      140,
      paint,
    );

    // Bottom-right glow (deep navy)
    paint.color = const Color(0xFF1F2D4A).withOpacity(0.22);
    canvas.drawCircle(
      Offset(size.width * (0.78 - 0.1 * shift), size.height * 0.85),
      180,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BusinessGlowPainter oldDelegate) =>
      oldDelegate.shift != shift;
}

// ⭐ Particles painter (same style)
class _BusinessParticlesPainter extends CustomPainter {
  final double t;
  _BusinessParticlesPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.35);

    for (int i = 0; i < 18; i++) {
      final double progress = (t + i * 0.05) % 1.0;
      final double x = size.width * (0.1 + 0.8 * (i / 18));
      final double y = size.height * (0.1 + 0.8 * progress);

      canvas.drawCircle(Offset(x, y), 2.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BusinessParticlesPainter oldDelegate) =>
      oldDelegate.t != t;
}
