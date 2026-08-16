import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class BrandResourcesScreen extends StatelessWidget {
  const BrandResourcesScreen({super.key});

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _navy = Color(0xFF273D68);
  static const Color _lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      title: 'Brand Resources',
      description:
          'A practical reference for partners, media, developers, and organisations presenting Gift Technology and its digital products.',
      eyebrow: 'GIFT TECHNOLOGY / BRAND',
      icon: Icons.auto_awesome_rounded,
      metaLabel: 'RESOURCE',
      metaValue: 'Brand Identity',
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
    final width = MediaQuery.of(context).size.width;
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
          _HeroPanel(isMobile: isMobile),
          const SizedBox(height: 22),
          _SectionHeading(
            eyebrow: 'BRAND ARCHITECTURE',
            title: 'One technology company. A connected digital ecosystem.',
            description:
                'Gift Technology Ltd is the parent technology identity. GiftPay is one of the digital products within the ecosystem, alongside services for utilities, payments, business operations, and other digital experiences.',
          ),
          const SizedBox(height: 14),
          _BrandArchitecture(isMobile: isMobile),
          const SizedBox(height: 22),
          _SectionHeading(
            eyebrow: 'VISUAL LANGUAGE',
            title: 'A precise, premium digital identity.',
            description:
                'The current Gift Technology visual direction uses deep navy foundations, soft blue highlights, white typography, glass-inspired surfaces, subtle glow, and generous spacing.',
          ),
          const SizedBox(height: 14),
          _VisualSystem(isMobile: isMobile),
          const SizedBox(height: 22),
          _SectionHeading(
            eyebrow: 'LOGO & NAMING',
            title: 'Keep the identity clear and consistent.',
            description:
                'Use the correct company or product name for the context. Avoid presenting GiftPay as the name of the parent company.',
          ),
          const SizedBox(height: 14),
          _NamingCards(isMobile: isMobile),
          const SizedBox(height: 22),
          _DoDontPanel(isMobile: isMobile),
          const SizedBox(height: 22),
          _ContactPanel(isMobile: isMobile),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final bool isMobile;

  const _HeroPanel({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 23 : 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF273D68), Color(0xFF15233F), Color(0xFF0D1527)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.20),
            blurRadius: 35,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_BrandMark(), const SizedBox(height: 20), _HeroCopy()],
            )
          : Row(
              children: [
                _BrandMark(),
                const SizedBox(width: 22),
                Expanded(child: _HeroCopy()),
                const SizedBox(width: 20),
                _IdentityBadge(),
              ],
            ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(.07),
        border: Border.all(color: Colors.white.withOpacity(.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF75A1FF).withOpacity(.16),
            blurRadius: 30,
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        size: 32,
        color: Color(0xFF75A1FF),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
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
            letterSpacing: 2.1,
            color: Color(0xFF75A1FF),
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'The identity behind the technology.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 25,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Gift Technology Ltd is a Nigerian multinational technology company '
          'headquartered in Port Harcourt, Rivers Nigeria. We build secure '
          'digital platforms that power payments, utilities, e-voting, '
          'entertainment, and business operations across Africa.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 13,
            height: 1.65,
            color: Colors.white.withOpacity(.62),
          ),
        ),
      ],
    );
  }
}

class _IdentityBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(.055),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REGISTERED COMPANY',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: Colors.white.withOpacity(.43),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Reg. No. 9607125',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

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
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.7,
            color: Color(0xFF75A1FF),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          description,
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.5,
            height: 1.58,
            color: Colors.white.withOpacity(.48),
          ),
        ),
      ],
    );
  }
}

class _BrandArchitecture extends StatelessWidget {
  final bool isMobile;

