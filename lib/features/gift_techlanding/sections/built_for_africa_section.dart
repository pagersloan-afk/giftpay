import 'dart:ui';

import 'package:flutter/material.dart';

class BuiltForAfricaSection extends StatelessWidget {
  const BuiltForAfricaSection({super.key});

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF7EA4FF);

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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: EdgeInsets.all(isMobile ? 28 : 60),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _blue.withOpacity(0.11),
                      Colors.white.withOpacity(0.025),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.075)),
                  boxShadow: [
                    BoxShadow(
                      color: _blue.withOpacity(0.055),
                      blurRadius: 70,
                      spreadRadius: -20,
                      offset: const Offset(0, 25),
                    ),
                  ],
                ),
                child: isMobile
                    ? _buildMobile(context)
                    : _buildDesktop(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DESKTOP
  // ---------------------------------------------------------------------------

  Widget _buildDesktop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 6, child: _buildCopy(context)),

        const SizedBox(width: 70),

        Expanded(flex: 4, child: _buildRegionalGrid()),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE
  // ---------------------------------------------------------------------------

  Widget _buildMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCopy(context),

        const SizedBox(height: 40),

        _buildRegionalGrid(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // COPY
  // ---------------------------------------------------------------------------

  Widget _buildCopy(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('BUILT FOR AFRICA'),

        const SizedBox(height: 20),

        Text(
          'Technology shaped by the market we understand.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: isMobile ? 36 : 52,
            height: 1.02,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Africa is not one market. It is a collection of people, '
          'businesses, communities and opportunities moving at different speeds.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: isMobile ? 14 : 15,
            height: 1.7,
            color: Colors.white.withOpacity(0.45),
          ),
        ),

        const SizedBox(height: 15),

        const Text(
          'We build with that complexity in mind.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _highlight,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // REGIONAL GRID
  // ---------------------------------------------------------------------------

  Widget _buildRegionalGrid() {
    final items = [
      (
        Icons.language_outlined,
        'LOCAL CONTEXT',
        'Products designed around real African use cases.',
      ),
      (
        Icons.people_outline_rounded,
        'PEOPLE FIRST',
        'Technology designed to reduce friction.',
      ),
      (
        Icons.trending_up_rounded,
        'GROWTH',
        'Infrastructure built with scale in mind.',
      ),
      (
        Icons.public_outlined,
        'GLOBAL AMBITION',
        'African technology with international standards.',
      ),
    ];

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildRegionalCard(
            icon: item.$1,
            title: item.$2,
            description: item.$3,
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // REGIONAL CARD
  // ---------------------------------------------------------------------------

  Widget _buildRegionalCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: Colors.white.withOpacity(0.025),
          border: Border.all(color: Colors.white.withOpacity(0.055)),
          boxShadow: [
            BoxShadow(
              color: _blue.withOpacity(0.025),
              blurRadius: 30,
              spreadRadius: -10,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _blue.withOpacity(0.14),
                    Colors.white.withOpacity(0.025),
                  ],
                ),
                border: Border.all(color: _highlight.withOpacity(0.08)),
              ),
              child: Icon(icon, size: 18, color: _highlight),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 10,
                      height: 1.4,
                      color: Colors.white.withOpacity(0.34),
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

  // ---------------------------------------------------------------------------
  // SECTION LABEL
  // ---------------------------------------------------------------------------

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'SegoeUI',
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: _highlight,
      ),
    );
  }
}
