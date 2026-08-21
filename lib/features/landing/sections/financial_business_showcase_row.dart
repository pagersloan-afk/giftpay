import 'package:flutter/material.dart';
import 'package:utilityhub/features/landing/sections/business_solutions_section.dart';
import 'package:utilityhub/features/landing/sections/product_showcase_section.dart';
import 'package:utilityhub/features/landing/sections/financial_education_section.dart';

/// GiftPay Financial + Business Showcase
///
/// Presents:
/// - Financial education
/// - Product experience
/// - Business solutions
///
/// IMPORTANT:
/// The carousel width is the source of truth.
/// Every child section receives a bounded width and must adapt to it.
class FinancialBusinessShowcaseRow extends StatefulWidget {
  const FinancialBusinessShowcaseRow({super.key});

  @override
  State<FinancialBusinessShowcaseRow> createState() =>
      _FinancialBusinessShowcaseRowState();
}

class _FinancialBusinessShowcaseRowState
    extends State<FinancialBusinessShowcaseRow>
    with SingleTickerProviderStateMixin {
  // ===========================================================================
  // ANIMATION
  // ===========================================================================

  late final AnimationController _controller;
  late final Animation<double> _slideUp;
  late final Animation<double> _bgShift;

  // ===========================================================================
  // SCROLL
  // ===========================================================================

  final ScrollController _scrollController = ScrollController();

  int _currentIndex = 0;

  // ===========================================================================
  // THEME
  // ===========================================================================

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF7EA4FF);
  static const Color _surface = Color(0xFFF7F9FC);

  static const double _cardSpacing = 20;

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _slideUp = Tween<double>(
      begin: 40,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _bgShift = Tween<double>(
      begin: -.6,
      end: .6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ===========================================================================
  // SCROLL SYNC
  // ===========================================================================

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final double itemExtent = _currentItemExtent;

    if (itemExtent <= 0) return;

    final double offset = _scrollController.offset;

    int calculatedIndex = (offset / itemExtent).round();

    calculatedIndex = calculatedIndex.clamp(0, 2);

    if (calculatedIndex != _currentIndex && mounted) {
      setState(() {
        _currentIndex = calculatedIndex;
      });
    }
  }

  double get _currentItemExtent {
    if (!_scrollController.hasClients) {
      return 1;
    }

    final double viewportWidth = _scrollController.position.viewportDimension;

    if (viewportWidth <= 0) {
      return 1;
    }

    return viewportWidth + _cardSpacing;
  }

  // ===========================================================================
  // CAROUSEL NAVIGATION
  // ===========================================================================

  void _scrollTo(int index, double cardWidth) {
    if (!_scrollController.hasClients) return;

    final double targetOffset = index * (cardWidth + _cardSpacing);

    final double maxScroll = _scrollController.position.maxScrollExtent;

    final double safeOffset = targetOffset.clamp(0.0, maxScroll);

    _scrollController.animateTo(
      safeOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );

    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideUp.value),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;

              final bool isMobile = width < 768;

              final bool isTablet = width >= 768 && width < 1100;

              // ===============================================================
              // SOURCE OF TRUTH
              //
              // The carousel card width is deliberately bounded.
              // Children must render inside this exact width.
              // ===============================================================

              final double horizontalPadding = isMobile
                  ? 12
                  : isTablet
                  ? 22
                  : 28;

              final double availableCarouselWidth =
                  width - (horizontalPadding * 2);

              final double cardWidth = isMobile
                  ? availableCarouselWidth * .92
                  : isTablet
                  ? availableCarouselWidth * .68
                  : availableCarouselWidth * .43;

              // Never allow the card to become absurdly wide.
              final double safeCardWidth = cardWidth.clamp(300.0, 620.0);

              // ===============================================================
              // HEIGHT
              // ===============================================================

              final double carouselHeight = isMobile
                  ? 650
                  : isTablet
                  ? 690
                  : 700;

              // ===============================================================
              // CHILD CARDS
              // ===============================================================

              final List<Widget> cards = [
                const FinancialEducationSection(),
                const ProductShowcaseSection(),
                const BusinessSolutionsSection(),
              ];

              return Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 1400),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isMobile ? 24 : 40,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(_bgShift.value, -1),
                      end: Alignment(1, _bgShift.value),
                      colors: [
                        Colors.white.withOpacity(.97),
                        _surface,
                        _blue.withOpacity(.075),
                        _navy.withOpacity(.035),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(isMobile ? 22 : 30),
                    border: Border.all(color: _navy.withOpacity(.07)),
                    boxShadow: [
                      BoxShadow(
                        color: _navy.withOpacity(.055),
                        blurRadius: 40,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =======================================================
                      // HEADER
                      // =======================================================
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 4 : 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _highlight,
                                  ),
                                ),
                                const SizedBox(width: 9),
                                Text(
                                  'GIFTPAY ECOSYSTEM',
                                  style: TextStyle(
                                    fontFamily: 'SegoeUI',
                                    fontSize: isMobile ? 8 : 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                    color: _blue,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Text(
                              'Learn, Compare, and Automate — '
                              'All in One Platform',
                              style: TextStyle(
                                fontFamily: 'SegoeUI',
                                fontWeight: FontWeight.w800,
                                fontSize: isMobile ? 22 : 30,
                                letterSpacing: isMobile ? -.5 : -1,
                                height: 1.15,
                                color: _navy,
                              ),
                            ),

                            const SizedBox(height: 8),

                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 760),
                              child: Text(
                                'Explore the tools, insights, '
                                'and experiences that make '
                                'GiftPay more useful across '
                                'everyday life, business, '
                                'and financial decisions.',
                                style: TextStyle(
                                  fontFamily: 'SegoeUI',
                                  fontSize: isMobile ? 13 : 15,
                                  height: 1.55,
                                  color: _navy.withOpacity(.48),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isMobile ? 24 : 30),

                      // =======================================================
                      // CAROUSEL
                      // =======================================================
                      SizedBox(
                        height: carouselHeight,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            isMobile ? 18 : 24,
                          ),
                          child: Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              ListView.separated(
                                controller: _scrollController,
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 2 : 8,
                                  vertical: 2,
                                ),
                                itemCount: cards.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: _cardSpacing),
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    width: safeCardWidth,
                                    child: cards[index],
                                  );
                                },
                              ),

                              // =================================================
                              // LEFT ARROW
                              // =================================================
                              if (!isMobile && _currentIndex > 0)
                                Positioned(
                                  left: 8,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: _ArrowButton(
                                      icon: Icons.arrow_back_rounded,
                                      onTap: () {
                                        _scrollTo(
                                          _currentIndex - 1,
                                          safeCardWidth,
                                        );
                                      },
                                    ),
                                  ),
                                ),

                              // =================================================
                              // RIGHT ARROW
                              // =================================================
                              if (!isMobile && _currentIndex < cards.length - 1)
                                Positioned(
                                  right: 8,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: _ArrowButton(
                                      icon: Icons.arrow_forward_rounded,
                                      onTap: () {
                                        _scrollTo(
                                          _currentIndex + 1,
                                          safeCardWidth,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =======================================================
                      // PAGINATION
                      // =======================================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(cards.length, (index) {
                          final bool active = _currentIndex == index;

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              _scrollTo(index, safeCardWidth);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 6,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOutCubic,
                                width: active ? 26 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: active
                                      ? _blue
                                      : _navy.withOpacity(.14),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ==============================================================================
// FLOATING ARROW BUTTON
// ==============================================================================

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.94),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF4A6BB8).withOpacity(.12)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF273D68).withOpacity(.10),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, size: 19, color: const Color(0xFF273D68)),
        ),
      ),
    );
  }
}

