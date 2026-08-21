import 'dart:math' as math;

import 'package:flutter/material.dart';

// ============================================================================
// GIFT PAY LANDING
// ============================================================================
//
// This file is intentionally kept as the landing-page ORCHESTRATOR.
//
// The individual sections remain responsible for their own:
// - UI
// - responsive behavior
// - animations
// - cards
// - CTAs
// - product visuals
//
// Landing flow:
//
// 1. Hero
// 2. Trust / Credibility
// 3. What You Can Do With GiftPay
// 4. Product Showcase
// 5. Lifestyle / Rewards
// 6. Business Solutions
// 7. Pricing
// 8. Why GiftPay
// 9. Final CTA
// 10. Footer
//
// ============================================================================

// ⭐ LANDING HEADER + FOOTER
import 'widgets/landing_header.dart';
import 'sections/landing_footer.dart';

// ⭐ RESPONSIVE LAYOUT
import 'widgets/landing_responsive_layout.dart';

// ⭐ EXISTING SECTIONS
import 'sections/hero_section.dart';
import 'sections/feature_cards_section.dart';
import 'sections/financial_business_showcase_row.dart';
import 'sections/app_showcase_section.dart';
import 'sections/lifestyle_benefits_section.dart';
import 'sections/pricing_section.dart';
import 'sections/product_showcase_section.dart';

// ⭐ EXISTING SHARED CARD
import 'widgets/parent_overlay_card.dart';

// ============================================================================
// NEW SECTIONS
// ============================================================================
//
// These files will be created/upgraded in the next implementation step.
//
// Expected files:
//
// sections/trust_section.dart
// sections/business_solutions_section.dart
// sections/why_giftpay_section.dart
// sections/final_cta_section.dart
//
// ============================================================================

