import 'dart:ui';

import 'package:flutter/material.dart';

/// Gift Technology — Businesses Section
///
/// Parent/orchestrator section for the "For Businesses" area of the landing
/// page. This file intentionally owns its internal cards so the landing page
/// only needs to call:
///
///   const BusinessesSection()
///
/// The section follows the existing Gift Technology visual language:
/// deep navy, soft blue, restrained glassmorphism, SegoeUI typography,
/// responsive desktop/tablet/mobile layouts.
class BusinessesSection extends StatelessWidget {
  const BusinessesSection({super.key});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF7EA4FF);

  static const List<_BusinessCapability> _capabilities = [
    _BusinessCapability(
      icon: Icons.payments_outlined,
      title: 'Accept Payments',
      description:
          'Give customers convenient digital payment experiences across connected channels.',
    ),
    _BusinessCapability(
      icon: Icons.storefront_outlined,
      title: 'Power Commerce',
      description:
          'Technology that helps modern businesses operate, sell, and serve customers more efficiently.',
    ),
    _BusinessCapability(
      icon: Icons.hub_outlined,
      title: 'Connect Services',
      description:
          'Bring payments, utilities, data, and digital services together through connected infrastructure.',
    ),
    _BusinessCapability(
      icon: Icons.insights_outlined,
      title: 'Scale Digitally',
      description:
          'Build on technology designed to support growing businesses and evolving digital operations.',
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
              _buildBusinessPanel(isMobile: isMobile, isTablet: isTablet),
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
        _sectionLabel('FOR BUSINESSES'),
        const SizedBox(height: 18),
        Text(
          'Technology that works for business.',
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
            'Digital tools and infrastructure designed to help businesses '
            'accept payments, connect services, serve customers, and grow.',
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

  Widget _buildBusinessPanel({required bool isMobile, required bool isTablet}) {
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
                Colors.white.withOpacity(0.055),
                _blue.withOpacity(0.045),
                Colors.white.withOpacity(0.018),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.075)),
            boxShadow: [
              BoxShadow(
                color: _navy.withOpacity(0.20),
                blurRadius: 45,
                spreadRadius: -12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMobile) _buildPanelIntro() else _buildMobileIntro(),
              SizedBox(height: isMobile ? 28 : 36),
              _buildCapabilityGrid(isMobile: isMobile, isTablet: isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanelIntro() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _smallLabel('BUSINESS INFRASTRUCTURE'),
              const SizedBox(height: 12),
              const Text(
                'Built around the way businesses actually operate.',
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
                'From everyday transactions to connected digital services, '
                'Gift Technology provides practical infrastructure for the '
                'modern African business.',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 13.5,
                  height: 1.65,
                  color: Colors.white.withOpacity(0.43),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        _buildBusinessBadge(),
      ],
    );
  }

  Widget _buildMobileIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _smallLabel('BUSINESS INFRASTRUCTURE'),
        const SizedBox(height: 12),
        const Text(
          'Built around the way businesses actually operate.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 23,
            height: 1.18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'From everyday transactions to connected digital services, '
          'Gift Technology provides practical infrastructure for the '
          'modern African business.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 13,
            height: 1.6,
            color: Colors.white.withOpacity(0.43),
          ),
        ),
        const SizedBox(height: 20),
        _buildBusinessBadge(),
      ],
    );
  }

  Widget _buildBusinessBadge() {
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
            Icons.business_center_outlined,
            size: 15,
            color: _highlight.withOpacity(0.90),
          ),
          const SizedBox(width: 8),
          Text(
            'BUILT FOR BUSINESS',
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

  Widget _buildCapabilityGrid({
    required bool isMobile,
    required bool isTablet,
  }) {
    if (isMobile) {
      return Column(
        children: [
          for (int index = 0; index < _capabilities.length; index++) ...[
            _buildCapabilityCard(_capabilities[index], compact: true),
            if (index != _capabilities.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    final columns = isTablet ? 2 : 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _capabilities.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: isTablet ? 180 : 205,
      ),
      itemBuilder: (context, index) {
        return _buildCapabilityCard(_capabilities[index], compact: false);
      },
    );
  }

  Widget _buildCapabilityCard(
    _BusinessCapability capability, {
    required bool compact,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: Container(
        padding: EdgeInsets.all(compact ? 18 : 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.025),
          border: Border.all(color: Colors.white.withOpacity(0.065)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                capability.icon,
                size: compact ? 19 : 21,
                color: _highlight,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              capability.title,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: compact ? 15 : 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              capability.description,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: compact ? 11.5 : 12,
                height: 1.55,
                color: Colors.white.withOpacity(0.38),
              ),
            ),
          ],
        ),
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

class _BusinessCapability {
  final IconData icon;
  final String title;
  final String description;

  const _BusinessCapability({
    required this.icon,
    required this.title,
    required this.description,
  });
}
