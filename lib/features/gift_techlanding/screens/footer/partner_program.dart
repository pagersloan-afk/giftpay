import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

/// Premium Partner Program screen for Gift Technology Ltd.
///
/// The supplied source describes the page as:
/// "Join our partner ecosystem and collaborate on digital transformation
/// across Africa."
///
/// The visual content below expands that framing without inventing partner
/// tiers, commercial terms, eligibility requirements, certifications, or
/// program benefits that are not present in the supplied source.
class PartnerProgramScreen extends StatelessWidget {
  const PartnerProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      title: 'Partner Program',
      description:
          'Join our partner ecosystem and collaborate on digital transformation across Africa.',
      child: const _PartnerProgramContent(),
    );
  }
}

class _PartnerProgramContent extends StatelessWidget {
  const _PartnerProgramContent();

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
          _buildPartnerHero(isMobile),
          const SizedBox(height: 20),
          _buildCollaborationGrid(isMobile),
          const SizedBox(height: 20),
          _buildEcosystemPanel(isMobile),
        ],
      ),
    );
  }

  Widget _buildPartnerHero(bool isMobile) {
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
                _buildPartnerOrb(),
                const SizedBox(height: 20),
                _buildHeroCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildPartnerOrb(),
                const SizedBox(width: 22),
                Expanded(child: _buildHeroCopy()),
                const SizedBox(width: 24),
                _buildPartnerBadge(),
              ],
            ),
    );
  }

  Widget _buildPartnerOrb() {
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
      child: const Icon(Icons.hub_outlined, color: _electricBlue, size: 31),
    );
  }

  Widget _buildHeroCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GIFT TECHNOLOGY / PARTNER ECOSYSTEM',
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
          'Partner Program',
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
          'Connect with Gift Technology and collaborate on digital transformation '
          'across Africa through a growing technology ecosystem.',
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

  Widget _buildPartnerBadge() {
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
          const Icon(Icons.public_rounded, color: _electricBlue, size: 15),
          const SizedBox(width: 8),
          Text(
            'AFRICA / DIGITAL TRANSFORMATION',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: Colors.white.withOpacity(0.68),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaborationGrid(bool isMobile) {
    const pillars = [
      (
        number: '01',
        title: 'Partner Ecosystem',
        text:
            'Become part of an ecosystem built around collaboration and digital transformation.',
        icon: Icons.account_tree_outlined,
      ),
      (
        number: '02',
        title: 'Collaboration',
        text:
            'Work alongside Gift Technology to explore opportunities for meaningful digital collaboration.',
        icon: Icons.handshake_outlined,
      ),
      (
        number: '03',
        title: 'Digital Transformation',
        text:
            'Contribute to technology-led transformation and the continued evolution of Africa’s digital landscape.',
        icon: Icons.auto_graph_rounded,
      ),
      (
        number: '04',
        title: 'Shared Direction',
        text:
            'Bring complementary capabilities together around a shared ambition for digital progress.',
        icon: Icons.compare_arrows_rounded,
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
        mainAxisExtent: isMobile ? 144 : 156,
      ),
      itemBuilder: (context, index) {
        final item = pillars[index];

        return _PartnerCard(
          number: item.number,
          title: item.title,
          text: item.text,
          icon: item.icon,
        );
      },
    );
  }

  Widget _buildEcosystemPanel(bool isMobile) {
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
              Icons.rocket_launch_outlined,
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
                  'Build what comes next',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Partnerships can bring technology, expertise, and new ideas together. '
                  'This program provides the foundation for collaboration around digital transformation across Africa.',
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

class _PartnerCard extends StatefulWidget {
  final String number;
  final String title;
  final String text;
  final IconData icon;

  const _PartnerCard({
    required this.number,
    required this.title,
    required this.text,
    required this.icon,
  });

  @override
  State<_PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends State<_PartnerCard> {
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