import 'sections/trust_section.dart';
import 'sections/business_solutions_section.dart';
import 'sections/why_giftpay_section.dart';
import 'sections/final_cta_section.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  // ==========================================================================
  // CONTROLLERS
  // ==========================================================================

  final ScrollController _scrollController = ScrollController();

  late final AnimationController _animController;

  // ==========================================================================
  // SCROLL / PARALLAX STATE
  // ==========================================================================

  double _scrollOffset = 0;

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  void _handleScroll() {
    if (!mounted) return;

    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();

    _animController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final double parallaxShift = (_scrollOffset / 800).clamp(0.0, 1.0);

    final bool isMobile = screenWidth < 700;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const LandingHeader(),

      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final double t = _animController.value;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + parallaxShift, -1),
                end: Alignment(1, 1 - parallaxShift),
                colors: const [
                  Color(0xFFF9FBFF),
                  Color(0xFFEFF4FF),
                  Color(0xFFF8FAFD),
                ],
              ),
            ),

            child: Stack(
              children: [
                // ============================================================
                // BACKGROUND EFFECTS
                // ============================================================
                _buildGlowLayer(t),

                _buildParticlesLayer(t),

                // ============================================================
                // MAIN LANDING CONTENT
                // ============================================================
                LandingResponsiveLayout(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: isMobile ? 24 : 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: const [
                        // ====================================================
                        // 1. HERO
                        // ====================================================
                        //
                        // What GiftPay is
                        // Primary CTA
                        // Secondary CTA
                        // Strong product visual
                        //
                        HeroSection(),

                        // ====================================================
                        // 2. TRUST / CREDIBILITY
                        // ====================================================
                        //
                        // Security
                        // Reliability
                        // Support
                        // Business/company credibility
                        //
                        ParentOverlayCard(child: TrustSection()),

                        // ====================================================
                        // 3. WHAT YOU CAN DO WITH GIFTPAY
                        // ====================================================
                        //
                        // Wallet
                        // Transfers
                        // Airtime & Data
                        // Electricity
                        // Gift Cards
                        // Other supported services
                        //
                        ParentOverlayCard(child: FeatureCardsSection()),

                        // ====================================================
                        // 4. PRODUCT SHOWCASE
                        // ====================================================
                        //
                        // Existing animated product visuals remain here.
                        //
                        ParentOverlayCard(child: ProductShowcaseSection()),

                        // ====================================================
                        // 5. LIFESTYLE / REWARDS
                        // ====================================================
                        //
                        // Rewards
                        // Travel
                        // Shopping
                        // Benefits ecosystem
                        //
                        ParentOverlayCard(child: LifestyleBenefitsSection()),

                        // ====================================================
                        // 6. BUSINESS SOLUTIONS
                        // ====================================================
                        //
                        // Merchant value
                        // Bulk transactions
                        // Utility automation
                        // Business support
                        //
                        ParentOverlayCard(child: BusinessSolutionsSection()),

                        // ====================================================
                        // Existing financial/business visual section.
                        //
                        // This is retained as supporting business/financial
                        // content and can be upgraded during the section pass.
                        // ====================================================
                        ParentOverlayCard(
                          child: FinancialBusinessShowcaseRow(),
                        ),

                        // ====================================================
                        // Existing app showcase.
                        //
                        // Retained because it provides product/interface
                        // visual proof and supports the conversion journey.
                        // ====================================================
                        ParentOverlayCard(child: AppShowcaseSection()),

                        // ====================================================
                        // 7. PRICING
                        // ====================================================
                        //
                        // Existing ₦ pricing section.
                        // Clear fees.
                        // No confusing pricing language.
                        //
                        ParentOverlayCard(child: PricingSection()),

                        // ====================================================
                        // 8. WHY GIFTPAY
                        // ====================================================
                        //
                        // Concise differentiation.
                        // Why consumers and businesses choose GiftPay.
                        //
                        ParentOverlayCard(child: WhyGiftPaySection()),

                        // ====================================================
                        // 9. FINAL CTA
                        // ====================================================
                        //
                        // Strong conversion section.
                        // Get started with GiftPay.
                        //
                        ParentOverlayCard(child: FinalCtaSection()),

                        // ====================================================
                        // 10. FOOTER
                        // ====================================================
                        //
                        // Products
                        // Business
                        // Company
                        // Resources
                        // Support
                        // Legal
                        //
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

  // ==========================================================================
  // BACKGROUND — SOFT GLOW
  // ==========================================================================

  Widget _buildGlowLayer(double t) {
    final double glowShift = 0.5 + 0.5 * math.sin(2 * math.pi * t);

    return IgnorePointer(
      child: CustomPaint(
        painter: _GlowPainter(glowShift),
        child: const SizedBox.expand(),
      ),
    );
  }

  // ==========================================================================
  // BACKGROUND — FLOATING PARTICLES
  // ==========================================================================

  Widget _buildParticlesLayer(double t) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlesPainter(t),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ============================================================================
// GLOW PAINTER
// ============================================================================

class _GlowPainter extends CustomPainter {
  final double shift;

  _GlowPainter(this.shift);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    // ------------------------------------------------------------------------
    // Top-left soft blue glow
    // ------------------------------------------------------------------------

    paint.color = const Color(0xFF4A6BB8).withOpacity(0.10);

    canvas.drawCircle(
      Offset(size.width * (0.18 + 0.08 * shift), size.height * 0.12),
      150,
      paint,
    );

    // ------------------------------------------------------------------------
    // Mid-right blue glow
    // ------------------------------------------------------------------------

    paint.color = const Color(0xFF75A1FF).withOpacity(0.075);

    canvas.drawCircle(
      Offset(size.width * (0.82 - 0.08 * shift), size.height * 0.48),
      170,
      paint,
    );

    // ------------------------------------------------------------------------
    // Bottom-right navy glow
    // ------------------------------------------------------------------------

    paint.color = const Color(0xFF273D68).withOpacity(0.08);

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.86),
      190,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) {
    return oldDelegate.shift != shift;
  }
}

// ============================================================================
// PARTICLES PAINTER
// ============================================================================

class _ParticlesPainter extends CustomPainter {
  final double t;

  _ParticlesPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final paint = Paint()..color = const Color(0xFF4A6BB8).withOpacity(0.12);

    for (int i = 0; i < 18; i++) {
      final double progress = (t + i * 0.055) % 1.0;

      final double x = size.width * (0.06 + 0.88 * (i / 18));

      final double y = size.height * (0.05 + 0.90 * progress);

      final double radius = 1.1 + (i % 3) * 0.55;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