// ==============================================================================
// ANIMATED INFORMATION CARD
// ==============================================================================

class AnimatedInfoCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final String linkText;
  final String linkRoute;

  const AnimatedInfoCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.linkText,
    required this.linkRoute,
  });

  @override
  State<AnimatedInfoCard> createState() => _AnimatedInfoCardState();
}

class _AnimatedInfoCardState extends State<AnimatedInfoCard> {
  double _hoverScale = 1.0;
  double _parallaxOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 600;

        return MouseRegion(
          onEnter: (_) {
            if (!isCompact) {
              setState(() {
                _hoverScale = 1.025;
              });
            }
          },
          onExit: (_) {
            if (!isCompact) {
              setState(() {
                _hoverScale = 1.0;
                _parallaxOffset = 0.0;
              });
            }
          },
          onHover: (event) {
            if (!isCompact) {
              setState(() {
                _parallaxOffset = (event.localPosition.dx - 150) / 45;
              });
            }
          },
          child: AnimatedScale(
            scale: _hoverScale,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isCompact ? 14 : 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF273D68).withOpacity(.055),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF273D68).withOpacity(.07),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: Offset(_parallaxOffset, 0),
                    child: SizedBox(
                      width: double.infinity,
                      height: isCompact ? 180 : 240,
                      child: Image.asset(
                        widget.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_outlined,
                            size: 42,
                            color: const Color(0xFF4A6BB8).withOpacity(.35),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontWeight: FontWeight.w800,
                      fontSize: isCompact ? 15 : 17,
                      color: const Color(0xFF273D68),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    maxLines: isCompact ? 5 : 7,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: isCompact ? 13 : 14,
                      color: const Color(0xFF273D68).withOpacity(.52),
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, widget.linkRoute);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6BB8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 17 : 21,
                        vertical: isCompact ? 9 : 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.linkText,
                          style: TextStyle(
                            fontFamily: 'SegoeUI',
                            fontWeight: FontWeight.w700,
                            fontSize: isCompact ? 12.5 : 13.5,
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
