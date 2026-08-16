import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

/// Premium Safety Center screen for Gift Technology Ltd.
///
/// Source-backed description:
/// "Learn how we protect users, enforce safety standards, and maintain
/// secure digital environments."
///
/// This screen focuses on the presentation of those three themes without
/// inventing specific security controls, certifications, reporting SLAs,
/// policies, or regulatory claims that are not present in the source.
class SafetyCenterScreen extends StatelessWidget {
  const SafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      title: 'Safety Center',
      description:
          'Learn how we protect users, enforce safety standards, and maintain secure digital environments.',
      child: const _SafetyCenterContent(),
    );
  }
}

class _SafetyCenterContent extends StatelessWidget {
  const _SafetyCenterContent();

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _electricBlue = Color(0xFF5D8FFF);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSecurityHero(isMobile),
          const SizedBox(height: 20),
          _buildSafetyPillars(isMobile),
          const SizedBox(height: 20),
          _buildSecurityPanel(isMobile),
        ],
      ),
    );
  }

  Widget _buildSecurityHero(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.085),
            _blue.withOpacity(0.065),
            Colors.white.withOpacity(0.025),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.10),
            blurRadius: 44,
            spreadRadius: 2,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShieldOrb(),
                const SizedBox(height: 20),
                _buildHeroCopy(),
              ],
            )
          : Row(
              children: [
                _buildShieldOrb(),
                const SizedBox(width: 22),
                Expanded(child: _buildHeroCopy()),
                const SizedBox(width: 24),
                _buildSecurityBadge(),
              ],
            ),
    );
  }

  Widget _buildShieldOrb() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withOpacity(0.14), _blue.withOpacity(0.13)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.13)),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.18),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.shield_rounded, color: _electricBlue, size: 31),
    );
  }

  Widget _buildHeroCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GIFT TECHNOLOGY / TRUST & SAFETY',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: _electricBlue.withOpacity(0.95),
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Safety Center',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Our safety experience is built around protecting users, '
          'maintaining secure digital environments, and supporting responsible platform use.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 14,
            height: 1.55,
            color: Colors.white.withOpacity(0.60),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: _blue.withOpacity(0.075),
        border: Border.all(color: _blue.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _electricBlue,
              boxShadow: [
                BoxShadow(
                  color: _electricBlue.withOpacity(0.45),
                  blurRadius: 9,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'TRUST & SAFETY',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
              color: Colors.white.withOpacity(0.68),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyPillars(bool isMobile) {
    const pillars = [
      (
        number: '01',
        title: 'Protect Users',
        text:
            'A safety-first approach focused on protecting people across the digital experience.',
        icon: Icons.person_outline_rounded,
      ),
      (
        number: '02',
        title: 'Safety Standards',
        text:
            'Clear standards help support responsible use of Gift Technology platforms.',
        icon: Icons.rule_rounded,
      ),
      (
        number: '03',
        title: 'Secure Environments',
        text:
            'Security is part of maintaining trusted digital environments for our users.',
        icon: Icons.lock_outline_rounded,
      ),
      (
        number: '04',
        title: 'Responsible Platform Use',
        text:
            'Safety works alongside responsible product design and platform governance.',
        icon: Icons.verified_user_outlined,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pillars.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: isMobile ? 142 : 154,
      ),
      itemBuilder: (context, index) {
        final item = pillars[index];

        return _SafetyCard(
          number: item.number,
          title: item.title,
          text: item.text,
          icon: item.icon,
        );
      },
    );
  }

  Widget _buildSecurityPanel(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.045),
        border: Border.all(color: Colors.white.withOpacity(0.085)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _blue.withOpacity(0.10),
              border: Border.all(color: _blue.withOpacity(0.18)),
            ),
            child: const Icon(
              Icons.security_rounded,
              color: _electricBlue,
              size: 21,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trust is part of the product',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Security and safety should feel intentional at every point of the digital journey. '
                  'Use this space to surface the complete Gift Technology safety guidance and resources.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 13,
                    height: 1.55,
                    color: Colors.white.withOpacity(0.55),
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

class _SafetyCard extends StatefulWidget {
  final String number;
  final String title;
  final String text;
  final IconData icon;

  const _SafetyCard({
    required this.number,
    required this.title,
    required this.text,
    required this.icon,
  });

  @override
  State<_SafetyCard> createState() => _SafetyCardState();
}

class _SafetyCardState extends State<_SafetyCard> {
  bool _hovered = false;

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _electricBlue = Color(0xFF5D8FFF);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(_hovered ? 0.085 : 0.065),
              Colors.white.withOpacity(0.025),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(_hovered ? 0.15 : 0.085),
          ),
          boxShadow: [
            BoxShadow(
              color: _blue.withOpacity(_hovered ? 0.14 : 0.055),
              blurRadius: _hovered ? 30 : 20,
              offset: const Offset(0, 12),
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
                borderRadius: BorderRadius.circular(14),
                color: _blue.withOpacity(0.10),
                border: Border.all(color: _blue.withOpacity(0.16)),
              ),
              child: Icon(widget.icon, size: 20, color: _electricBlue),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.number,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: _electricBlue.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 12.5,
                      height: 1.45,
                      color: Colors.white.withOpacity(0.50),
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
