import 'dart:async';

import 'package:flutter/material.dart';

/// GiftPay Feature / Services Carousel
///
/// Production goals:
/// - Premium fintech visual language
/// - Responsive desktop / tablet / mobile layout
/// - Seamless automatic horizontal movement
/// - No visible jump when the carousel loops
/// - Hover interaction on web / desktop
/// - Auto-scroll pauses while the user interacts
/// - Strong typography and hierarchy
/// - Typed service model instead of dynamic maps
/// - No RenderFlex overflow inside service cards
///
/// This section does not control page scrolling or global navigation.
class FeatureCardsSection extends StatefulWidget {
  const FeatureCardsSection({super.key});

  @override
  State<FeatureCardsSection> createState() => _FeatureCardsSectionState();
}

class _FeatureCardsSectionState extends State<FeatureCardsSection> {
  // ===========================================================================
  // THEME
  // ===========================================================================

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF7EA4FF);
  static const Color _surface = Color(0xFFF7F9FC);

  // ===========================================================================
  // CONTROLLER
  // ===========================================================================

  final ScrollController _scrollController = ScrollController();

  Timer? _autoScrollTimer;

  bool _isPointerInside = false;
  bool _isUserDragging = false;

  // ===========================================================================
  // SERVICES
  // ===========================================================================

  static const List<_GiftPayService> _services = [
    _GiftPayService(
      title: 'Electricity',
      category: 'UTILITIES',
      subtitle: 'Buy prepaid electricity and receive your token digitally.',
      icon: Icons.bolt_rounded,
      iconColor: Color(0xFFE5A900),
      route: '/electricity',
    ),
    _GiftPayService(
      title: 'Airtime',
      category: 'MOBILE',
      subtitle: 'Top up supported mobile networks directly from GiftPay.',
      icon: Icons.phone_android_rounded,
      iconColor: Color(0xFF4A78D0),
      route: '/airtime',
    ),
    _GiftPayService(
      title: 'Data',
      category: 'MOBILE',
      subtitle: 'Purchase data bundles and manage your connectivity.',
      icon: Icons.wifi_rounded,
      iconColor: Color(0xFF3D9B70),
      route: '/data',
    ),
    _GiftPayService(
      title: 'Gift Cards',
      category: 'COMMERCE',
      subtitle: 'Access digital gift cards for everyday purchases.',
      icon: Icons.card_giftcard_rounded,
      iconColor: Color(0xFF8458C9),
      route: '/giftcards',
    ),
    _GiftPayService(
      title: 'Cable TV',
      category: 'ENTERTAINMENT',
      subtitle: 'Renew supported TV subscriptions without leaving GiftPay.',
      icon: Icons.tv_rounded,
      iconColor: Color(0xFFD65A5A),
      route: '/cable',
    ),
    _GiftPayService(
      title: 'Flight Booking',
      category: 'TRAVEL',
      subtitle: 'Discover and book local and international flights.',
      icon: Icons.flight_takeoff_rounded,
      iconColor: Color(0xFF4D7ED1),
      route: '/aviation',
    ),
    _GiftPayService(
      title: 'Ride Booking',
      category: 'MOBILITY',
      subtitle: 'Access supported ride services directly through GiftPay.',
      icon: Icons.local_taxi_rounded,
      iconColor: Color(0xFFE1A832),
      route: '/rides',
    ),
    _GiftPayService(
      title: 'Betting',
      category: 'DIGITAL',
      subtitle: 'Fund supported betting platforms from one account.',
      icon: Icons.sports_soccer_rounded,
      iconColor: Color(0xFFE87932),
      route: '/betting',
    ),
    _GiftPayService(
      title: 'Gaming',
      category: 'GAMING',
      subtitle: 'Purchase gaming credits and supported digital top-ups.',
      icon: Icons.sports_esports_rounded,
      iconColor: Color(0xFF7055C9),
      route: '/psgames',
    ),
    _GiftPayService(
      title: 'Internet',
      category: 'CONNECTIVITY',
      subtitle: 'Manage supported internet and digital utility services.',
      icon: Icons.router_rounded,
      iconColor: Color(0xFF3D938B),
      route: '/electricity',
    ),
    _GiftPayService(
      title: 'Health',
      category: 'LIFESTYLE',
      subtitle: 'Explore connected health and wellness services.',
      icon: Icons.health_and_safety_rounded,
      iconColor: Color(0xFFD45A67),
      route: '/settings',
    ),
    _GiftPayService(
      title: 'Savings',
      category: 'FINANCE',
      subtitle: 'Access savings-focused financial experiences.',
      icon: Icons.savings_rounded,
      iconColor: Color(0xFF536DB5),
      route: '/savings',
    ),
  ];

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // AUTO SCROLL
  // ===========================================================================

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();

    _autoScrollTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _performAutoScroll(),
    );
  }

  void _performAutoScroll() {
    if (!mounted) return;
    if (!_scrollController.hasClients) return;

    // Pause when the user is interacting with the carousel.
    if (_isPointerInside || _isUserDragging) {
      return;
    }

    final ScrollPosition position = _scrollController.position;

    if (!position.hasContentDimensions) {
      return;
    }

    final double maxExtent = position.maxScrollExtent;

    if (maxExtent <= 0) {
      return;
    }

    final double currentOffset = _scrollController.offset;

    // Two identical copies are rendered.
    //
    // Once the first complete sequence has passed, move back by exactly
    // one sequence width. Since the second sequence is identical to the
    // first, the reset is visually seamless.
    final double loopPoint = _getLoopPoint();

    if (loopPoint > 0 && currentOffset >= loopPoint) {
      final double resetOffset = currentOffset - loopPoint;

      if (resetOffset >= 0 && resetOffset <= maxExtent) {
        _scrollController.jumpTo(resetOffset);
      }

      return;
    }

    // Slow premium movement.
    const double pixelsPerFrame = 0.55;

    final double nextOffset = currentOffset + pixelsPerFrame;

    if (nextOffset < maxExtent) {
      _scrollController.jumpTo(nextOffset);
    }
  }

  double _getLoopPoint() {
    final double width = MediaQuery.sizeOf(context).width;

    final bool isMobile = width < 700;

    final double cardWidth = isMobile ? 188 : 235;

    const double spacing = 16;

    return _services.length * (cardWidth + spacing);
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    final bool isMobile = width < 700;
    final bool isTablet = width >= 700 && width < 1100;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? 18
            : isTablet
            ? 34
            : 64,
        vertical: isMobile ? 64 : 88,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile),
              SizedBox(height: isMobile ? 28 : 38),
              _buildCarouselShell(context, isMobile: isMobile),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('THE GIFTPAY ECOSYSTEM'),

        const SizedBox(height: 14),

        Text(
          'More of what you need, in one place.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: isMobile ? 32 : 48,
            height: 1.06,
            fontWeight: FontWeight.w800,
            letterSpacing: isMobile ? -1.1 : -2.0,
            color: _navy,
          ),
        ),

        const SizedBox(height: 12),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            'From everyday payments and utilities to travel, mobility, '
            'digital commerce and financial services, GiftPay is designed '
            'to bring more of your digital life together.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isMobile ? 15 : 18,
              height: 1.65,
              fontWeight: FontWeight.w400,
              color: _navy.withOpacity(.58),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // CAROUSEL SHELL
  // ===========================================================================

  Widget _buildCarouselShell(BuildContext context, {required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 18 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isMobile ? 24 : 30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, _surface, _blue.withOpacity(.045)],
        ),
        border: Border.all(color: _navy.withOpacity(.07)),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(.06),
            blurRadius: 35,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 26),
            child: Row(
              children: [
                _miniLabel('EXPLORE SERVICES'),

                const Spacer(),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swipe_rounded,
                      size: 16,
                      color: _blue.withOpacity(.50),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Scroll to explore',
                      style: TextStyle(
                        fontFamily: 'SegoeUI',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _navy.withOpacity(.38),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 17),

          _buildCarousel(context, isMobile: isMobile),
        ],
      ),
    );
  }

  // ===========================================================================
  // CAROUSEL
  // ===========================================================================

  Widget _buildCarousel(BuildContext context, {required bool isMobile}) {
    // -------------------------------------------------------------------------
    // IMPORTANT OVERFLOW FIX
    //
    // The previous desktop card height of 190px was too tight for:
    // - 20px padding
    // - 48px icon
    // - category
    // - title
    // - two-line description
    // - Explore action
    // - vertical spacing
    //
    // This production version gives the card enough vertical breathing room.
    // -------------------------------------------------------------------------

    final double cardWidth = isMobile ? 188 : 235;

    final double cardHeight = isMobile ? 180 : 202;

    // Two copies allow seamless looping.
    final List<_GiftPayService> carouselItems = [..._services, ..._services];

    return MouseRegion(
      onEnter: (_) {
        _isPointerInside = true;
      },
      onExit: (_) {
        _isPointerInside = false;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            _isUserDragging = notification.dragDetails != null;
          }

          if (notification is ScrollEndNotification) {
            _isUserDragging = false;
          }

          return false;
        },
        child: SizedBox(
          height: cardHeight,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 26),
            itemCount: carouselItems.length,
            separatorBuilder: (_, __) {
              return const SizedBox(width: 16);
            },
            itemBuilder: (context, index) {
              final _GiftPayService service = carouselItems[index];

              return SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: _ServiceCard(
                  service: service,
                  isMobile: isMobile,
                  onTap: () {
                    Navigator.pushNamed(context, service.route);
                  },
                ),
              );
            },
          ),
        ),
      ),
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
          width: 6,
          height: 6,
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
            color: _blue,
          ),
        ),
      ],
    );
  }

  Widget _miniLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'SegoeUI',
        fontSize: 8.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.8,
        color: _blue,
      ),
    );
  }
}

