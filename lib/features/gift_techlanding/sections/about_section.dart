import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/features/landing/widgets/parent_overlay_card.dart';
import 'hero_section.dart'; // For AnimatedLiftCard reuse

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 40 : 80,
      ),
      child: ParentOverlayCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------------------
            // TITLE
            // ------------------------------------------------------------
            Text(
              "About Gift Technology Ltd",
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 26 : 34,
                fontWeight: FontWeight.w800,
                color: const Color.fromARGB(255, 20, 40, 80),
              ),
            ),

            const SizedBox(height: 20),

            // ------------------------------------------------------------
            // DESCRIPTION
            // ------------------------------------------------------------
            Text(
              "Gift Technology Ltd is a Nigerian multinational technology company headquartered in Port Harcourt, Rivers. "
              "We build secure digital platforms that power payments, utilities, e‑voting, entertainment, and business operations "
              "for millions of users across Africa.",
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 15 : 17,
                height: 1.6,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 40),

            // ------------------------------------------------------------
            // CORE VALUES — LUXURY FINTECH CARDS (Horizontal Scroll)
            // ------------------------------------------------------------
            SizedBox(
              height: isMobile ? 260 : 300, // enough height for cards
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _valueCard(
                      icon: Icons.security,
                      title: "Security First",
                      text:
                          "Every product we build is protected with enterprise‑grade security, encryption, and compliance.",
                    ),
                    const SizedBox(width: 24),

                    _valueCard(
                      icon: Icons.public,
                      title: "Built for Africa",
                      text:
                          "Our platforms are designed to solve real problems across payments, utilities, and digital services.",
                    ),
                    const SizedBox(width: 24),

                    _valueCard(
                      icon: Icons.auto_graph,
                      title: "Scalable Technology",
                      text:
                          "We engineer systems that scale seamlessly from thousands to millions of users.",
                    ),
                    const SizedBox(width: 24),

                    _valueCard(
                      icon: Icons.lightbulb,
                      title: "Innovation Driven",
                      text:
                          "We create modern digital experiences that empower individuals, businesses, and communities.",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ VALUE CARD (Luxury Fintech Style)
  Widget _valueCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return AnimatedLiftCard(
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.30), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: GiftPayTheme.primaryBlue),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
