import 'package:flutter/material.dart';

import 'gifttech_dedicated_page_template.dart';

class GiftTechAboutScreen extends StatelessWidget {
  const GiftTechAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechDedicatedPageTemplate(
      title: 'About Gift Technology',
      eyebrow: 'ABOUT THE COMPANY',
      icon: Icons.business_center_rounded,
      description:
          'Gift Technology Ltd is a digital infrastructure company building practical, secure, and accessible technology for everyday digital life across Africa.',
      metaLabel: 'COMPANY',
      metaValue: 'Gift Technology Ltd',
      secondaryMetaLabel: 'HEADQUARTERS',
      secondaryMetaValue: 'Port Harcourt, Nigeria',
      child: const _AboutContent(),
    );
  }
}

class _AboutContent extends StatelessWidget {
  const _AboutContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _GlassSection(
            eyebrow: '01 / MISSION',
            title: 'Technology designed around real life.',
            description:
                'Gift Technology focuses on building digital products that simplify payments, utilities, commerce, business operations, and access to essential digital services.',
            icon: Icons.auto_awesome_rounded,
          ),
          const SizedBox(height: 18),
          _GlassSection(
            eyebrow: '02 / VISION',
            title: 'A stronger digital future for Africa.',
            description:
                'Our vision is to contribute to a connected African digital economy where individuals, businesses, developers, and communities can access reliable technology through simple and secure experiences.',
            icon: Icons.visibility_outlined,
          ),
          const SizedBox(height: 18),
          _GlassSection(
            eyebrow: '03 / OUR APPROACH',
            title: 'Infrastructure first. Experience always.',
            description:
                'We combine digital infrastructure, payment technology, utility services, business tools, and platform experiences into products designed to be useful, scalable, and dependable.',
            icon: Icons.account_tree_outlined,
          ),
        ],
      ),
    );
  }
}

class _GlassSection extends StatelessWidget {
  const _GlassSection({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 720;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(mobile ? 24 : 34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white.withOpacity(0.035),
        border: Border.all(color: Colors.white.withOpacity(0.075)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF4A6BB8).withOpacity(0.13),
              border: Border.all(
                color: const Color(0xFF75A1FF).withOpacity(0.12),
              ),
            ),
            child: Icon(icon, color: const Color(0xFF75A1FF), size: 22),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                    color: Color(0xFF75A1FF),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: mobile ? 20 : 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: mobile ? 13 : 14,
                    height: 1.7,
                    color: Colors.white.withOpacity(0.53),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
