import 'dart:ui';

import 'package:flutter/material.dart';

/// Gift Technology — Trust & Security Section
///
/// Parent/orchestrator section for the "Trust / Security" area of the landing
/// page. It is intentionally self-contained:
///
///   const TrustSection()
///
/// Existing safety material emphasizes protecting users, security standards,
/// secure environments, responsible platform use, privacy, and accurate
/// information. This section translates those themes into the landing-page
/// presentation rather than duplicating the dedicated safety-center screen.
class TrustSection extends StatelessWidget {
  const TrustSection({super.key});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF7EA4FF);

  static const List<_TrustPillar> _pillars = [
    _TrustPillar(
      number: '01',
      icon: Icons.shield_outlined,
      title: 'Security-led',
      description:
          'Security is considered as part of the digital experience, not as an afterthought.',
    ),
    _TrustPillar(
      number: '02',
      icon: Icons.lock_outline_rounded,
      title: 'Protect Users',
      description:
          'We design around responsible access, account protection, and safer digital interactions.',
    ),
    _TrustPillar(
      number: '03',
      icon: Icons.verified_user_outlined,
      title: 'Responsible Use',
      description:
          'Our platforms are built to support responsible and appropriate use of digital services.',
    ),
    _TrustPillar(
      number: '04',
      icon: Icons.privacy_tip_outlined,
      title: 'Privacy Minded',
      description:
          'Respect for personal and account information remains part of the trust experience.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 700;
    final isTablet = width >= 700 && width < 1100;

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
              _buildHeader(isMobile: isMobile, isTablet: isTablet),
              SizedBox(height: isMobile ? 34 : 52),
              _buildTrustPanel(isMobile: isMobile, isTablet: isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({required bool isMobile, required bool isTablet}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('TRUST / SECURITY'),
        const SizedBox(height: 18),
        Text(
          'Trust is part of the infrastructure.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: isMobile
                ? 34
                : isTablet
                ? 44
                : 52,
            height: 1.02,
            fontWeight: FontWeight.w700,
            letterSpacing: isMobile ? -1.2 : -2.2,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            'We build digital experiences with security, responsible use, '
            'and user protection at the center.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isMobile ? 16 : 19,
              height: 1.6,
              fontWeight: FontWeight.w300,
              color: _highlight.withOpacity(0.76),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrustPanel({required bool isMobile, required bool isTablet}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 22 : 38),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _navy.withOpacity(0.24),
                Colors.white.withOpacity(0.035),
                _blue.withOpacity(0.045),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.075)),
            boxShadow: [
              BoxShadow(
                color: _navy.withOpacity(0.22),
                blurRadius: 45,
                spreadRadius: -12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTrustIntro(isMobile),
              SizedBox(height: isMobile ? 28 : 36),
              _buildPillars(isMobile: isMobile, isTablet: isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustIntro(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrustBadge(),
          const SizedBox(height: 18),
          _buildIntroText(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildIntroText()),
        const SizedBox(width: 40),
        _buildTrustBadge(),
      ],
    );
  }

  Widget _buildIntroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _smallLabel('OUR TRUST APPROACH'),
        const SizedBox(height: 12),
        const Text(
          'Designed to keep the digital experience dependable.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 27,
            height: 1.15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Trust comes from the combination of secure technology, '
          'responsible platform design, clear standards, and respect for '
          'the people who use our services.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 13.5,
            height: 1.65,
            color: Colors.white.withOpacity(0.43),
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: _blue.withOpacity(0.075),
        border: Border.all(color: _highlight.withOpacity(0.13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 15,
            color: _highlight.withOpacity(0.90),
          ),
          const SizedBox(width: 8),
          Text(
            'TRUST & SAFETY',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
              color: Colors.white.withOpacity(0.68),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillars({required bool isMobile, required bool isTablet}) {
    if (isMobile) {
      return Column(
        children: [
          for (int index = 0; index < _pillars.length; index++) ...[
            _buildPillarCard(_pillars[index], compact: true),
            if (index != _pillars.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _pillars.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 2 : 4,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: isTablet ? 175 : 200,
      ),
      itemBuilder: (context, index) {
        return _buildPillarCard(_pillars[index], compact: false);
      },
    );
  }

  Widget _buildPillarCard(_TrustPillar pillar, {required bool compact}) {
    return Container(
      padding: EdgeInsets.all(compact ? 18 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.025),
        border: Border.all(color: Colors.white.withOpacity(0.065)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: compact ? 44 : 48,
                height: compact ? 44 : 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _blue.withOpacity(0.16),
                      Colors.white.withOpacity(0.025),
                    ],
                  ),
                  border: Border.all(color: _highlight.withOpacity(0.09)),
                ),
                child: Icon(
                  pillar.icon,
                  size: compact ? 19 : 21,
                  color: _highlight,
                ),
              ),
              Text(
                pillar.number,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: Colors.white.withOpacity(0.18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            pillar.title,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: compact ? 15 : 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pillar.description,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: compact ? 11.5 : 12,
              height: 1.55,
              color: Colors.white.withOpacity(0.38),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _highlight,
            boxShadow: [
              BoxShadow(color: _highlight.withOpacity(0.45), blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(width: 10),
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

  Widget _smallLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'SegoeUI',
        fontSize: 8,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.7,
        color: _highlight.withOpacity(0.82),
      ),
    );
  }
}

class _TrustPillar {
  final String number;
  final IconData icon;
  final String title;
  final String description;

  const _TrustPillar({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });
}
