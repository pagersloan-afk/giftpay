import 'package:flutter/material.dart';

// Shared GiftPay public-site components.
import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

// Bulk electricity sections.
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/bulk_electricity/bulk_hero_section.dart';
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/bulk_electricity/bulk_features_section.dart';
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/bulk_electricity/bulk_cta_section.dart';

class BulkElectricityPage extends StatelessWidget {
  const BulkElectricityPage({super.key});

  static const Color navy = Color(0xFF273D68);
  static const Color pageBackground = Color(0xFFF7F9FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: const LandingHeader(),
      body: LandingResponsiveLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            BulkElectricityAnimatedSection(child: BulkHeroSection()),

            SizedBox(height: 28),

            BulkElectricityAnimatedSection(child: BulkFeaturesSection()),

            SizedBox(height: 28),

            BulkElectricityAnimatedSection(child: BulkCTASection()),

            SizedBox(height: 48),

            LandingFooter(),
          ],
        ),
      ),
    );
  }
}

/// Lightweight entrance animation used only by this page.
///
/// This is deliberately page-specific instead of being called
/// `AnimatedSection`, preventing duplicate class-name conflicts when
/// several public product pages are imported together.
class BulkElectricityAnimatedSection extends StatefulWidget {
  final Widget child;

  const BulkElectricityAnimatedSection({super.key, required this.child});

  @override
  State<BulkElectricityAnimatedSection> createState() =>
      _BulkElectricityAnimatedSectionState();
}

class _BulkElectricityAnimatedSectionState
    extends State<BulkElectricityAnimatedSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
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
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
