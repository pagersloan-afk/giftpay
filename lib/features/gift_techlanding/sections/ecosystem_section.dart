import 'dart:ui';

import 'package:flutter/material.dart';

class EcosystemSection extends StatefulWidget {
  const EcosystemSection({super.key});

  @override
  State<EcosystemSection> createState() => _EcosystemSectionState();
}

class _EcosystemSectionState extends State<EcosystemSection> {
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF7EA4FF);

  int _hoveredIndex = -1;

  final List<_EcosystemItem> _items = const [
    _EcosystemItem(
      icon: Icons.account_balance_wallet_outlined,
      number: '01',
      title: 'Payments',
      description:
          'Digital payment experiences designed to make everyday transactions simpler, faster and more connected.',
    ),
    _EcosystemItem(
      icon: Icons.storefront_outlined,
      number: '02',
      title: 'Commerce',
      description:
          'Technology that helps businesses operate, transact and serve their customers through modern digital channels.',
    ),
    _EcosystemItem(
      icon: Icons.bolt_outlined,
      number: '03',
      title: 'Utilities',
      description:
          'Connected access to essential digital services through convenient and intelligent platforms.',
    ),
    _EcosystemItem(
      icon: Icons.hub_outlined,
      number: '04',
      title: 'Digital Platforms',
      description:
          'Purpose-built platforms connecting people, organizations and digital services across one ecosystem.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 700;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 64,
        vertical: isMobile ? 75 : 110,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionIntro(isMobile),

              const SizedBox(height: 48),

              _buildGrid(isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionIntro(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('THE ECOSYSTEM'),

        const SizedBox(height: 18),

        Text(
          'One technology ecosystem.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: isMobile ? 34 : 52,
            height: 1.0,
            fontWeight: FontWeight.w700,
            letterSpacing: isMobile ? -1.1 : -2.1,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Built around the way Africa lives, works and connects.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: isMobile ? 17 : 22,
            fontWeight: FontWeight.w300,
            color: _highlight.withOpacity(0.86),
          ),
        ),

        const SizedBox(height: 18),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            'Gift Technology brings payments, commerce, utilities and digital platforms together into a connected technology ecosystem.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isMobile ? 13.5 : 15,
              height: 1.7,
              color: Colors.white.withOpacity(0.43),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(bool isMobile) {
    if (isMobile) {
      return Column(
        children: List.generate(
          _items.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCard(_items[index], index, true),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 1.75,
      ),
      itemBuilder: (context, index) {
        return _buildCard(_items[index], index, false);
      },
    );
  }

  Widget _buildCard(_EcosystemItem item, int index, bool isMobile) {
    final hovered = _hoveredIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) {
        setState(() => _hoveredIndex = index);
      },
      onExit: (_) {
        setState(() => _hoveredIndex = -1);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.identity()..translate(0.0, hovered ? -5.0 : 0.0),
        padding: EdgeInsets.all(isMobile ? 20 : 26),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: hovered
              ? Colors.white.withOpacity(0.045)
              : Colors.white.withOpacity(0.025),
          border: Border.all(
            color: hovered
                ? _highlight.withOpacity(0.14)
                : Colors.white.withOpacity(0.065),
          ),
          boxShadow: hovered
              ? [
                  BoxShadow(
                    color: _blue.withOpacity(0.10),
                    blurRadius: 35,
                    offset: const Offset(0, 15),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: _blue.withOpacity(0.08),
                    border: Border.all(color: Colors.white.withOpacity(0.07)),
                  ),
                  child: Icon(
                    item.icon,
                    size: 20,
                    color: _highlight.withOpacity(0.82),
                  ),
                ),

                const SizedBox(width: 17),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.number,
                            style: TextStyle(
                              fontFamily: 'SegoeUI',
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: _highlight.withOpacity(0.60),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontFamily: 'SegoeUI',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 9),

                      Text(
                        item.description,
                        style: TextStyle(
                          fontFamily: 'SegoeUI',
                          fontSize: 12,
                          height: 1.55,
                          color: Colors.white.withOpacity(0.40),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _highlight,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: _highlight,
          ),
        ),
      ],
    );
  }
}

class _EcosystemItem {
  final IconData icon;
  final String number;
  final String title;
  final String description;

  const _EcosystemItem({
    required this.icon,
    required this.number,
    required this.title,
    required this.description,
  });
}
