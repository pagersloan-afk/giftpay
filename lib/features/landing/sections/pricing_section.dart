import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class PricingSection extends StatefulWidget {
  const PricingSection({super.key});

  @override
  State<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<PricingSection> {
  int currentPage = 0;

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF75A1FF);
  static const Color _surface = Color(0xFFF6F8FC);

  final List<Map<String, dynamic>> pricingItems = [
    {
      "title": "Electricity Tokens",
      "items": [
        "Instant token delivery",
        "Service fee: ₦10–₦25",
        "Minimum purchase: ₦100",
      ],
      "icon": Icons.bolt_rounded,
      "gradient": [const Color(0xFF273D68), const Color(0xFF4A6BB8)],
    },
    {
      "title": "Airtime & Data",
      "items": [
        "Network rate (no markup)",
        "Processing fee: ₦0–₦10",
        "Instant delivery",
      ],
      "icon": Icons.network_cell_rounded,
      "gradient": [const Color(0xFF3158B4), const Color(0xFF5E83D6)],
    },
    {
      "title": "Wallet Funding",
      "items": [
        "Bank transfer: Free",
        "Card payments: Gateway fees apply",
        "Instant wallet credit",
      ],
      "icon": Icons.account_balance_wallet_rounded,
      "gradient": [const Color(0xFF4A6BB8), const Color(0xFF273D68)],
    },
    {
      "title": "Gift Cards",
      "items": [
        "Starting from ₦7,000",
        "Processing fee: ₦0–₦20",
        "Instant digital delivery",
      ],
      "icon": Icons.card_giftcard_rounded,
      "gradient": [const Color(0xFF273D68), const Color(0xFF3659A8)],
    },
    {
      "title": "Transfers",
      "items": [
        "Send to any Nigerian bank",
        "Fee: ₦10–₦25",
        "Instant settlement",
      ],
      "icon": Icons.send_rounded,
      "gradient": [const Color(0xFF3158B4), const Color(0xFF4A6BB8)],
    },
    {
      "title": "Business Solutions",
      "items": [
        "Bulk utilities automation",
        "Custom pricing available",
        "Dedicated business support",
      ],
      "icon": Icons.business_center_rounded,
      "gradient": [const Color(0xFF4A6BB8), const Color(0xFF3158B4)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool isMobile = screenWidth < 700;
    final bool isTablet = screenWidth >= 700 && screenWidth < 1050;

    final int visibleCount = isMobile
        ? 1
        : isTablet
        ? 2
        : 3;

    final int totalPages = (pricingItems.length / visibleCount).ceil();

    // Keep the page index valid after a responsive breakpoint change.
    final int safeCurrentPage = totalPages == 0
        ? 0
        : currentPage.clamp(0, totalPages - 1);

    if (safeCurrentPage != currentPage) {
      currentPage = safeCurrentPage;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile
              ? 16
              : isTablet
              ? 28
              : 54,
          vertical: isMobile ? 34 : 58,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 26 : 34),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, _surface, _blue.withOpacity(0.035)],
              ),
              border: Border.all(color: _navy.withOpacity(0.065)),
              boxShadow: [
                BoxShadow(
                  color: _navy.withOpacity(0.045),
                  blurRadius: 34,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isMobile ? 26 : 34),
              child: Stack(
                children: [
                  Positioned(
                    top: -130,
                    right: -100,
                    child: IgnorePointer(
                      child: Container(
                        width: 340,
                        height: 340,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _blue.withOpacity(0.10),
                              _blue.withOpacity(0.025),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -150,
                    left: -120,
                    child: IgnorePointer(
                      child: Container(
                        width: 360,
                        height: 360,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _lightBlue.withOpacity(0.075),
                              _lightBlue.withOpacity(0.018),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(
                      isMobile
                          ? 20
                          : isTablet
                          ? 26
                          : 34,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(isMobile: isMobile, isTablet: isTablet),
                        SizedBox(height: isMobile ? 28 : 38),
                        _buildCarousel(
                          isMobile: isMobile,
                          isTablet: isTablet,
                          visibleCount: visibleCount,
                          totalPages: totalPages,
                        ),
                        SizedBox(height: isMobile ? 22 : 28),
                        _buildPageIndicator(totalPages: totalPages),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({required bool isMobile, required bool isTablet}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _lightBlue,
              ),
            ),
            const SizedBox(width: 9),
            const Text(
              'SIMPLE • TRANSPARENT • PREDICTABLE',
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
                color: _blue,
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 13 : 16),
        Text(
          'Pricing that stays clear.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: isMobile
                ? 30
                : isTablet
                ? 38
                : 46,
            height: 1.08,
            fontWeight: FontWeight.w800,
            letterSpacing: isMobile ? -1.0 : -1.8,
            color: _navy,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            'GiftPay is built on clear, simple, and predictable pricing. '
            'No hidden fees. Every transaction shows its cost upfront '
            'before you pay.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isMobile ? 14 : 16,
              height: 1.65,
              fontWeight: FontWeight.w400,
              color: _navy.withOpacity(0.55),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel({
    required bool isMobile,
    required bool isTablet,
    required int visibleCount,
    required int totalPages,
  }) {
    final bool canGoBack = currentPage > 0;
    final bool canGoForward = currentPage < totalPages - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildNavigationButton(
          icon: Icons.arrow_back_rounded,
          enabled: canGoBack,
          onPressed: canGoBack
              ? () {
                  setState(() {
                    currentPage--;
                  });
                }
              : null,
        ),
        SizedBox(width: isMobile ? 8 : 12),

        // IMPORTANT:
        // The carousel now has a finite vertical constraint.
        // This prevents the card's internal Expanded from receiving
        // an unbounded height.
        Expanded(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              layoutBuilder:
                  (Widget? currentChild, List<Widget> previousChildren) {
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
              transitionBuilder: (Widget child, Animation<double> animation) {
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );

                return FadeTransition(
                  opacity: curvedAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.025, 0),
                      end: Offset.zero,
                    ).animate(curvedAnimation),
                    child: child,
                  ),
                );
              },
              child: _buildCardRow(
                key: ValueKey(currentPage),
                visibleCount: visibleCount,
                isMobile: isMobile,
                isTablet: isTablet,
              ),
            ),
          ),
        ),

        SizedBox(width: isMobile ? 8 : 12),
        _buildNavigationButton(
          icon: Icons.arrow_forward_rounded,
          enabled: canGoForward,
          onPressed: canGoForward
              ? () {
                  setState(() {
                    currentPage++;
                  });
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildCardRow({
    required Key key,
    required int visibleCount,
    required bool isMobile,
    required bool isTablet,
  }) {
    return Row(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(visibleCount, (i) {
        final int index = currentPage * visibleCount + i;

        if (index >= pricingItems.length) {
          return Expanded(child: const SizedBox());
        }

        final item = pricingItems[index];

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile
                  ? 3
                  : isTablet
                  ? 6
                  : 7,
            ),
            child: AnimatedPricingCard(
              title: item["title"] as String,
              items: List<String>.from(item["items"] as List),
              iconData: item["icon"] as IconData,
              gradientColors: List<Color>.from(item["gradient"] as List),
              isMobile: isMobile,
              isTablet: isTablet,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback? onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: enabled
            ? Colors.white.withOpacity(0.88)
            : Colors.white.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: enabled ? _blue.withOpacity(0.12) : _navy.withOpacity(0.055),
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: _navy.withOpacity(0.055),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        splashRadius: 20,
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
          color: enabled ? _blue : _navy.withOpacity(0.22),
        ),
      ),
    );
  }

  Widget _buildPageIndicator({required int totalPages}) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(totalPages, (index) {
          final bool active = index == currentPage;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              gradient: active
                  ? const LinearGradient(colors: [_blue, _lightBlue])
                  : null,
              color: active ? null : _navy.withOpacity(0.16),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    );
  }
}

class AnimatedPricingCard extends StatefulWidget {
  final String title;
  final List<String> items;
  final IconData iconData;
  final List<Color> gradientColors;
  final bool isMobile;
  final bool isTablet;

  const AnimatedPricingCard({
    super.key,
    required this.title,
    required this.items,
    required this.iconData,
    required this.gradientColors,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  State<AnimatedPricingCard> createState() => _AnimatedPricingCardState();
}

class _AnimatedPricingCardState extends State<AnimatedPricingCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
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
      child: AnimatedScale(
        scale: _hovered ? 1.018 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: widget.isMobile
                ? 230
                : widget.isTablet
                ? 245
                : 250,
          ),
          padding: EdgeInsets.all(
            widget.isMobile
                ? 18
                : widget.isTablet
                ? 20
                : 22,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.isMobile ? 20 : 23),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradientColors,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(_hovered ? 0.30 : 0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.first.withOpacity(
                  _hovered ? 0.22 : 0.12,
                ),
                blurRadius: _hovered ? 28 : 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: widget.isMobile ? 42 : 46,
                    height: widget.isMobile ? 42 : 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white.withOpacity(_hovered ? 0.22 : 0.15),
                      border: Border.all(
                        color: Colors.white.withOpacity(_hovered ? 0.30 : 0.18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.iconData,
                      size: widget.isMobile ? 21 : 23,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'SegoeUI',
                        fontWeight: FontWeight.w800,
                        fontSize: widget.isMobile
                            ? 16
                            : widget.isTablet
                            ? 17
                            : 18,
                        height: 1.15,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: 34,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.32),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),

              // FIX:
              // Removed Expanded from the pricing details column.
              // The card previously had an unbounded height while this
              // Expanded demanded the remaining height, causing:
              //
              // "BoxConstraints forces an infinite height."
              //
              // The content now sizes itself naturally.
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < widget.items.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == widget.items.length - 1 ? 0 : 12,
                      ),
                      child: _buildPricingItem(widget.items[i]),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'UPFRONT PRICING',
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.25,
                      color: Colors.white.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.72),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: widget.isMobile
                  ? 12.5
                  : widget.isTablet
                  ? 12.5
                  : 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.88),
            ),
          ),
        ),
      ],
    );
  }
}
