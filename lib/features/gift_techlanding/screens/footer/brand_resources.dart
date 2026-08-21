import 'dart:ui';

import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class BrandResourcesScreen extends StatelessWidget {
  const BrandResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      title: 'Brand Resources',
      description:
          'The identity, principles, visual language, and resources that define Gift Technology Ltd.',
      eyebrow: 'GIFT TECHNOLOGY / BRAND',
      icon: Icons.auto_awesome_rounded,
      metaLabel: 'BRAND',
      metaValue: 'Identity & Resources',
      secondaryMetaLabel: 'PRIMARY BRAND',
      secondaryMetaValue: 'Gift Technology Ltd',
      child: const _BrandResourcesContent(),
    );
  }
}

class _BrandResourcesContent extends StatelessWidget {
  const _BrandResourcesContent();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 720;
    final horizontal = isMobile
        ? 20.0
        : width < 1100
        ? 34.0
        : 56.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BrandIdentityHero(),
          const SizedBox(height: 26),

          const _SectionHeading(
            eyebrow: 'WHAT WE STAND FOR',
            title: 'Technology with purpose.',
            description:
                'Gift Technology exists to build practical digital technology around real-world needs. Our products are designed to make services more accessible, connected, useful, and ready for scale.',
          ),
          const SizedBox(height: 16),
          _ValuesSection(isMobile: isMobile),

          const SizedBox(height: 30),

          const _SectionHeading(
            eyebrow: 'BRAND CHARACTER',
            title: 'How Gift Technology should feel.',
            description:
                'Our identity is modern and ambitious, but never complicated for the sake of complexity. Every interaction should communicate confidence, clarity, usefulness, and human purpose.',
          ),
          const SizedBox(height: 16),
          _BrandCharacterSection(isMobile: isMobile),

          const SizedBox(height: 30),

          const _SectionHeading(
            eyebrow: 'BRAND ARCHITECTURE',
            title: 'One technology company. A connected digital ecosystem.',
            description:
                'Gift Technology Ltd is the parent technology identity. Its products and platforms form a connected ecosystem serving consumers, businesses, developers, and organisations.',
          ),
          const SizedBox(height: 16),
          _BrandArchitecture(isMobile: isMobile),

          const SizedBox(height: 30),

          const _SectionHeading(
            eyebrow: 'VISUAL IDENTITY',
            title: 'A precise, premium digital language.',
            description:
                'The Gift Technology visual system combines deep navy foundations, soft blue technology accents, white typography, glass-inspired surfaces, subtle glow, controlled motion, and generous spacing.',
          ),
          const SizedBox(height: 16),
          _VisualIdentity(isMobile: isMobile),

          const SizedBox(height: 30),

          const _SectionHeading(
            eyebrow: 'THE EXPERIENCE',
            title: 'Clear. Premium. Useful. Human. Connected.',
            description:
                'The visual identity should support the product experience rather than compete with it. Technology should feel sophisticated while remaining approachable and easy to understand.',
          ),
          const SizedBox(height: 16),
          _ExperienceSection(isMobile: isMobile),

          const SizedBox(height: 30),

          const _SectionHeading(
            eyebrow: 'NAMING & USAGE',
            title: 'Keep the identity clear and consistent.',
            description:
                'Use the correct company or product name for the context. Gift Technology Ltd represents the company; GiftPay represents a product within the wider technology ecosystem.',
          ),
          const SizedBox(height: 16),
          _NamingSection(isMobile: isMobile),

          const SizedBox(height: 16),
          _DoDontSection(isMobile: isMobile),

          const SizedBox(height: 30),

          const _SectionHeading(
            eyebrow: 'BRAND RESOURCES',
            title: 'The materials behind the identity.',
            description:
                'This section is the practical resource area for teams, partners, media, developers, and organisations working with the Gift Technology identity.',
          ),
          const SizedBox(height: 16),
          _ResourcesSection(isMobile: isMobile),

          const SizedBox(height: 30),

