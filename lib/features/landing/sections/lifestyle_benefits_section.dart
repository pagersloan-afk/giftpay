import 'package:flutter/material.dart';

/// GiftPay Lifestyle / Rewards Ecosystem
///
/// Production goals:
/// - Premium fintech / lifestyle visual language
/// - Rewards, Travel and Shopping ecosystem
/// - Responsive desktop / tablet / mobile layout
/// - Glass-morphic cards
/// - Subtle entrance animation
/// - Desktop hover interaction
/// - Lightweight parallax artwork movement
/// - Strong typography hierarchy
/// - No dependency on page/global scroll controllers
/// - No unbounded-height / Expanded layout issues
/// - No fixed-card bottom overflow
class LifestyleBenefitsSection extends StatefulWidget {
  const LifestyleBenefitsSection({super.key});

  @override
  State<LifestyleBenefitsSection> createState() =>
      _LifestyleBenefitsSectionState();
}

class _LifestyleBenefitsSectionState extends State<LifestyleBenefitsSection>
    with SingleTickerProviderStateMixin {
  // ===========================================================================
  // THEME
  // ===========================================================================

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF7EA4FF);
  static const Color _surface = Color(0xFFF7F9FC);

  // ===========================================================================
  // ANIMATION
  // ===========================================================================

  late final AnimationController _controller;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<double>(begin: 34, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _headerAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    final bool isMobile = width < 700;
    final bool isTablet = width >= 700 && width < 1100;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile
              ? 18
              : isTablet
              ? 34
              : 64,
          vertical: isMobile ? 58 : 82,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isMobile: isMobile),
                SizedBox(height: isMobile ? 30 : 42),
                _buildBenefitsShell(
                  context,
                  isMobile: isMobile,
                  isTablet: isTablet,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader({required bool isMobile}) {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _headerAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - _headerAnimation.value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('LIFESTYLE & REWARDS'),
          const SizedBox(height: 14),
          Text(
            'More ways to enjoy GiftPay.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isMobile ? 31 : 46,
              height: 1.06,
              fontWeight: FontWeight.w800,
              letterSpacing: isMobile ? -1.0 : -1.8,
              color: _navy,
            ),
          ),
          const SizedBox(height: 13),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              'Your everyday GiftPay experience can go beyond payments. '
              'Earn rewards, discover travel opportunities, shop smarter, '
              'and unlock more benefits across the ecosystem.',
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 14.5 : 17,
                height: 1.65,
                fontWeight: FontWeight.w400,
                color: _navy.withOpacity(.56),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MAIN SHELL
  // ===========================================================================

  Widget _buildBenefitsShell(
    BuildContext context, {
    required bool isMobile,
    required bool isTablet,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isMobile
            ? 14
            : isTablet
            ? 20
            : 24,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isMobile ? 26 : 34),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, _surface, _blue.withOpacity(.035)],
        ),
        border: Border.all(color: _navy.withOpacity(.07)),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(.055),
            blurRadius: 42,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildShellHeader(isMobile: isMobile),
          SizedBox(height: isMobile ? 18 : 24),
          if (isMobile)
            _buildMobileCards()
          else
            _buildDesktopCards(isTablet: isTablet),
          SizedBox(height: isMobile ? 18 : 24),
          _buildEcosystemFooter(isMobile: isMobile),
        ],
      ),
    );
  }

  // ===========================================================================
  // SHELL HEADER
  // ===========================================================================

  Widget _buildShellHeader({required bool isMobile}) {
    return Row(
      children: [
        Container(
          width: isMobile ? 38 : 42,
          height: isMobile ? 38 : 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: _blue.withOpacity(.075),
            border: Border.all(color: _blue.withOpacity(.11)),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            size: isMobile ? 18 : 20,
            color: _blue,
          ),
        ),
        SizedBox(width: isMobile ? 11 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'THE GIFTPAY BENEFITS ECOSYSTEM',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: isMobile ? 8 : 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: _blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rewards, travel, shopping and more.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: isMobile ? 12 : 13,
                  fontWeight: FontWeight.w500,
                  color: _navy.withOpacity(.48),
                ),
              ),
            ],
          ),
        ),
        if (!isMobile) _buildStatusPill(),
      ],
    );
  }

  Widget _buildStatusPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _navy.withOpacity(.07)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF45B879),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            'CONNECTED BENEFITS',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: _navy.withOpacity(.48),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MOBILE CARDS
  // ===========================================================================

  Widget _buildMobileCards() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBenefitCard(
          index: 0,
          title: 'Rewards',
          category: 'GIFTPAY REWARDS',
          subtitle: 'Earn cashback and discover benefits as you use GiftPay.',
          image: 'assets/illustrations/rewards.png',
          icon: Icons.card_giftcard_rounded,
          accent: const Color(0xFF8458C9),
          isMobile: true,
        ),
        const SizedBox(height: 14),
        _buildBenefitCard(
          index: 1,
          title: 'Travel',
          category: 'GIFTPAY TRAVEL',
          subtitle: 'Redeem rewards and explore connected travel experiences.',
          image: 'assets/illustrations/travel.png',
          icon: Icons.flight_takeoff_rounded,
          accent: const Color(0xFF4D7ED1),
          isMobile: true,
        ),
        const SizedBox(height: 14),
        _buildBenefitCard(
          index: 2,
          title: 'Shopping',
          category: 'GIFTPAY SHOPPING',
          subtitle: 'Discover exclusive deals and smarter ways to shop.',
          image: 'assets/illustrations/shopping.png',
          icon: Icons.shopping_bag_rounded,
          accent: const Color(0xFFE1A832),
          isMobile: true,
        ),
      ],
    );
  }

  // ===========================================================================
  // DESKTOP CARDS
  // ===========================================================================

  Widget _buildDesktopCards({required bool isTablet}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildBenefitCard(
            index: 0,
            title: 'Rewards',
            category: 'GIFTPAY REWARDS',
            subtitle: 'Earn cashback and discover benefits as you use GiftPay.',
            image: 'assets/illustrations/rewards.png',
            icon: Icons.card_giftcard_rounded,
            accent: const Color(0xFF8458C9),
            isMobile: false,
          ),
        ),
        SizedBox(width: isTablet ? 14 : 18),
        Expanded(
          child: _buildBenefitCard(
            index: 1,
            title: 'Travel',
            category: 'GIFTPAY TRAVEL',
            subtitle:
                'Redeem rewards and explore connected travel experiences.',
            image: 'assets/illustrations/travel.png',
            icon: Icons.flight_takeoff_rounded,
            accent: const Color(0xFF4D7ED1),
            isMobile: false,
          ),
        ),
        SizedBox(width: isTablet ? 14 : 18),
        Expanded(
          child: _buildBenefitCard(
            index: 2,
            title: 'Shopping',
            category: 'GIFTPAY SHOPPING',
            subtitle: 'Discover exclusive deals and smarter ways to shop.',
            image: 'assets/illustrations/shopping.png',
            icon: Icons.shopping_bag_rounded,
            accent: const Color(0xFFE1A832),
            isMobile: false,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // BENEFIT CARD
  // ===========================================================================

  Widget _buildBenefitCard({
    required int index,
    required String title,
    required String category,
    required String subtitle,
    required String image,
    required IconData icon,
    required Color accent,
    required bool isMobile,
  }) {
    return _AnimatedBenefitCard(
      index: index,
      title: title,
      category: category,
      subtitle: subtitle,
      image: image,
      icon: icon,
      accent: accent,
      isMobile: isMobile,
    );
  }

  // ===========================================================================
  // ECOSYSTEM FOOTER
  // ===========================================================================

  Widget _buildEcosystemFooter({required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 18,
        vertical: isMobile ? 13 : 15,
      ),
      decoration: BoxDecoration(
        color: _navy.withOpacity(.035),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _navy.withOpacity(.055)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hub_rounded,
            size: isMobile ? 17 : 18,
            color: _blue.withOpacity(.72),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'One connected ecosystem for more of your everyday life.',
              maxLines: isMobile ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 11.5 : 12.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: _navy.withOpacity(.48),
              ),
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: _blue.withOpacity(.50),
            ),
          ],
        ],
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
}

