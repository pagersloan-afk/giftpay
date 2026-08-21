import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

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

  late final AnimationController _ambientController;

  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;

    if ((offset - _scrollOffset).abs() > 1) {
      setState(() {
        _scrollOffset = offset;
      });
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();

    _ambientController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final parallax = (_scrollOffset / 1000).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const LandingHeader(),
      body: AnimatedBuilder(
        animation: _ambientController,
        builder: (context, child) {
          final t = _ambientController.value;

          return Stack(
            children: [
              Positioned.fill(
                child: _AboutBackground(animationValue: t, parallax: parallax),
              ),

              Positioned.fill(
                child: IgnorePointer(
                  child: _AmbientParticles(animationValue: t),
                ),
              ),

              LandingResponsiveLayout(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: isMobile ? 20 : 34),

                      const HeroMarqueeSection(),

                      SizedBox(height: isMobile ? 30 : 56),

                      const _SectionIntro(
                        eyebrow: 'WHO WE ARE',
                        title: 'Building technology around everyday life',
                        description:
                            'GiftPay combines secure digital payments, practical financial tools, and technology designed to make everyday transactions simpler for people and businesses.',
                      ),

                      SizedBox(height: isMobile ? 20 : 30),

                      const ThreeCardSection(),

                      SizedBox(height: isMobile ? 34 : 60),

                      const CareerPromoSection(),

                      SizedBox(height: isMobile ? 34 : 60),

                      const _SectionIntro(
                        eyebrow: 'THE GIFT EXPERIENCE',
                        title: 'More than a payment platform',
                        description:
                            'From security and customer stories to product news and responsible practices, explore the ideas and people shaping the GiftPay experience.',
                      ),

                      SizedBox(height: isMobile ? 20 : 30),

                      const AdditionalCardsSection(),

                      SizedBox(height: isMobile ? 34 : 60),

                      const HistorySection(),

                      SizedBox(height: isMobile ? 34 : 60),

                      const LandingFooter(),
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

class _SectionIntro extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;

  const _SectionIntro({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            Text(
              eyebrow,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
                color: const Color(0xFF4A6BB8),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isMobile ? 25 : 34,
                fontWeight: FontWeight.w800,
                height: 1.12,
                color: const Color(0xFF17243D),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isMobile ? 14 : 16,
                height: 1.65,
                color: const Color(0xFF536174),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutBackground extends StatelessWidget {
  final double animationValue;
  final double parallax;

  const _AboutBackground({
    required this.animationValue,
    required this.parallax,
  });

  @override
  Widget build(BuildContext context) {
    final shift = math.sin(animationValue * math.pi * 2);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1 + (parallax * 0.35), -1),
          end: Alignment(1, 1 - (parallax * 0.25)),
          colors: const [
            Color(0xFFF7F9FD),
            Color(0xFFEFF3FA),
            Color(0xFFF9FAFC),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _AboutGlowPainter(shift: shift, parallax: parallax),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _AboutGlowPainter extends CustomPainter {
  final double shift;
  final double parallax;

  const _AboutGlowPainter({required this.shift, required this.parallax});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 75);

    paint.color = const Color(0xFF4A6BB8).withOpacity(0.12);

    canvas.drawCircle(
      Offset(
        size.width * (0.15 + (shift * 0.025)),
        size.height * (0.15 + parallax * 0.08),
      ),
      170,
      paint,
    );

    paint.color = const Color(0xFF273D68).withOpacity(0.08);

    canvas.drawCircle(
      Offset(size.width * (0.88 - (shift * 0.025)), size.height * 0.72),
      210,
      paint,
    );

    paint.color = const Color(0xFF4A6BB8).withOpacity(0.06);

    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.48),
      250,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _AboutGlowPainter oldDelegate) {
    return oldDelegate.shift != shift || oldDelegate.parallax != parallax;
  }
}

class _AmbientParticles extends StatelessWidget {
  final double animationValue;

  const _AmbientParticles({required this.animationValue});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(animationValue),
      child: const SizedBox.expand(),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double t;

  const _ParticlePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < 22; i++) {
      final progress = (t + i * 0.047) % 1.0;

      final x = size.width * (0.04 + ((i * 0.137) % 0.92));

      final y = size.height * ((progress * 0.9) + 0.05);

      final opacity = 0.08 + ((math.sin(progress * math.pi * 2) + 1) * 0.06);

      paint.color = const Color(0xFF4A6BB8).withOpacity(opacity);

      canvas.drawCircle(Offset(x, y), i.isEven ? 1.5 : 2.1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
