import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class CommunityStandardsScreen extends StatelessWidget {
  const CommunityStandardsScreen({super.key});

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      eyebrow: 'GIFT TECHNOLOGY / TRUST',
      title: 'Community\nStandards',
      description:
          'The standards that help keep Gift Technology platforms safe, respectful, reliable, and useful for everyone.',
      icon: Icons.groups_2_outlined,
      metaLabel: 'STANDARD',
      metaValue: 'Safe & Respectful Use',
      secondaryMetaLabel: 'APPLIES TO',
      secondaryMetaValue: 'Gift Technology Platforms',
      child: const _CommunityStandardsContent(),
    );
  }
}

class _CommunityStandardsContent extends StatelessWidget {
  const _CommunityStandardsContent();

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _intro(isMobile),
          const SizedBox(height: 20),
          _sectionLabel('OUR COMMUNITY'),
          const SizedBox(height: 12),
          _standardsGrid(isMobile),
          const SizedBox(height: 20),
          _safeUseSection(isMobile),
          const SizedBox(height: 20),
          _prohibitedSection(isMobile),
          const SizedBox(height: 20),
          _enforcementSection(isMobile),
          const SizedBox(height: 20),
          _reportSection(isMobile),
        ],
      ),
    );
  }

  Widget _intro(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF273D68), Color(0xFF355792), Color(0xFF101A2D)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.11)),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(.17),
            blurRadius: 36,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _trustIcon(),
                const SizedBox(height: 18),
                _introCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _trustIcon(),
                const SizedBox(width: 20),
                Expanded(child: _introCopy()),
                const SizedBox(width: 22),
                _trustBadge(),
              ],
            ),
    );
  }

  Widget _trustIcon() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(.075),
        border: Border.all(color: Colors.white.withOpacity(.14)),
        boxShadow: [
          BoxShadow(color: _lightBlue.withOpacity(.18), blurRadius: 30),
        ],
      ),
      child: const Icon(Icons.shield_outlined, color: Colors.white, size: 32),
    );
  }

  Widget _introCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A BETTER DIGITAL COMMUNITY',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.9,
            color: Colors.white.withOpacity(.62),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Respect, safety, and responsible participation.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 22,
            height: 1.18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -.3,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Gift Technology expects people using its platforms and community '
          'spaces to interact responsibly and help maintain an environment '
          'where digital services can be used safely and respectfully.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.8,
            height: 1.6,
            color: Colors.white.withOpacity(.60),
          ),
        ),
      ],
    );
  }

  Widget _trustBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(.07),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user_outlined, size: 15, color: _lightBlue),
          const SizedBox(width: 7),
          Text(
            'TRUST & SAFETY',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white.withOpacity(.70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _standardsGrid(bool isMobile) {
    const standards = [
      _Standard(
        Icons.handshake_outlined,
        'Treat people with respect',
        'Keep conversations and interactions professional, constructive, and respectful.',
      ),
      _Standard(
        Icons.lock_outline_rounded,
        'Protect account security',
        'Keep login credentials, security information, and account access private and secure.',
      ),
      _Standard(
        Icons.gpp_maybe_outlined,
        'Do not abuse our platforms',
        'Do not use Gift Technology services to facilitate fraud, deception, abuse, or other harmful activity.',
      ),
      _Standard(
        Icons.privacy_tip_outlined,
        'Respect privacy',
        'Do not expose, misuse, or attempt to obtain another person’s private information.',
      ),
      _Standard(
        Icons.fact_check_outlined,
        'Use accurate information',
        'Provide truthful information when using services that require identity, account, or transaction details.',
      ),
      _Standard(
        Icons.devices_other_outlined,
        'Use services responsibly',
        'Use Gift Technology products only for their intended purposes and in accordance with applicable terms.',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: standards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: isMobile ? 122 : 132,
      ),
      itemBuilder: (_, index) => _StandardCard(standard: standards[index]),
    );
  }

  Widget _safeUseSection(bool isMobile) {
    return _ContentPanel(
      isMobile: isMobile,
      icon: Icons.verified_outlined,
      label: 'SAFE PARTICIPATION',
      title: 'Help keep the ecosystem useful.',
      body:
          'Community spaces, support channels, developer resources, and other '
          'Gift Technology environments work best when participants communicate '
          'clearly, protect one another’s privacy, and use the available services '
          'for legitimate purposes.',
    );
  }

  Widget _prohibitedSection(bool isMobile) {
    const items = [
      'Fraudulent or deceptive activity',
      'Attempts to compromise accounts, systems, or services',
      'Harassment, threats, or abusive conduct',
      'Misuse of personal or confidential information',
      'Activity intended to disrupt or damage our platforms',
      'Use of Gift Technology services for unlawful purposes',
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white.withOpacity(.032),
        border: Border.all(color: Colors.white.withOpacity(.075)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('NOT ACCEPTABLE'),
          const SizedBox(height: 8),
          const Text(
            'Activity that puts people or platforms at risk.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gift Technology may take action when activity violates our terms, '
            'creates a security risk, or undermines safe use of our services.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12.7,
              height: 1.55,
              color: Colors.white.withOpacity(.50),
            ),
          ),
          const SizedBox(height: 17),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.remove_circle_outline,
                    size: 17,
                    color: _lightBlue,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontFamily: 'SegoeUI',
                        fontSize: 12.3,
                        height: 1.45,
                        color: Colors.white.withOpacity(.58),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _enforcementSection(bool isMobile) {
    return _ContentPanel(
      isMobile: isMobile,
      icon: Icons.gavel_outlined,
      label: 'ENFORCEMENT',
      title: 'Protecting the community comes first.',
      body:
          'Where activity breaches our service terms or creates a material '
          'risk to users or the platform, Gift Technology may restrict or '
          'suspend access and take other appropriate action. Serious matters '
          'may also be escalated through the appropriate legal or regulatory channels.',
    );
  }

  Widget _reportSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101A2D), Color(0xFF1D2E50)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _reportCopy(),
                const SizedBox(height: 18),
                _contactCard(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _reportCopy()),
                const SizedBox(width: 28),
                SizedBox(width: 330, child: _contactCard()),
              ],
            ),
    );
  }

  Widget _reportCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('REPORT A CONCERN'),
        const SizedBox(height: 8),
        const Text(
          'See something that needs attention?',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'If you need help with a service, suspect fraudulent activity, or '
          'have a safety concern involving a Gift Technology platform, contact '
          'our support team with the relevant details.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.7,
            height: 1.58,
            color: Colors.white.withOpacity(.50),
          ),
        ),
      ],
    );
  }

  Widget _contactCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        color: Colors.white.withOpacity(.045),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _contactRow(Icons.email_outlined, 'support@gifttechnologyltd.com'),
          const SizedBox(height: 12),
          _contactRow(Icons.phone_outlined, '+234 901 085 3849'),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: _lightBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12,
              height: 1.45,
              color: Colors.white.withOpacity(.58),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return const Text(
      'COMMUNITY STANDARDS',
      style: TextStyle(
        fontFamily: 'SegoeUI',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
        color: _lightBlue,
      ),
    );
  }
}