// ============================================================================
// SERVICE MODEL
// ============================================================================

class _GiftPayService {
  final String title;
  final String category;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String route;

  const _GiftPayService({
    required this.title,
    required this.category,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.route,
  });
}

// ============================================================================
// SERVICE CARD
// ============================================================================

class _ServiceCard extends StatefulWidget {
  final _GiftPayService service;
  final bool isMobile;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.isMobile,
    required this.onTap,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (!mounted) return;

        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        if (!mounted) return;

        setState(() {
          _hovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,

          // Slight upward lift on desktop hover.
          transform: Matrix4.translationValues(0, _hovered ? -5 : 0, 0),

          // -------------------------------------------------------------------
          // OVERFLOW FIX
          //
          // Reduced padding from 20 -> 18 on desktop and removed Spacer().
          // The previous Spacer() made the layout dependent on whatever
          // vertical space remained, which could result in a tiny overflow
          // when text metrics were calculated.
          // -------------------------------------------------------------------
          padding: EdgeInsets.all(widget.isMobile ? 16 : 18),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                _hovered ? _blue.withOpacity(.045) : Colors.white,
              ],
            ),
            border: Border.all(
              color: _hovered
                  ? _highlight.withOpacity(.22)
                  : _navy.withOpacity(.07),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: _blue.withOpacity(.12),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: _navy.withOpacity(.045),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -----------------------------------------------------------------
              // ICON
              // -----------------------------------------------------------------
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: widget.isMobile ? 44 : 48,
                height: widget.isMobile ? 44 : 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: widget.service.iconColor.withOpacity(
                    _hovered ? .15 : .09,
                  ),
                  border: Border.all(
                    color: widget.service.iconColor.withOpacity(
                      _hovered ? .24 : .12,
                    ),
                  ),
                ),
                child: Icon(
                  widget.service.icon,
                  size: widget.isMobile ? 21 : 23,
                  color: widget.service.iconColor,
                ),
              ),

              // -----------------------------------------------------------------
              // CONTROLLED GAP
              //
              // Replaces Spacer() so cards remain stable even when
              // descriptions wrap differently.
              // -----------------------------------------------------------------
              SizedBox(height: widget.isMobile ? 14 : 16),

              // -----------------------------------------------------------------
              // CATEGORY
              // -----------------------------------------------------------------
              Text(
                widget.service.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.45,
                  color: _blue.withOpacity(.58),
                ),
              ),

              const SizedBox(height: 6),

              // -----------------------------------------------------------------
              // TITLE
              // -----------------------------------------------------------------
              Text(
                widget.service.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: widget.isMobile ? 16 : 17,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                  letterSpacing: -.2,
                ),
              ),

              const SizedBox(height: 6),

              // -----------------------------------------------------------------
              // DESCRIPTION
              // -----------------------------------------------------------------
              Expanded(
                child: Text(
                  widget.service.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: widget.isMobile ? 11 : 11.5,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                    color: _navy.withOpacity(.48),
                  ),
                ),
              ),

              const SizedBox(height: 7),

              // -----------------------------------------------------------------
              // ACTION INDICATOR
              // -----------------------------------------------------------------
              AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _hovered ? 1 : .65,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Explore',
                      style: TextStyle(
                        fontFamily: 'SegoeUI',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: _blue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 12, color: _blue),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