  const _BrandArchitecture({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        Icons.apartment_rounded,
        'Gift Technology Ltd',
        'Parent company identity',
        'Use this name when referring to the company, corporate identity, technology organisation, or company-level initiatives.',
      ),
      (
        Icons.account_balance_wallet_rounded,
        'GiftPay',
        'Digital product identity',
        'Use GiftPay when referring specifically to the wallet, payments, utilities, business dashboard, or GiftPay API ecosystem.',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 166,
      ),
      itemBuilder: (_, index) {
        final item = cards[index];
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

class _VisualSystem extends StatelessWidget {
  final bool isMobile;

  const _VisualSystem({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: isMobile
          ? Column(
              children: [
                _ColorCard(
                  name: 'Deep Navy',
                  hex: '#273D68',
                  color: const Color(0xFF273D68),
                ),
                const SizedBox(height: 12),
                _ColorCard(
                  name: 'Soft Blue',
                  hex: '#4A6BB8',
                  color: const Color(0xFF4A6BB8),
                ),
                const SizedBox(height: 12),
                _ColorCard(
                  name: 'White',
                  hex: '#FFFFFF',
                  color: Colors.white,
                  darkText: true,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _ColorCard(
                    name: 'Deep Navy',
                    hex: '#273D68',
                    color: const Color(0xFF273D68),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ColorCard(
                    name: 'Soft Blue',
                    hex: '#4A6BB8',
                    color: const Color(0xFF4A6BB8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ColorCard(
                    name: 'White',
                    hex: '#FFFFFF',
                    color: Colors.white,
                    darkText: true,
                  ),
                ),
              ],
            ),
    );
  }
}

class _ColorCard extends StatelessWidget {
  final String name;
  final String hex;
  final Color color;
  final bool darkText;

  const _ColorCard({
    required this.name,
    required this.hex,
    required this.color,
    this.darkText = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = darkText ? const Color(0xFF18243B) : Colors.white;

    return Container(
      height: 112,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: color,
        border: Border.all(
          color: darkText
              ? const Color(0xFFE2E6EE)
              : Colors.white.withOpacity(.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.10),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            name,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            hex,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(.68),
            ),
          ),
        ],
      ),
    );
  }
}

class _NamingCards extends StatelessWidget {
  final bool isMobile;

  const _NamingCards({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.business_rounded,
        'Company references',
        'Gift Technology Ltd',
        'Use for corporate, legal, company profile, media, investor, and organisational references.',
      ),
      (
        Icons.wallet_rounded,
        'Product references',
        'GiftPay',
        'Use for the wallet, payments, utilities, merchant services, and GiftPay API product experience.',
      ),
      (
        Icons.code_rounded,
        'Technology references',
        'GiftPay API',
        'Use when specifically discussing the REST API and supported digital transaction services.',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 3,
        crossAxisSpacing: 13,
        mainAxisSpacing: 13,
        mainAxisExtent: 156,
      ),
      itemBuilder: (_, index) {
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

class _DoDontPanel extends StatelessWidget {
  final bool isMobile;

  const _DoDontPanel({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: isMobile
          ? Column(
              children: [
                _GuidanceColumn(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Recommended',
                  items: const [
                    'Use the exact company or product name for the context.',
                    'Keep sufficient contrast around logos and visual marks.',
                    'Preserve the premium, clean, technology-led visual language.',
                  ],
                ),
                const SizedBox(height: 20),
                _GuidanceColumn(
                  icon: Icons.cancel_outlined,
                  title: 'Avoid',
                  items: const [
                    'Do not rename or distort the Gift Technology identity.',
                    'Do not present GiftPay as a separate parent company.',
                    'Do not invent certifications, partnerships, awards, or brand claims.',
                  ],
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _GuidanceColumn(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Recommended',
                    items: const [
                      'Use the exact company or product name for the context.',
                      'Keep sufficient contrast around logos and visual marks.',
                      'Preserve the premium, clean, technology-led visual language.',
                    ],
                  ),
                ),
                const SizedBox(width: 28),
                Expanded(
                  child: _GuidanceColumn(
                    icon: Icons.cancel_outlined,
                    title: 'Avoid',
                    items: const [
                      'Do not rename or distort the Gift Technology identity.',
                      'Do not present GiftPay as a separate parent company.',
                      'Do not invent certifications, partnerships, awards, or brand claims.',
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
            Icon(icon, color: const Color(0xFF75A1FF), size: 20),
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
        const SizedBox(height: 13),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
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

class _ContactPanel extends StatelessWidget {
  final bool isMobile;

  const _ContactPanel({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF273D68), Color(0xFF111B30)],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_copy(), const SizedBox(height: 18), _details()],
            )
          : Row(
              children: [
                Expanded(child: _copy()),
                const SizedBox(width: 30),
                SizedBox(width: 350, child: _details()),
              ],
            ),
    );
  }

  Widget _copy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BRAND & CORPORATE ENQUIRIES',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.7,
            color: Color(0xFF75A1FF),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Need to use the Gift Technology identity?',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'For brand, corporate, media, or partnership enquiries, contact Gift Technology directly.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.5,
            height: 1.55,
            color: Colors.white.withOpacity(.54),
          ),
        ),
      ],
    );
  }

  Widget _details() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        color: Colors.white.withOpacity(.045),
        border: Border.all(color: Colors.white.withOpacity(.09)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            icon: Icons.email_outlined,
            text: 'support@gifttechnologyltd.com',
          ),
          const SizedBox(height: 11),
          _DetailRow(icon: Icons.phone_outlined, text: '+234 901 085 3849'),
          const SizedBox(height: 11),
          _DetailRow(
            icon: Icons.location_on_outlined,
            text: 'Port Harcourt, Rivers, Nigeria',
          ),
          const SizedBox(height: 11),
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
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(.035),
        border: Border.all(color: Colors.white.withOpacity(.065)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
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
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: Colors.white.withOpacity(.38),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11.2,
              height: 1.4,
              color: Colors.white.withOpacity(.46),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;

  const _GlassPanel({required this.child, this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient:
            gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(.052),
                Colors.white.withOpacity(.016),
              ],
            ),
        border: Border.all(color: Colors.white.withOpacity(.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
