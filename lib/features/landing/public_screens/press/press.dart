import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

// Shared Landing Header + Footer
import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';

// Responsive Layout
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

// Press Sections
import 'package:utilityhub/features/landing/public_screens/press/section/press_hero.dart';
import 'package:utilityhub/features/landing/public_screens/press/section/press_highlights.dart';
import 'package:utilityhub/features/landing/public_screens/press/section/press_news.dart';
import 'package:utilityhub/features/landing/public_screens/press/section/press_media_kit.dart';

class PressPage extends StatefulWidget {
  const PressPage({super.key});

  @override
  State<PressPage> createState() => _PressPageState();
}

class _PressPageState extends State<PressPage>
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + parallaxShift, -1),
                end: Alignment(1, 1 - parallaxShift),
                colors: [
                  const Color(0xFF273D68).withOpacity(0.95),
                  const Color(0xFF4A6BB8).withOpacity(0.85),
                  const Color(0xFFF9F9F9).withOpacity(0.95),
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
                        SizedBox(height: 40),

                        PressHeroSection(),
                        SizedBox(height: 40),

                        PressHighlightsSection(),
                        SizedBox(height: 40),

                        PressNewsSection(),
                        SizedBox(height: 40),

                        PressMediaKitSection(),
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

  Widget _buildGlowLayer(double t) {
    final double glowShift = (0.5 + 0.5 * math.sin(2 * math.pi * t));

    return IgnorePointer(
      child: CustomPaint(
        painter: _GlowPainter(glowShift),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildParticlesLayer(double t) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlesPainter(t),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  final double shift;
  _GlowPainter(this.shift);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    paint.color = const Color(0xFF4A6BB8).withOpacity(0.25);
    canvas.drawCircle(
      Offset(size.width * (0.2 + 0.1 * shift), size.height * 0.2),
      140,
      paint,
    );

    paint.color = const Color(0xFF273D68).withOpacity(0.22);
    canvas.drawCircle(
      Offset(size.width * (0.8 - 0.1 * shift), size.height * 0.85),
      180,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) =>
      oldDelegate.shift != shift;
}

class _ParticlesPainter extends CustomPainter {
  final double t;
  _ParticlesPainter(this.t);

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
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) =>
      oldDelegate.t != t;
}
