import 'package:flutter/material.dart';

// Shared GiftPay landing shell
import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

// Business Dashboard sections
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/business_dashboard/business_dashboard_hero_section.dart';
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/business_dashboard/business_dashboard_features_section.dart';
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/business_dashboard/business_dashboard_cta_section.dart';

class BusinessDashboardPage extends StatelessWidget {
  const BusinessDashboardPage({super.key});

  static const Color background = Color(0xFFF7F9FC);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: background,
      appBar: LandingHeader(),
      body: LandingResponsiveLayout(child: _BusinessDashboardContent()),
    );
  }
}

class _BusinessDashboardContent extends StatelessWidget {
  const _BusinessDashboardContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        AnimatedSection(child: BusinessDashboardHeroSection()),

        SizedBox(height: 56),

        AnimatedSection(child: BusinessDashboardFeaturesSection()),

        SizedBox(height: 56),

        AnimatedSection(child: BusinessDashboardCTASection()),

        SizedBox(height: 56),

        LandingFooter(),
      ],
    );
  }
}

///
/// Reusable entrance animation used by public GiftPay product pages.
///

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
      begin: const Offset(0, 0.045),
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
