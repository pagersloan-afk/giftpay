import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class BusinessHeroSection extends StatefulWidget {
  const BusinessHeroSection({super.key});

  @override
  State<BusinessHeroSection> createState() => _BusinessHeroSectionState();
}

class _BusinessHeroSectionState extends State<BusinessHeroSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double _hoverScale = 1.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 700;
    final isTablet = width >= 700 && width < 1100;

    final heroHeight = isMobile
        ? 600.0
        : isTablet
        ? 500.0
        : 560.0;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.045), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
            ),
        child: MouseRegion(
          onEnter: (_) {
            if (!isMobile) {
              setState(() => _hoverScale = 1.008);
            }
          },
          onExit: (_) {
            if (!isMobile) {
              setState(() => _hoverScale = 1.0);
            }
          },
          child: AnimatedScale(
            scale: _hoverScale,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: Container(
              width: double.infinity,
              height: heroHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isMobile ? 20 : 28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF273D68).withOpacity(0.16),
                    blurRadius: 40,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    "assets/illustrations/business_hero_bg.png",
                    fit: BoxFit.cover,
                  ),

                  // Dark cinematic overlay.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color(0xFF172744).withOpacity(0.90),
                          const Color(0xFF273D68).withOpacity(0.58),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.48, 1.0],
                      ),
                    ),
                  ),

                  // Bottom fade.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0x33000000), Colors.transparent],
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 22 : 54,
                      vertical: isMobile ? 28 : 48,
                    ),
                    child: Align(
                      alignment: isMobile
                          ? Alignment.bottomCenter
                          : Alignment.centerLeft,
                      child: _HeroContent(isMobile: isMobile),
                    ),
                  ),

                  // Top status pill.
                  Positioned(
                    top: isMobile ? 18 : 26,
                    left: isMobile ? 18 : 30,
                    child: _HeroPill(
                      icon: Icons.business_rounded,
                      text: "GIFT PAY BUSINESS",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final bool isMobile;

  const _HeroContent({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isMobile ? 390 : 570),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 22 : 34),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.20)),
            ),
            child: Column(
              crossAxisAlignment: isMobile
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  "GiftPay for Business",
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontWeight: FontWeight.w800,
                    fontSize: isMobile ? 30 : 46,
                    height: 1.08,
                    letterSpacing: -1.0,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  "Power your business with smarter utility management.",
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: isMobile ? 16 : 20,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: Colors.white.withOpacity(0.94),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Automate bulk electricity tokens, airtime distribution, and corporate data plans from one secure dashboard.",
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: isMobile ? 13.5 : 15.5,
                    height: 1.55,
                    color: Colors.white.withOpacity(0.76),
                  ),
                ),

                const SizedBox(height: 26),

                Wrap(
                  alignment: isMobile
                      ? WrapAlignment.center
                      : WrapAlignment.start,
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _HeroFeature(icon: Icons.bolt_rounded, label: "Fast"),
                    _HeroFeature(icon: Icons.shield_rounded, label: "Secure"),
                    _HeroFeature(
                      icon: Icons.auto_awesome_rounded,
                      label: "Automated",
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: isMobile ? double.infinity : null,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/contact');
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text("Explore Business Solutions"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GiftPayTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: GiftPayTheme.primaryBlue.withOpacity(0.35),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20 : 26,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(
                        fontFamily: 'SegoeUI',
                        fontSize: isMobile ? 14 : 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeroPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.13),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 15),
              const SizedBox(width: 7),
              Text(
                text,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroFeature extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroFeature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