          const _BrandContactPanel(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// BRAND IDENTITY HERO
// -----------------------------------------------------------------------------

class _BrandIdentityHero extends StatelessWidget {
  const _BrandIdentityHero();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 720;

    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 38),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF273D68), Color(0xFF172744), Color(0xFF0B1324)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.11)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A6BB8).withOpacity(.14),
            blurRadius: 55,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(.22),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: isMobile
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BrandSymbol(),
                SizedBox(height: 24),
                _BrandHeroCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _BrandSymbol(),
                const SizedBox(width: 28),
                const Expanded(child: _BrandHeroCopy()),
                const SizedBox(width: 35),
                const _BrandStatementCard(),
              ],
            ),
    );
  }
}

class _BrandSymbol extends StatelessWidget {
  const _BrandSymbol();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(.065),
        border: Border.all(color: Colors.white.withOpacity(.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF75A1FF).withOpacity(.18),
            blurRadius: 35,
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        size: 35,
        color: Color(0xFF75A1FF),
      ),
    );
  }
}

class _BrandHeroCopy extends StatelessWidget {
  const _BrandHeroCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GIFT TECHNOLOGY LTD',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.4,
            color: Color(0xFF75A1FF),
          ),
        ),
        const SizedBox(height: 11),
        const Text(
          'Building technology\nwith purpose.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 34,
            height: 1.04,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.4,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Gift Technology Ltd is the technology company behind a connected ecosystem of digital products and platforms designed around payments, utilities, commerce, connectivity, and modern digital experiences.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 13.5,
            height: 1.7,
            color: Colors.white.withOpacity(.63),
          ),
        ),
      ],
    );
  }
}

class _BrandStatementCard extends StatelessWidget {
  const _BrandStatementCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(.055),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.bolt_rounded,
            color: const Color(0xFF75A1FF).withOpacity(.9),
            size: 22,
          ),
          const SizedBox(height: 17),
          Text(
            'OUR CORE IDEA',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.7,
              color: Colors.white.withOpacity(.38),
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Technology should create meaningful utility.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 16,
              height: 1.3,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SECTION HEADING
// -----------------------------------------------------------------------------

class _SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;

  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.9,
            color: Color(0xFF75A1FF),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 22,
            height: 1.18,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.5,
            height: 1.62,
            color: Colors.white.withOpacity(.48),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// VALUES
// -----------------------------------------------------------------------------

class _ValuesSection extends StatelessWidget {
  final bool isMobile;

  const _ValuesSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        Icons.lightbulb_outline_rounded,
        'Innovation',
        'We build practical technology around real-world needs.',
      ),
      (
        Icons.accessibility_new_rounded,
        'Accessibility',
        'Digital services should be easier to access, understand, and use.',
      ),
      (
        Icons.verified_user_outlined,
        'Trust',
        'Technology should be dependable, transparent, and built responsibly.',
      ),
      (
        Icons.hub_outlined,
        'Connection',
        'We connect people, businesses, services, and digital infrastructure.',
      ),
      (
        Icons.trending_up_rounded,
        'Progress',
        'We build toward a more connected and capable digital economy.',
      ),
      (
        Icons.track_changes_rounded,
        'Purpose',
        'Technology matters when it creates meaningful utility.',
      ),
    ];

    return _ResponsiveGrid(
      isMobile: isMobile,
      count: 6,
      desktopColumns: 3,
      childBuilder: (index) {
        final item = items[index];

        return _InfoCard(icon: item.$1, title: item.$2, description: item.$3);
      },
    );
  }
}

// -----------------------------------------------------------------------------
// BRAND CHARACTER
// -----------------------------------------------------------------------------

class _BrandCharacterSection extends StatelessWidget {
  final bool isMobile;

