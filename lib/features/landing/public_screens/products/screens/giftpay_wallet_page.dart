import 'package:flutter/material.dart';

// Shared GiftPay public-site components
import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

// GiftPay Wallet sections
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/giftpay_wallet/giftpay_wallet_hero_section.dart';
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/giftpay_wallet/giftpay_wallet_features_section.dart';
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/giftpay_wallet/giftpay_wallet_cta_section.dart';

class GiftPayWalletPage extends StatelessWidget {
  const GiftPayWalletPage({super.key});

  static const Color _background = Color(0xFFF7F9FD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: const LandingHeader(),
      body: LandingResponsiveLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AnimatedSection(child: GiftPayWalletHeroSection()),
            const SizedBox(height: 32),

            const AnimatedSection(child: GiftPayWalletFeaturesSection()),
            const SizedBox(height: 32),

            const AnimatedSection(child: GiftPayWalletCTASection()),
            const SizedBox(height: 48),

            const LandingFooter(),
          ],
        ),
      ),
    );
  }
}

/// Lightweight entrance animation used by GiftPay public product pages.
///
/// This widget intentionally does not depend on viewport visibility or
/// nested scroll controllers, making it safe inside the existing
/// LandingResponsiveLayout.
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

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);

    _slide = Tween<Offset>(
      begin: const Offset(0.0, 0.035),
      end: Offset.zero,
    ).animate(curvedAnimation);

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
