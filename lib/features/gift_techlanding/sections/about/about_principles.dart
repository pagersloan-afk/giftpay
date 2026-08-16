import 'package:flutter/material.dart';

import 'about_shared.dart';

class AboutPrinciples extends StatelessWidget {
  const AboutPrinciples({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 700;

    if (isMobile) {
      return const Column(
        children: [
          AboutPrincipleCard(
            icon: Icons.public_rounded,
            eyebrow: '01',
            title: 'Built for Africa',
            description:
                'We design around the realities of African consumers, businesses, communities, and digital markets.',
          ),

          SizedBox(height: 16),

          AboutPrincipleCard(
            icon: Icons.security_rounded,
            eyebrow: '02',
            title: 'Trust by design',
            description:
                'Security, reliability, privacy, and responsible technology are considered from the foundation.',
          ),

          SizedBox(height: 16),

          AboutPrincipleCard(
            icon: Icons.auto_graph_rounded,
            eyebrow: '03',
            title: 'Designed to scale',
            description:
                'Our infrastructure is designed to evolve from emerging products into platforms serving millions.',
          ),
        ],
      );
    }

    return const Row(
      // IMPORTANT:
      // Use START instead of STRETCH.
      //
      // This prevents Flutter from attempting to give the
      // cards an infinite height inside the page's
      // SingleChildScrollView.
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AboutPrincipleCard(
            icon: Icons.public_rounded,
            eyebrow: '01',
            title: 'Built for Africa',
            description:
                'We design around the realities of African consumers, businesses, communities, and digital markets.',
          ),
        ),

        SizedBox(width: 24),

        Expanded(
          child: AboutPrincipleCard(
            icon: Icons.security_rounded,
            eyebrow: '02',
            title: 'Trust by design',
            description:
                'Security, reliability, privacy, and responsible technology are considered from the foundation.',
          ),
        ),

        SizedBox(width: 24),

        Expanded(
          child: AboutPrincipleCard(
            icon: Icons.auto_graph_rounded,
            eyebrow: '03',
            title: 'Designed to scale',
            description:
                'Our infrastructure is designed to evolve from emerging products into platforms serving millions.',
          ),
        ),
      ],
    );
  }
}

class AboutPrincipleCard extends StatelessWidget {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;

  const AboutPrincipleCard({
    super.key,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return AboutLuxuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AboutColors.highlight.withOpacity(0.20),
                      AboutColors.blue.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Icon(icon, size: 20, color: AboutColors.highlight),
              ),

              Text(
                eyebrow,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: Colors.white.withOpacity(0.22),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 21,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            description,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 13,
              height: 1.65,
              color: Colors.white.withOpacity(0.38),
            ),
          ),
        ],
      ),
    );
  }
}
