import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

import 'package:utilityhub/features/landing/public_screens/giftcards/section/giftcards_hero.dart';
import 'package:utilityhub/features/landing/public_screens/giftcards/section/giftcards_categories.dart';
import 'package:utilityhub/features/landing/public_screens/giftcards/section/giftcards_featured_brands.dart';
import 'package:utilityhub/features/landing/public_screens/giftcards/section/giftcards_faq.dart';

class GiftCardsPage extends StatefulWidget {
  const GiftCardsPage({super.key});

  @override
  State<GiftCardsPage> createState() => _GiftCardsPageState();
}

class _GiftCardsPageState extends State<GiftCardsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: const LandingHeader(),
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _GiftCardsBackgroundPainter(
                      _backgroundController.value,
                    ),
                  ),
                ),
              ),
              LandingResponsiveLayout(
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    const GiftCardsHeroSection(),

                    const SizedBox(height: 32),

                    const GiftCardsCategoriesSection(),

                    const SizedBox(height: 32),

                    const GiftCardsFeaturedBrandsSection(),

                    const SizedBox(height: 32),

                    const GiftCardsFAQSection(),

                    const SizedBox(height: 40),

                    const LandingFooter(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GiftCardsBackgroundPainter extends CustomPainter {
  final double progress;

  const _GiftCardsBackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final double wave = math.sin(progress * math.pi * 2);

    final paintOne = Paint()
      ..color = const Color(0xFF4A6BB8).withOpacity(0.055)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);

    final paintTwo = Paint()
      ..color = const Color(0xFF273D68).withOpacity(0.045)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    canvas.drawCircle(
      Offset(size.width * (0.12 + wave * 0.025), size.height * 0.12),
      150,
      paintOne,
    );

    canvas.drawCircle(
      Offset(size.width * (0.88 - wave * 0.025), size.height * 0.70),
      190,
      paintTwo,
    );
  }

  @override
  bool shouldRepaint(covariant _GiftCardsBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
