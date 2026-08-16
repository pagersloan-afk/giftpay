import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class ElectionsScreen extends StatelessWidget {
  const ElectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      title: 'Elections',
      description:
          'Exploring secure digital voting infrastructure, auditability, and civic technology through controlled internal research and experimentation.',
      eyebrow: 'CIVIC TECHNOLOGY',
      icon: Icons.how_to_vote_outlined,
      metaLabel: 'CURRENT STATUS',
      metaValue: 'Experimental',
      secondaryMetaLabel: 'PUBLIC ELECTIONS',
      secondaryMetaValue: 'Not Available',
      child: const _ElectionsContent(),
    );
  }
}

class _ElectionsContent extends StatelessWidget {
  const _ElectionsContent();

  static const Color primaryBlue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 720;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _statusHero(isMobile),
          const SizedBox(height: 20),
          _overviewSection(),
          const SizedBox(height: 20),
          _capabilitiesSection(isMobile),
          const SizedBox(height: 20),
          _securitySection(isMobile),
          const SizedBox(height: 20),
          _auditSection(),
          const SizedBox(height: 20),
          _publicAvailabilitySection(),
          const SizedBox(height: 20),
          _responsibleTechnologySection(isMobile),
          const SizedBox(height: 20),
          _contactSection(),
        ],
      ),
    );
  }

  Widget _statusHero(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withOpacity(.46),
            const Color(0xFF0A1427).withOpacity(.96),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(.09)),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(.14),
            blurRadius: 48,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              color: lightBlue.withOpacity(.11),
              border: Border.all(color: lightBlue.withOpacity(.15)),
            ),
            child: const Icon(
              Icons.how_to_vote_outlined,
              color: lightBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Exploring the future of digital voting.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Gift Technology is researching secure digital voting concepts through internal experimentation. Our current e-voting capabilities are not offered as a public election service.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 12,
                    height: 1.62,
                    color: Colors.white.withOpacity(.52),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewSection() {
    return _sectionCard(
      eyebrow: '01 • CURRENT STATUS',
      title: 'Experimental technology — not a public election service.',
      description:
          'Gift Technology Ltd does not currently provide public e-voting for government, political, or public elections. Our work in this area remains experimental and focused on understanding how secure digital voting infrastructure could operate.',
      icon: Icons.science_outlined,
    );
  }

  Widget _capabilitiesSection(bool isMobile) {
    final capabilities = [
      (
        Icons.poll_outlined,
        'Secure Polling',
        'Internal polling concepts designed around controlled participation and secure vote collection.',
      ),
      (
        Icons.vpn_key_outlined,
        'Token-Based Voting',
        'Exploration of token-based mechanisms for controlled voting access.',
      ),
      (
        Icons.lock_outline,
        'Encrypted Vote Storage',
        'Research into protected storage approaches for electronic voting records.',
      ),
      (
        Icons.admin_panel_settings_outlined,
        'Administrative Controls',
        'Internal administration concepts for configuring and monitoring controlled voting exercises.',
      ),
    ];

    return _contentSection(
      eyebrow: '02 • INTERNAL CAPABILITIES',
      title: 'Technology under exploration.',
      description:
          'The following capabilities represent the areas of e-voting technology currently explored internally by Gift Technology.',
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: capabilities.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 145,
          ),
          itemBuilder: (context, index) {
            final item = capabilities[index];

            return _CapabilityTile(
              icon: item.$1,
              title: item.$2,
              description: item.$3,
            );
          },
        ),
      ],
    );
  }

  Widget _securitySection(bool isMobile) {
    final items = [
      (
        Icons.lock_person_outlined,
        'Access control',
        'Controlled access mechanisms can help restrict participation to authorised users.',
      ),
      (
        Icons.key_outlined,
        'Token security',
        'Token-based voting is being explored as a mechanism for controlled voting participation.',
      ),
      (
        Icons.enhanced_encryption_outlined,
        'Protected records',
        'Encrypted vote storage is part of the internal technology exploration.',
      ),
    ];

    return _contentSection(
      eyebrow: '03 • SECURITY',
      title: 'Security is central to the research.',
      description:
          'Any future digital voting system would require strong controls around voter access, vote confidentiality, data integrity, and auditability.',
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 145,
          ),
          itemBuilder: (context, index) {
            final item = items[index];

            return _CapabilityTile(
              icon: item.$1,
              title: item.$2,
              description: item.$3,
            );
          },
        ),
      ],
    );
  }

  Widget _auditSection() {
    return _sectionCard(
      eyebrow: '04 • AUDITABILITY',
      title: 'Designed with accountability in mind.',
      description:
          'Audit logs are part of the internal e-voting capability set. The objective is to provide traceable system activity during controlled voting exercises while maintaining the integrity of voting records.',
      icon: Icons.fact_check_outlined,
    );
  }

  Widget _publicAvailabilitySection() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF273D68).withOpacity(.32),
            const Color(0xFF0A1427).withOpacity(.90),
          ],
        ),
        border: Border.all(color: lightBlue.withOpacity(.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.withOpacity(.08),
              border: Border.all(color: Colors.orange.withOpacity(.12)),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Colors.orangeAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PUBLIC AVAILABILITY',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.55,
                    color: lightBlue,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Not currently available for public elections.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Gift Technology Ltd does not currently provide public e-voting services. The technology described on this page is experimental and should not be interpreted as an active public-election product or election service.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11,
                    height: 1.58,
                    color: Color.fromRGBO(255, 255, 255, .44),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _responsibleTechnologySection(bool isMobile) {
    final principles = [
      (
        Icons.verified_user_outlined,
        'Integrity',
        'Protecting the integrity of voting records is fundamental to any future implementation.',
      ),
      (
        Icons.visibility_outlined,
        'Transparency',
        'Voting systems require understandable processes and appropriate auditability.',
      ),
      (
        Icons.security_outlined,
        'Security',
        'Strong security controls are essential when handling sensitive voting activity.',
      ),
      (
        Icons.people_outline,
        'Accessibility',
        'Future civic technology should be designed with broad and inclusive participation in mind.',
      ),
    ];

    return _contentSection(
      eyebrow: '05 • RESPONSIBLE INNOVATION',
      title: 'Technology should strengthen trust.',
      description:
          'Our approach to civic technology is grounded in the principle that digital systems must be designed responsibly, securely, and transparently before they are considered for real-world public use.',
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: principles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 125,
          ),
          itemBuilder: (context, index) {
            final item = principles[index];

            return _CapabilityTile(
              icon: item.$1,
              title: item.$2,
              description: item.$3,
            );
          },
        ),
      ],
    );
  }

  Widget _contactSection() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        color: Colors.white.withOpacity(.025),
        border: Border.all(color: Colors.white.withOpacity(.055)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.mail_outline_rounded, color: lightBlue, size: 24),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TECHNOLOGY & PARTNERSHIP ENQUIRIES',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: lightBlue,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Connect with Gift Technology',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'support@gifttechnologyltd.com',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '+234 901 085 3849  •  Port Harcourt, Rivers, Nigeria',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10.5,
                    color: Color.fromRGBO(255, 255, 255, .40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentSection({
    required String eyebrow,
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        color: const Color(0xFF0B162A).withOpacity(.70),
        border: Border.all(color: Colors.white.withOpacity(.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.65,
              color: lightBlue,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11.2,
              height: 1.58,
              color: Colors.white.withOpacity(.44),
            ),
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String eyebrow,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        color: const Color(0xFF0B162A).withOpacity(.72),
        border: Border.all(color: Colors.white.withOpacity(.055)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconTile(icon),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: lightBlue,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11.1,
                    height: 1.58,
                    color: Colors.white.withOpacity(.43),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconTile(IconData icon) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: primaryBlue.withOpacity(.11),
        border: Border.all(color: lightBlue.withOpacity(.10)),
      ),
      child: Icon(icon, size: 21, color: lightBlue),
    );
  }
}

class _CapabilityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _CapabilityTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(.025),
        border: Border.all(color: Colors.white.withOpacity(.055)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF4A6BB8).withOpacity(.10),
            ),
            child: Icon(icon, color: const Color(0xFF75A1FF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10.3,
                    height: 1.48,
                    color: Colors.white.withOpacity(.42),
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
