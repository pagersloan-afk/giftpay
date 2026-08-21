import 'package:flutter/material.dart';

// Shared GiftPay landing chrome
import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';

// Responsive landing layout
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

// GiftPay API sections
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/giftpay_api/giftpay_api_hero_section.dart';
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/giftpay_api/giftpay_api_features_section.dart';
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/giftpay_api/giftpay_api_cta_section.dart';

class GiftPayApiPage extends StatelessWidget {
  const GiftPayApiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: const LandingHeader(),
      body: LandingResponsiveLayout(
        child: Column(
          children: [
            const AnimatedSection(child: GiftPayApiHeroSection()),
            const SizedBox(height: 28),

            const AnimatedSection(child: GiftPayApiFeaturesSection()),
            const SizedBox(height: 28),

            const AnimatedSection(child: GiftPayApiCTASection()),
            const SizedBox(height: 48),

            const LandingFooter(),
          ],
        ),
      ),
    );
  }
}

/// Lightweight entrance animation shared by the API page sections.
class AnimatedSection extends StatefulWidget {
  final Widget child;

  const AnimatedSection({super.key, required this.child});

  @override
  State<AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<AnimatedSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
