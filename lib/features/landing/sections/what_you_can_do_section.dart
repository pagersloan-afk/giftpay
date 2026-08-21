import 'dart:ui';

import 'package:flutter/material.dart';

/// GiftPay — What You Can Do Section.
///
/// Position in landing flow:
/// 1. Hero
/// 2. Trust
/// 3. What You Can Do
///
/// Purpose:
/// Clearly communicate the everyday services GiftPay is designed to bring
/// together in one digital experience.
///
/// IMPORTANT:
/// Travel, ride-hailing, and partner-powered services are presented as
/// integration capabilities / supported experiences rather than claiming
/// that every provider is already live.
///
/// This section does not:
/// - perform transactions
/// - call APIs
/// - navigate to provider services
/// - control the landing page scroll
/// - own the landing page background
class WhatYouCanDoSection extends StatelessWidget {
  const WhatYouCanDoSection({super.key});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF75A1FF);

  static const List<_ServiceItem> _services = [
    _ServiceItem(
      icon: Icons.account_balance_wallet_outlined,
      eyebrow: 'MONEY',
      title: 'Your GiftPay Wallet',
      description:
          'Keep your everyday digital transactions connected through one '
          'simple wallet experience.',
      status: 'CORE EXPERIENCE',
    ),
    _ServiceItem(
      icon: Icons.swap_horiz_rounded,
      eyebrow: 'TRANSFERS',
      title: 'Send & receive money',
      description:
          'Move money conveniently for everyday payments, personal needs, '
          'and supported digital transactions.',
      status: 'CORE EXPERIENCE',
    ),
    _ServiceItem(
      icon: Icons.phone_android_rounded,
      eyebrow: 'CONNECTIVITY',
      title: 'Airtime & Data',
      description:
          'Recharge airtime and data when you need to stay connected, '
          'without leaving your GiftPay experience.',
      status: 'DIGITAL SERVICE',
    ),
    _ServiceItem(
      icon: Icons.bolt_rounded,
      eyebrow: 'UTILITIES',
      title: 'Electricity & Bills',
      description:
          'Access supported utility services and manage everyday digital '
          'bill payments from one connected platform.',
      status: 'DIGITAL SERVICE',
    ),
    _ServiceItem(
      icon: Icons.card_giftcard_rounded,
      eyebrow: 'SHOPPING',
      title: 'Gift Cards',
      description:
          'Discover supported digital gift cards for gifting, shopping, '
          'and everyday digital purchases.',
      status: 'DIGITAL COMMERCE',
    ),
    _ServiceItem(
      icon: Icons.directions_car_filled_outlined,
      eyebrow: 'MOBILITY',
      title: 'Ride Booking',
      description:
          'GiftPay is being designed to connect users with supported ride '
          'services through integrated mobility partners.',
      status: 'PARTNER INTEGRATIONS',
      comingSoon: true,
    ),
    _ServiceItem(
      icon: Icons.flight_takeoff_rounded,
      eyebrow: 'TRAVEL',
      title: 'Flight Booking',
      description:
          'Search and book supported flights through integrated travel '
          'providers as GiftPay expands its travel ecosystem.',
      status: 'TRAVEL INTEGRATIONS',
      comingSoon: true,
    ),
    _ServiceItem(
      icon: Icons.apps_rounded,
      eyebrow: 'ECOSYSTEM',
      title: 'More digital services',
      description:
          'GiftPay is built to connect additional useful services as new '
          'partners and integrations become available.',
      status: 'EXPANDING',
      comingSoon: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool isMobile = width < 700;
    final bool isTablet = width >= 700 && width < 1050;

    final double horizontalPadding = isMobile
        ? 20
        : isTablet
        ? 34
        : 64;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 72 : 96,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeading(isMobile),

              SizedBox(height: isMobile ? 30 : 44),

              _buildIntroPanel(isMobile),

              SizedBox(height: isMobile ? 24 : 30),

              _buildServicesGrid(isMobile: isMobile, isTablet: isTablet),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADING
  // ===========================================================================

  Widget _buildHeading(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('WHAT YOU CAN DO'),

        const SizedBox(height: 16),

        Text(
          'More of everyday life, in one place.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: isMobile ? 33 : 51,
            height: 1.05,
            fontWeight: FontWeight.w800,
            letterSpacing: isMobile ? -1.2 : -2.2,
            color: _navy,
          ),
        ),

        const SizedBox(height: 12),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            'Pay, transfer, recharge, shop, move, travel, and access '
            'supported digital services without constantly switching '
            'between different experiences.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isMobile ? 15 : 18,
              height: 1.65,
              fontWeight: FontWeight.w400,
              color: _navy.withOpacity(0.58),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // INTRO PANEL
  // ===========================================================================

  Widget _buildIntroPanel(bool isMobile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isMobile ? 24 : 30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 20 : 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMobile ? 24 : 30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _navy.withOpacity(0.96),
                _blue.withOpacity(0.94),
                const Color(0xFF182A4A).withOpacity(0.98),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: _navy.withOpacity(0.16),
                blurRadius: 38,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _introIcon(),
                    const SizedBox(height: 18),
                    _introCopy(),
                  ],
                )
              : Row(
                  children: [
                    _introIcon(),
                    const SizedBox(width: 20),
                    Expanded(child: _introCopy()),
                    const SizedBox(width: 30),
                    _serviceCounter(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _introIcon() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.075),
        border: Border.all(color: _highlight.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(color: _highlight.withOpacity(0.10), blurRadius: 25),
        ],
      ),
      child: const Icon(Icons.grid_view_rounded, size: 27, color: _highlight),
    );
  }

  Widget _introCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ONE CONNECTED EXPERIENCE',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
            color: _highlight,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Everyday services, connected around you.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 20,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'GiftPay brings core payment experiences together with '
          'useful digital services and an expanding partner ecosystem.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.5,
            height: 1.55,
            color: Colors.white.withOpacity(0.60),
          ),
        ),
      ],
    );
  }

  Widget _serviceCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.055),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SERVICES & EXPERIENCES',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
              color: Colors.white.withOpacity(0.38),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '08',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 25,
              height: 1,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SERVICES GRID
  // ===========================================================================

  Widget _buildServicesGrid({required bool isMobile, required bool isTablet}) {
    if (isMobile) {
      return Column(
        children: _services
            .map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ServiceCard(service: service),
              ),
            )
            .toList(),
      );
    }

    final int columns = isTablet ? 2 : 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _services.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 13,
        mainAxisSpacing: 13,
        mainAxisExtent: 238,
      ),
      itemBuilder: (_, index) {
        return _ServiceCard(service: _services[index]);
      },
    );
  }

  // ===========================================================================
  // SECTION LABEL
  // ===========================================================================

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
            letterSpacing: 1.9,
            color: _blue,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SERVICE DATA MODEL
