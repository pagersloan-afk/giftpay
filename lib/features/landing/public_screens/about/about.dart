import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

// ⭐ Shared Landing Header + Footer
import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';

// ⭐ Landing Responsive Layout
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

// ⭐ GiftPay About Sections
import 'package:utilityhub/features/landing/public_screens/about/section/section_1.dart';
import 'package:utilityhub/features/landing/public_screens/about/section/section_2.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
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
            // ⭐ Multi-layer animated gradient + glow + particles
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + parallaxShift, -1),
                end: Alignment(1, 1 - parallaxShift),
                colors: [
                  const Color(0xFF273D68).withOpacity(0.95), // GiftPay navy
                  const Color(0xFF4A6BB8).withOpacity(0.85), // soft blue
                  const Color(0xFFF9F9F9).withOpacity(0.95), // light gray
                ],
              ),
            ),

            child: Stack(
              children: [
                // ⭐ Soft glow pulses
                _buildGlowLayer(t),

                // ⭐ Floating particles
                _buildParticlesLayer(t),

                // ⭐ Main content (unchanged)
                LandingResponsiveLayout(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: const [
                        SizedBox(height: 40),

                        HeroMarqueeSection(),
                        SizedBox(height: 40),

                        ThreeCardSection(),
                        SizedBox(height: 40),

                        CareerPromoSection(),
                        SizedBox(height: 40),

                        AdditionalCardsSection(),
                        SizedBox(height: 40),

                        HistorySection(),
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

  // ⭐ Soft glow pulses layer
  Widget _buildGlowLayer(double t) {
    final double glowShift = (0.5 + 0.5 * math.sin(2 * math.pi * t));

    return IgnorePointer(
      child: CustomPaint(
        painter: _GlowPainter(glowShift),
        child: const SizedBox.expand(),
      ),
    );
  }

  // ⭐ Floating particles layer
  Widget _buildParticlesLayer(double t) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlesPainter(t),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ⭐ Glow painter (soft luxury blobs)
class _GlowPainter extends CustomPainter {
  final double shift;
  _GlowPainter(this.shift);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    // Top-left glow
    paint.color = const Color(0xFF4A6BB8).withOpacity(0.25);
    canvas.drawCircle(
      Offset(size.width * (0.2 + 0.1 * shift), size.height * 0.2),
      140,
      paint,
    );

    // Bottom-right glow
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

// ⭐ Particles painter (floating dots)
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