  const _BrandCharacterSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        Icons.auto_awesome_rounded,
        'Modern',
        'Forward-looking without becoming unnecessarily complicated.',
      ),
      (
        Icons.shield_outlined,
        'Confident',
        'Capable and assured without being loud or overstated.',
      ),
      (
        Icons.person_outline_rounded,
        'Human',
        'Technology designed around people and the way they live and work.',
      ),
      (
        Icons.tune_rounded,
        'Precise',
        'Thoughtful, reliable, intentional, and consistent.',
      ),
      (
        Icons.rocket_launch_outlined,
        'Ambitious',
        'Designed with scale, opportunity, and long-term impact in mind.',
      ),
    ];

    return _ResponsiveGrid(
      isMobile: isMobile,
      count: items.length,
      desktopColumns: 5,
      childBuilder: (index) {
        final item = items[index];

        return _CharacterCard(
          icon: item.$1,
          title: item.$2,
          description: item.$3,
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// BRAND ARCHITECTURE
// -----------------------------------------------------------------------------

class _BrandArchitecture extends StatelessWidget {
  final bool isMobile;

  const _BrandArchitecture({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ArchitectureCard(
          icon: Icons.apartment_rounded,
          eyebrow: 'PARENT COMPANY',
          title: 'Gift Technology Ltd',
          description:
              'The parent technology company and corporate identity. Use this name when referring to the organisation, company profile, corporate initiatives, media, investors, partnerships, and legal or organisational matters.',
          highlighted: true,
        ),
        const SizedBox(height: 12),
        if (isMobile)
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF75A1FF),
          )
        else
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF75A1FF),
          ),
        const SizedBox(height: 12),
        _ArchitectureCard(
          icon: Icons.account_balance_wallet_rounded,
          eyebrow: 'DIGITAL PRODUCT',
          title: 'GiftPay',
          description:
              'A digital product within the Gift Technology ecosystem, covering wallet, payments, utilities, merchant services, and related digital transaction experiences.',
        ),
        const SizedBox(height: 12),
        _ArchitectureCard(
          icon: Icons.hub_rounded,
          eyebrow: 'CONNECTED ECOSYSTEM',
          title: 'Products & Platforms',
          description:
              'Additional products and technology platforms extend the ecosystem across business commerce, connectivity, distribution, digital services, and other practical technology experiences.',
        ),
      ],
    );
  }
}

class _ArchitectureCard extends StatelessWidget {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final bool highlighted;

  const _ArchitectureCard({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: highlighted
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF273D68), Color(0xFF162542)],
              )
            : null,
        color: highlighted ? null : Colors.white.withOpacity(.032),
        border: Border.all(
          color: highlighted
              ? const Color(0xFF75A1FF).withOpacity(.18)
              : Colors.white.withOpacity(.065),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color(0xFF4A6BB8).withOpacity(.12),
              border: Border.all(
                color: const Color(0xFF75A1FF).withOpacity(.13),
              ),
            ),
            child: Icon(icon, size: 21, color: const Color(0xFF75A1FF)),
          ),
          const SizedBox(width: 16),
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
                    letterSpacing: 1.5,
                    color: Color(0xFF75A1FF),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11.7,
                    height: 1.55,
                    color: Colors.white.withOpacity(.50),
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

// -----------------------------------------------------------------------------
// VISUAL IDENTITY
// -----------------------------------------------------------------------------

class _VisualIdentity extends StatelessWidget {
  final bool isMobile;

  const _VisualIdentity({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _VisualColorPanel(isMobile: isMobile),
        const SizedBox(height: 14),
        _VisualPrinciples(isMobile: isMobile),
      ],
    );
  }
}

class _VisualColorPanel extends StatelessWidget {
  final bool isMobile;

