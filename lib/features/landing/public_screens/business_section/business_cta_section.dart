import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class BusinessCTASection extends StatefulWidget {
  const BusinessCTASection({super.key});

  @override
  State<BusinessCTASection> createState() => _BusinessCTASectionState();
}

class _BusinessCTASectionState extends State<BusinessCTASection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _hovered = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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

    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
        child: MouseRegion(
          onEnter: (_) {
            if (!isMobile) {
              setState(() => _hovered = true);
            }
          },
          onExit: (_) {
            if (!isMobile) {
              setState(() => _hovered = false);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1180),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 24 : 30),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF273D68,
                  ).withOpacity(_hovered ? 0.20 : 0.13),
                  blurRadius: _hovered ? 40 : 30,
                  offset: Offset(0, _hovered ? 18 : 12),
                ),
              ],
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF172744),
                  Color(0xFF273D68),
                  Color(0xFF4A6BB8),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -80,
                  top: -100,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                ),

                Positioned(
                  left: -100,
                  bottom: -120,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.045),
                    ),
                  ),
                ),

                ClipRRect(
                  borderRadius: BorderRadius.circular(isMobile ? 24 : 30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 22 : 70,
                        vertical: isMobile ? 34 : 54,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.16),
                              ),
                            ),
                            child: const Text(
                              "LET'S BUILD SOMETHING BETTER",
                              style: TextStyle(
                                fontFamily: 'SegoeUI',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          Text(
                            "Let’s power your business with automation",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'SegoeUI',
                              fontWeight: FontWeight.w800,
                              fontSize: isMobile ? 26 : 38,
                              height: 1.12,
                              letterSpacing: -0.7,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 14),

                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 670),
                            child: Text(
                              "Speak with a GiftPay Business specialist to explore tailored automation solutions for your organization.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'SegoeUI',
                                fontSize: isMobile ? 13 : 15,
                                color: Colors.white.withOpacity(0.76),
                                height: 1.55,
                              ),
                            ),
                          ),

                          const SizedBox(height: 26),

                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: const [
                              _CTAFeature(
                                icon: Icons.bolt_rounded,
                                label: "Fast setup",
                              ),
                              _CTAFeature(
                                icon: Icons.security_rounded,
                                label: "Secure",
                              ),
                              _CTAFeature(
                                icon: Icons.support_agent_rounded,
                                label: "Business support",
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          SizedBox(
                            width: isMobile ? double.infinity : null,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/contact');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: GiftPayTheme.primaryBlue,
                                elevation: 8,
                                shadowColor: Colors.black.withOpacity(0.18),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Talk to GiftPay",
                                    style: TextStyle(
                                      fontFamily: 'SegoeUI',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 17),
                                ],
                              ),
                            ),
                          ),
                        ],
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

class _CTAFeature extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CTAFeature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.13)),
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
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
