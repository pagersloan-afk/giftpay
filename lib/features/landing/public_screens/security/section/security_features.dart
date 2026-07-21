import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class SecurityFeaturesSection extends StatefulWidget {
  const SecurityFeaturesSection({super.key});

  @override
  State<SecurityFeaturesSection> createState() =>
      _SecurityFeaturesSectionState();
}

class _SecurityFeaturesSectionState extends State<SecurityFeaturesSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> fadeIn;
  late Animation<double> slideUp;

  double hoverScale = 1.0;
  double parallaxOffset = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    slideUp = Tween<double>(
      begin: 40,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: fadeIn.value,
          child: Transform.translate(
            offset: Offset(0, slideUp.value),
            child: MouseRegion(
              onEnter: (_) {
                if (!isMobile) setState(() => hoverScale = 1.03);
              },
              onExit: (_) {
                if (!isMobile) setState(() => hoverScale = 1.0);
              },
              onHover: (event) {
                if (!isMobile) {
                  setState(() {
                    parallaxOffset = (event.localPosition.dx - 150) / 40;
                  });
                }
              },
              child: AnimatedScale(
                scale: hoverScale,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF273D68).withOpacity(0.95),
                        const Color(0xFF4A6BB8).withOpacity(0.85),
                        const Color(0xFFF9F9F9).withOpacity(0.90),
                      ],
                    ),
                  ),
                  child: isMobile
                      ? Column(
                          children: [
                            _featureImage(),
                            const SizedBox(height: 16),
                            _featureContent(isMobile),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(flex: 1, child: _featureImage()),
                            const SizedBox(width: 24),
                            Expanded(flex: 1, child: _featureContent(isMobile)),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _featureImage() {
    return Transform.translate(
      offset: Offset(parallaxOffset, 0),
      child: Image.asset(
        "assets/images/security-features.png",
        width: double.infinity,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _featureContent(bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          "Advanced Protection Features",
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 18 : 22,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Multi‑factor authentication, biometric verification, secure sessions, device‑level protection, and continuous monitoring.",
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isMobile ? 13 : 14,
            color: Colors.white.withOpacity(0.85),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/security/features');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: GiftPayTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 24,
              vertical: isMobile ? 10 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            "Learn More",
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