  const _VisualColorPanel({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final colors = [
      ('Deep Navy', '#273D68', const Color(0xFF273D68), 'Foundation'),
      ('Soft Blue', '#4A6BB8', const Color(0xFF4A6BB8), 'Technology'),
      ('White', '#FFFFFF', Colors.white, 'Clarity'),
    ];

    return _GlassPanel(
      child: _ResponsiveGrid(
        isMobile: isMobile,
        count: colors.length,
        desktopColumns: 3,
        childBuilder: (index) {
          final item = colors[index];

          return _ColorCard(
            name: item.$1,
            hex: item.$2,
            color: item.$3,
            role: item.$4,
            darkText: item.$3 == Colors.white,
          );
        },
      ),
    );
  }
}

class _ColorCard extends StatelessWidget {
  final String name;
  final String hex;
  final Color color;
  final String role;
  final bool darkText;

  const _ColorCard({
    required this.name,
    required this.hex,
    required this.color,
    required this.role,
    this.darkText = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = darkText ? const Color(0xFF18243B) : Colors.white;

    return Container(
      height: 130,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        color: color,
        border: Border.all(
          color: darkText
              ? const Color(0xFFE2E6EE)
              : Colors.white.withOpacity(.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            role.toUpperCase(),
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: textColor.withOpacity(.52),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hex,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(.62),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisualPrinciples extends StatelessWidget {
  final bool isMobile;

  const _VisualPrinciples({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        Icons.text_fields_rounded,
        'Typography',
        'Clean, strong typography with generous spacing and clear hierarchy.',
      ),
      (
        Icons.blur_on_rounded,
        'Surfaces',
        'Glass-inspired panels, restrained transparency, and subtle depth.',
      ),
      (
        Icons.auto_awesome_rounded,
        'Motion',
        'Smooth, intentional animation that supports the experience rather than distracting from it.',
      ),
      (
        Icons.image_outlined,
        'Imagery',
        'Premium, human, technology-led imagery with strong visual clarity.',
      ),
    ];

    return _ResponsiveGrid(
      isMobile: isMobile,
      count: items.length,
      desktopColumns: 4,
      childBuilder: (index) {
        final item = items[index];

        return _InfoCard(icon: item.$1, title: item.$2, description: item.$3);
      },
    );
  }
}

// -----------------------------------------------------------------------------
// EXPERIENCE
// -----------------------------------------------------------------------------

class _ExperienceSection extends StatelessWidget {
  final bool isMobile;

  const _ExperienceSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    const items = [
      ('01', 'Clear', 'People should understand what the technology does.'),
      (
        '02',
        'Premium',
        'The experience should feel considered and trustworthy.',
      ),
      ('03', 'Useful', 'Every feature should serve a meaningful purpose.'),
      (
        '04',
        'Human',
        'Technology should work around people, not the other way around.',
      ),
      (
        '05',
        'Connected',
        'Products should feel like part of one coherent ecosystem.',
      ),
    ];

    return _GlassPanel(
      child: _ResponsiveGrid(
        isMobile: isMobile,
        count: items.length,
        desktopColumns: 5,
        childBuilder: (index) {
          final item = items[index];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.$1,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: const Color(0xFF75A1FF).withOpacity(.72),
                ),
              ),
              const SizedBox(height: 13),
              Text(
                item.$2,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                item.$3,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 11,
                  height: 1.5,
                  color: Colors.white.withOpacity(.45),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// NAMING
// -----------------------------------------------------------------------------

class _NamingSection extends StatelessWidget {
  final bool isMobile;

  const _NamingSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        Icons.business_rounded,
        'Gift Technology Ltd',
        'COMPANY IDENTITY',
        'Use for corporate, legal, media, investor, organisational, and company-level references.',
      ),
      (
        Icons.account_balance_wallet_rounded,
        'GiftPay',
        'PRODUCT IDENTITY',
        'Use when referring specifically to the GiftPay digital product and its associated user experience.',
      ),
      (
        Icons.code_rounded,
        'GiftPay API',
        'TECHNOLOGY',
        'Use when specifically discussing the GiftPay API and supported digital transaction services.',
      ),
    ];

    return _ResponsiveGrid(
      isMobile: isMobile,
      count: items.length,
      desktopColumns: 3,
      childBuilder: (index) {
        final item = items[index];

        return _NamingCard(
          icon: item.$1,
          title: item.$2,
          label: item.$3,
          description: item.$4,
        );
      },
    );
  }
}

class _NamingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String label;
  final String description;

  const _NamingCard({
    required this.icon,
    required this.title,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        color: Colors.white.withOpacity(.033),
        border: Border.all(color: Colors.white.withOpacity(.065)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: const Color(0xFF4A6BB8).withOpacity(.12),
              border: Border.all(
                color: const Color(0xFF75A1FF).withOpacity(.12),
              ),
            ),
            child: Icon(icon, color: const Color(0xFF75A1FF), size: 20),
          ),
          const Spacer(),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: Colors.white.withOpacity(.35),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11.2,
              height: 1.48,
              color: Colors.white.withOpacity(.46),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DO / DON'T
// -----------------------------------------------------------------------------

class _DoDontSection extends StatelessWidget {
  final bool isMobile;

  const _DoDontSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: isMobile
          ? const Column(
              children: [
                _GuidanceColumn(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Recommended',
                  items: [
                    'Use the exact company or product name for the context.',
                    'Maintain strong contrast and clear space around visual marks.',
                    'Preserve the premium, clean, technology-led visual language.',
                    'Keep messaging useful, clear, confident, and human.',
                  ],
                ),
                SizedBox(height: 24),
                _GuidanceColumn(
                  icon: Icons.cancel_outlined,
                  title: 'Avoid',
                  items: [
                    'Do not rename, distort, or recreate the Gift Technology identity.',
                    'Do not present GiftPay as the parent company.',
                    'Do not invent certifications, partnerships, awards, or claims.',
                    'Do not use visual effects that overpower clarity or usability.',
                  ],
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  child: _GuidanceColumn(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Recommended',
                    items: [
                      'Use the exact company or product name for the context.',
                      'Maintain strong contrast and clear space around visual marks.',
                      'Preserve the premium, clean, technology-led visual language.',
                      'Keep messaging useful, clear, confident, and human.',
                    ],
                  ),
                ),
                SizedBox(width: 35),
                Expanded(
                  child: _GuidanceColumn(
                    icon: Icons.cancel_outlined,
                    title: 'Avoid',
                    items: [
                      'Do not rename, distort, or recreate the Gift Technology identity.',
                      'Do not present GiftPay as the parent company.',
                      'Do not invent certifications, partnerships, awards, or claims.',
                      'Do not use visual effects that overpower clarity or usability.',
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _GuidanceColumn extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const _GuidanceColumn({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF75A1FF)),
            const SizedBox(width: 9),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.circle, size: 4, color: Color(0xFF75A1FF)),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 11.7,
                      height: 1.5,
                      color: Colors.white.withOpacity(.50),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// RESOURCES
// -----------------------------------------------------------------------------

class _ResourcesSection extends StatelessWidget {
  final bool isMobile;

  const _ResourcesSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        Icons.image_outlined,
        'Logo Assets',
        'LOGOS',
        'Primary company and product identity assets for approved digital and print use.',
      ),
      (
        Icons.palette_outlined,
        'Color System',
        'COLORS',
        'Core brand colors, supporting tones, and usage guidance for consistent visual presentation.',
      ),
      (
        Icons.text_fields_rounded,
        'Typography',
        'TYPE',
        'Typography hierarchy, weights, sizing, spacing, and general presentation principles.',
      ),
      (
        Icons.dashboard_customize_outlined,
        'Visual Guidelines',
        'DESIGN',
        'Guidance for surfaces, cards, gradients, imagery, motion, icons, and overall visual direction.',
      ),
      (
        Icons.photo_library_outlined,
        'Media Assets',
        'MEDIA',
        'Approved visual material for media, presentations, publications, and brand communications.',
      ),
      (
        Icons.menu_book_outlined,
        'Brand Guidelines',
        'GUIDELINES',
        'A consolidated reference for teams and partners working with the Gift Technology identity.',
      ),
    ];

    return _ResponsiveGrid(
      isMobile: isMobile,
      count: items.length,
      desktopColumns: 3,
      childBuilder: (index) {
        final item = items[index];

        return _ResourceCard(
          icon: item.$1,
          title: item.$2,
          label: item.$3,
          description: item.$4,
        );
      },
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String label;
  final String description;

  const _ResourceCard({
    required this.icon,
    required this.title,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        color: Colors.white.withOpacity(.033),
        border: Border.all(color: Colors.white.withOpacity(.065)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: const Color(0xFF4A6BB8).withOpacity(.12),
              border: Border.all(
                color: const Color(0xFF75A1FF).withOpacity(.13),
              ),
            ),
            child: Icon(icon, color: const Color(0xFF75A1FF), size: 20),
          ),
          const Spacer(),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: Colors.white.withOpacity(.34),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11.2,
              height: 1.45,
              color: Colors.white.withOpacity(.46),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CONTACT
// -----------------------------------------------------------------------------

class _BrandContactPanel extends StatelessWidget {
  const _BrandContactPanel();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 720;

    return Container(
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF273D68), Color(0xFF111B30)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.09)),
      ),
      child: isMobile
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ContactCopy(),
                SizedBox(height: 20),
                _ContactDetails(),
              ],
            )
          : const Row(
              children: [
                Expanded(child: _ContactCopy()),
                SizedBox(width: 35),
                SizedBox(width: 355, child: _ContactDetails()),
              ],
            ),
    );
  }
}

class _ContactCopy extends StatelessWidget {
  const _ContactCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BRAND & CORPORATE ENQUIRIES',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.7,
            color: Color(0xFF75A1FF),
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Working with the Gift Technology identity?',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 21,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'For brand, corporate, media, partnership, or resource enquiries, contact Gift Technology directly.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.5,
            height: 1.58,
            color: Colors.white.withOpacity(.54),
          ),
        ),
      ],
    );
  }
}

class _ContactDetails extends StatelessWidget {
  const _ContactDetails();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(.045),
        border: Border.all(color: Colors.white.withOpacity(.09)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            icon: Icons.email_outlined,
            text: 'support@gifttechnologyltd.com',
          ),
          SizedBox(height: 12),
          _DetailRow(icon: Icons.phone_outlined, text: '+234 901 085 3849'),
          SizedBox(height: 12),
          _DetailRow(
            icon: Icons.location_on_outlined,
            text: 'Port Harcourt, Rivers, Nigeria',
          ),
          SizedBox(height: 12),
          _DetailRow(
            icon: Icons.language_rounded,
            text: 'gifttechnologyltd.com',
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.circle, size: 6, color: Color(0xFF75A1FF)),
        const SizedBox(width: 10),
        Icon(icon, size: 16, color: const Color(0xFF75A1FF)),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11.5,
              height: 1.45,
              color: Colors.white.withOpacity(.60),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// SHARED COMPONENTS
// -----------------------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(.032),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: const Color(0xFF4A6BB8).withOpacity(.11),
              border: Border.all(
                color: const Color(0xFF75A1FF).withOpacity(.12),
              ),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF75A1FF)),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11.2,
              height: 1.48,
              color: Colors.white.withOpacity(.46),
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _CharacterCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(.032),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF75A1FF), size: 21),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 10.8,
              height: 1.45,
              color: Colors.white.withOpacity(.44),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;

  const _GlassPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(.052),
                Colors.white.withOpacity(.015),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(.07)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  final bool isMobile;
  final int count;
  final int desktopColumns;
  final Widget Function(int index) childBuilder;

  const _ResponsiveGrid({
    required this.isMobile,
    required this.count,
    required this.desktopColumns,
    required this.childBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : desktopColumns,
        crossAxisSpacing: 13,
        mainAxisSpacing: 13,
        mainAxisExtent: isMobile ? 150 : 165,
      ),
      itemBuilder: (_, index) => childBuilder(index),
    );
  }
}