// =============================================================================
// ANIMATED BENEFIT CARD
// =============================================================================

class _AnimatedBenefitCard extends StatefulWidget {
  final int index;
  final String title;
  final String category;
  final String subtitle;
  final String image;
  final IconData icon;
  final Color accent;
  final bool isMobile;

  const _AnimatedBenefitCard({
    required this.index,
    required this.title,
    required this.category,
    required this.subtitle,
    required this.image,
    required this.icon,
    required this.accent,
    required this.isMobile,
  });

  @override
  State<_AnimatedBenefitCard> createState() => _AnimatedBenefitCardState();
}

class _AnimatedBenefitCardState extends State<_AnimatedBenefitCard> {
  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);

  bool _hovered = false;

  double _parallaxX = 0;
  double _parallaxY = 0;

  // ===========================================================================
  // FINITE CARD DIMENSIONS
  // ===========================================================================

  double get _cardHeight {
    if (widget.isMobile) {
      return 330;
    }

    // Increased from 350 to 400 to give the complete content
    // enough vertical space without overflow.
    return 400;
  }

  double get _artworkHeight {
    if (widget.isMobile) {
      return 118;
    }

    return 145;
  }

  double get _horizontalPadding {
    return widget.isMobile ? 20 : 24;
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

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
          _parallaxX = 0;
          _parallaxY = 0;
        });
      },

      onHover: widget.isMobile
          ? null
          : (event) {
              if (!mounted) return;

              final RenderObject? renderObject = context.findRenderObject();

              if (renderObject is! RenderBox) {
                return;
              }

              final Size size = renderObject.size;

              if (size.width <= 0 || size.height <= 0) {
                return;
              }

              final double normalizedX =
                  ((event.localPosition.dx / size.width) - .5).clamp(-.5, .5);

              final double normalizedY =
                  ((event.localPosition.dy / size.height) - .5).clamp(-.5, .5);

              setState(() {
                _parallaxX = normalizedX * 8;
                _parallaxY = normalizedY * 5;
              });
            },

      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},

        child: AnimatedScale(
          scale: _hovered ? 1.018 : 1,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,

          child: SizedBox(
            width: double.infinity,
            height: _cardHeight,

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.isMobile ? 22 : 26),

                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(_hovered ? .96 : .88),
                    widget.accent.withOpacity(_hovered ? .055 : .025),
                    Colors.white,
                  ],
                ),

                border: Border.all(
                  color: _hovered
                      ? widget.accent.withOpacity(.20)
                      : _navy.withOpacity(.065),
                ),

                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: widget.accent.withOpacity(.13),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: _navy.withOpacity(.045),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.isMobile ? 22 : 26),

                child: Stack(
                  children: [
                    // ==========================================================
                    // BACKGROUND ACCENT
                    // ==========================================================
                    Positioned(
                      top: -80,
                      right: -70,
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.accent.withOpacity(.045),
                        ),
                      ),
                    ),

                    // ==========================================================
                    // CARD CONTENT
                    //
                    // IMPORTANT:
                    // No Expanded.
                    // No Spacer.
                    // Every section has controlled finite height.
                    // ==========================================================
                    Padding(
                      padding: EdgeInsets.all(_horizontalPadding),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        mainAxisSize: MainAxisSize.min,

                        children: [
                          // ----------------------------------------------------
                          // TOP ROW
                          // ----------------------------------------------------
                          _buildCardTopRow(isMobile: widget.isMobile),

                          SizedBox(height: widget.isMobile ? 10 : 10),

                          // ----------------------------------------------------
                          // ARTWORK
                          // ----------------------------------------------------
                          SizedBox(
                            width: double.infinity,
                            height: _artworkHeight,

                            child: Center(
                              child: Transform.translate(
                                offset: Offset(_parallaxX, _parallaxY),

                                child: Image.asset(
                                  widget.image,
                                  width: double.infinity,
                                  height: _artworkHeight,
                                  fit: BoxFit.contain,

                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image_outlined,
                                      size: 42,
                                      color: widget.accent.withOpacity(.30),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          // ----------------------------------------------------
                          // CATEGORY
                          // ----------------------------------------------------
                          SizedBox(height: widget.isMobile ? 8 : 8),

                          Text(
                            widget.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'SegoeUI',
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.55,
                              color: _blue.withOpacity(.60),
                            ),
                          ),

                          const SizedBox(height: 5),

                          // ----------------------------------------------------
                          // TITLE
                          // ----------------------------------------------------
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'SegoeUI',
                              fontSize: widget.isMobile ? 21 : 23,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.45,
                              color: _navy,
                            ),
                          ),

                          const SizedBox(height: 5),

                          // ----------------------------------------------------
                          // DESCRIPTION
                          // ----------------------------------------------------
                          Text(
                            widget.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'SegoeUI',
                              fontSize: widget.isMobile ? 12 : 12.5,
                              height: 1.35,
                              fontWeight: FontWeight.w400,
                              color: _navy.withOpacity(.49),
                            ),
                          ),

                          const SizedBox(height: 7),

                          // ----------------------------------------------------
                          // EXPLORE
                          // ----------------------------------------------------
                          _buildExploreIndicator(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // CARD TOP ROW
  // ===========================================================================

  Widget _buildCardTopRow({required bool isMobile}) {
    return SizedBox(
      height: isMobile ? 42 : 46,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),

            width: isMobile ? 42 : 46,
            height: isMobile ? 42 : 46,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),

              color: widget.accent.withOpacity(_hovered ? .14 : .08),

              border: Border.all(
                color: widget.accent.withOpacity(_hovered ? .24 : .12),
              ),
            ),

            child: Icon(
              widget.icon,
              size: isMobile ? 20 : 22,
              color: widget.accent,
            ),
          ),

          const Spacer(),

          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: _hovered ? 1 : .55,

            child: Container(
              width: 29,
              height: 29,

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _blue.withOpacity(.055),
                border: Border.all(color: _blue.withOpacity(.09)),
              ),

              child: Icon(Icons.arrow_outward_rounded, size: 14, color: _blue),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EXPLORE INDICATOR
  // ===========================================================================

  Widget _buildExploreIndicator() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: _hovered ? 1 : .62,

      child: SizedBox(
        height: 18,

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Explore',
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _blue,
              ),
            ),

            const SizedBox(width: 5),

            Icon(Icons.arrow_forward_rounded, size: 13, color: _blue),
          ],
        ),
      ),
    );
  }
}