// ============================================================================

class _ServiceItem {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final String status;
  final bool comingSoon;

  const _ServiceItem({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.status,
    this.comingSoon = false,
  });
}

// ============================================================================
// SERVICE CARD
// ============================================================================

class _ServiceCard extends StatefulWidget {
  final _ServiceItem service;

  const _ServiceCard({required this.service});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (mounted) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _hovered = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -5 : 0, 0),
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: _hovered
              ? Colors.white.withOpacity(0.80)
              : Colors.white.withOpacity(0.54),
          border: Border.all(
            color: _hovered
                ? _highlight.withOpacity(0.20)
                : _navy.withOpacity(0.065),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: _blue.withOpacity(0.11),
                    blurRadius: 27,
                    offset: const Offset(0, 12),
                  ),
                ]
              : [
                  BoxShadow(
                    color: _navy.withOpacity(0.025),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------------------------------
            // TOP ROW
            // -----------------------------------------------------------------
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _blue.withOpacity(_hovered ? 0.18 : 0.10),
                        _highlight.withOpacity(_hovered ? 0.11 : 0.045),
                      ],
                    ),
                    border: Border.all(
                      color: _highlight.withOpacity(_hovered ? 0.22 : 0.10),
                    ),
                  ),
                  child: Icon(widget.service.icon, size: 21, color: _blue),
                ),

                const Spacer(),

                if (widget.service.comingSoon)
                  _statusBadge(label: 'COMING SOON', highlighted: true),
              ],
            ),

            const Spacer(),

            // -----------------------------------------------------------------
            // CATEGORY
            // -----------------------------------------------------------------
            Text(
              widget.service.eyebrow,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.55,
                color: _blue.withOpacity(0.66),
              ),
            ),

            const SizedBox(height: 6),

            // -----------------------------------------------------------------
            // TITLE
            // -----------------------------------------------------------------
            Text(
              widget.service.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 15.5,
                height: 1.15,
                fontWeight: FontWeight.w800,
                color: _navy,
              ),
            ),

            const SizedBox(height: 7),

            // -----------------------------------------------------------------
            // DESCRIPTION
            // -----------------------------------------------------------------
            Text(
              widget.service.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 10.8,
                height: 1.45,
                color: _navy.withOpacity(0.50),
              ),
            ),

            const SizedBox(height: 12),

            // -----------------------------------------------------------------
            // STATUS
            // -----------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.service.status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: _navy.withOpacity(0.34),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: _blue.withOpacity(_hovered ? 0.85 : 0.38),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge({required String label, required bool highlighted}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: highlighted
            ? _blue.withOpacity(0.08)
            : Colors.white.withOpacity(0.08),
        border: Border.all(
          color: highlighted
              ? _highlight.withOpacity(0.16)
              : Colors.white.withOpacity(0.10),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'SegoeUI',
          fontSize: 6.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: highlighted
              ? _blue.withOpacity(0.72)
              : _navy.withOpacity(0.40),
        ),
      ),
    );
  }
}
