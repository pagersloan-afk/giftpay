import 'package:flutter/material.dart';

// ⭐ Shared Landing Header + Footer
import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';

// ⭐ Landing Responsive Layout
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

// ⭐ Modular Sections
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/bulk_electricity/bulk_hero_section.dart';
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/bulk_electricity/bulk_features_section.dart';
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/bulk_electricity/bulk_cta_section.dart';

class BulkElectricityPage extends StatelessWidget {
  const BulkElectricityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const LandingHeader(),

      // ⭐ Luxury Animated Wrapper
      body: LandingResponsiveLayout(
        child: Column(
          children: [
            // ⭐ Hero Section with Fade + Parallax
            const AnimatedSection(child: BulkHeroSection()),
            const SizedBox(height: 40),

            // ⭐ Features Section with Glow Pulse
            const AnimatedSection(child: BulkFeaturesSection()),
            const SizedBox(height: 40),

            // ⭐ CTA Section with Slide-Up Animation
            const AnimatedSection(child: BulkCTASection()),
            const SizedBox(height: 40),

            // ⭐ Footer (no animation)
            const LandingFooter(),
          ],
        ),
      ),
    );
  }
}

// ⭐ Reusable Animated Wrapper (Luxury Feel)
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

    // ⭐ Smooth fade + slide animation
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

    // ⭐ Trigger animation when widget is built
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
          // ⭐ Luxury Glow Pulse Background
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