class _Standard {
  final IconData icon;
  final String title;
  final String description;

  const _Standard(this.icon, this.title, this.description);
}

class _StandardCard extends StatefulWidget {
  final _Standard standard;

  const _StandardCard({required this.standard});

  @override
  State<_StandardCard> createState() => _StandardCardState();
}

class _StandardCardState extends State<_StandardCard> {
  bool _hovered = false;

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(_hovered ? .075 : .045),
              Colors.white.withOpacity(.018),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(_hovered ? .13 : .065),
          ),
          boxShadow: [
            BoxShadow(
              color: _blue.withOpacity(_hovered ? .12 : .035),
              blurRadius: _hovered ? 25 : 16,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _blue.withOpacity(.10),
                border: Border.all(color: _lightBlue.withOpacity(.14)),
              ),
              child: Icon(widget.standard.icon, size: 21, color: _lightBlue),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.standard.title,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 14.2,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.standard.description,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 11.7,
                      height: 1.45,
                      color: Colors.white.withOpacity(.49),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentPanel extends StatelessWidget {
  final bool isMobile;
  final IconData icon;
  final String label;
  final String title;
  final String body;

  const _ContentPanel({
    required this.isMobile,
    required this.icon,
    required this.label,
    required this.title,
    required this.body,
  });

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue.withOpacity(.10), Colors.white.withOpacity(.028)],
        ),
        border: Border.all(color: _lightBlue.withOpacity(.10)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_icon(), const SizedBox(height: 16), _copy()],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _icon(),
                const SizedBox(width: 18),
                Expanded(child: _copy()),
              ],
            ),
    );
  }

  Widget _icon() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _blue.withOpacity(.11),
        border: Border.all(color: _lightBlue.withOpacity(.15)),
      ),
      child: Icon(icon, color: _lightBlue, size: 25),
    );
  }

  Widget _copy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: _lightBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          body,
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.7,
            height: 1.6,
            color: Colors.white.withOpacity(.52),
          ),
        ),
      ],
    );
  }
}
