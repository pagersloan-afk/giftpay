import 'package:flutter/material.dart';
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/airtime/airtime_cta_section.dart';
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/airtime/airtime_features_section.dart';
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/airtime/airtime_hero_section.dart';

// ⭐ Shared Landing Header + Footer
import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';

// ⭐ Landing Responsive Layout
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

class AirtimeDistributionPage extends StatelessWidget {
  const AirtimeDistributionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const LandingHeader(),

      body: LandingResponsiveLayout(
        child: Column(
          children: [
            const AnimatedSection(child: AirtimeHeroSection()),
            const SizedBox(height: 40),

            const AnimatedSection(child: AirtimeFeaturesSection()),
            const SizedBox(height: 40),

            const AnimatedSection(child: AirtimeCTASection()),
            const SizedBox(height: 40),

            const LandingFooter(),
          ],
        ),
      ),
    );
  }
}

// ⭐ Reusable Luxury Animation Wrapper
class AnimatedSection extends StatefulWidget {
  final Widget child;
  const AnimatedSection({super.key, required this.child});

  @override
  State<AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
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
      child: SlideTransition(
        position: _slide,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.06),
                blurRadius: 40,
                spreadRadius: 4,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
