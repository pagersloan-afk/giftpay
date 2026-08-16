import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

/// Premium Developer Hub screen for Gift Technology Ltd.
///
/// The existing Community & Ecosystem section describes Developer Hub as:
/// "API docs, SDKs, sandbox tools, and integration guides."
///
/// This screen elevates those existing developer resources visually without
/// inventing API capabilities, endpoints, authentication methods, pricing,
/// limits, certifications, or unsupported technical guarantees.
class DevelopersScreen extends StatelessWidget {
  const DevelopersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      title: 'Developer Hub',
      description:
          'API docs, SDKs, sandbox tools, and integration guides for building with Gift Technology.',
      child: const _DeveloperHubContent(),
    );
  }
}

class _DeveloperHubContent extends StatelessWidget {
  const _DeveloperHubContent();

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
          _buildDeveloperHero(isMobile),
          const SizedBox(height: 20),
          _buildDeveloperGrid(isMobile),
          const SizedBox(height: 20),
          _buildDeveloperPanel(isMobile),
        ],
      ),
    );
  }

  Widget _buildDeveloperHero(bool isMobile) {
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
                _buildCodeOrb(),
                const SizedBox(height: 20),
                _buildHeroCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCodeOrb(),
                const SizedBox(width: 22),
                Expanded(child: _buildHeroCopy()),
                const SizedBox(width: 24),
                _buildDeveloperBadge(),
              ],
            ),
    );
  }

  Widget _buildCodeOrb() {
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
      child: const Icon(Icons.code_rounded, color: _electricBlue, size: 31),
    );
  }

  Widget _buildHeroCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GIFT TECHNOLOGY / DEVELOPER ECOSYSTEM',
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
          'Developer Hub',
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
          'Everything developers need to explore, integrate, and build with '
          'Gift Technology — presented in one focused technical workspace.',
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

  Widget _buildDeveloperBadge() {
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
          const Icon(Icons.terminal_rounded, color: _electricBlue, size: 15),
          const SizedBox(width: 8),
          Text(
            'BUILD / INTEGRATE / SCALE',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.25,
              color: Colors.white.withOpacity(0.68),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperGrid(bool isMobile) {
    const resources = [
      (
        number: '01',
        title: 'API Documentation',
        text:
            'Explore the technical documentation that supports integrations with Gift Technology.',
        icon: Icons.menu_book_outlined,
      ),
      (
        number: '02',
        title: 'SDKs',
        text:
            'Developer tools designed to make building and integrating more straightforward.',
        icon: Icons.extension_outlined,
      ),
      (
        number: '03',
        title: 'Sandbox Tools',
        text:
            'A dedicated space for developers to explore integrations in a controlled environment.',
        icon: Icons.science_outlined,
      ),
      (
        number: '04',
        title: 'Integration Guides',
        text:
            'Step-by-step guidance for understanding and connecting technology across the ecosystem.',
        icon: Icons.integration_instructions_outlined,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: resources.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: isMobile ? 144 : 156,
      ),
      itemBuilder: (context, index) {
        final item = resources[index];

        return _DeveloperCard(
          number: item.number,
          title: item.title,
          text: item.text,
          icon: item.icon,
        );
      },
    );
  }

  Widget _buildDeveloperPanel(bool isMobile) {
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
              Icons.data_object_rounded,
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
                  'Build with clarity',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bring documentation, developer tools, sandbox resources, and integration guidance '
                  'together in one technical experience designed for the people building on our ecosystem.',
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

class _DeveloperCard extends StatefulWidget {
  final String number;
  final String title;
  final String text;
  final IconData icon;

  const _DeveloperCard({
    required this.number,
    required this.title,
    required this.text,
    required this.icon,
  });

  @override
  State<_DeveloperCard> createState() => _DeveloperCardState();
}

class _DeveloperCardState extends State<_DeveloperCard> {
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
