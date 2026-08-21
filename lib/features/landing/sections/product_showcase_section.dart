import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

/// GiftPay Product Showcase Section
///
/// IMPORTANT:
/// This widget is designed to work both:
/// 1. As a normal full-width landing section.
/// 2. Inside the FinancialBusinessShowcaseRow carousel.
///
/// The available width from LayoutBuilder is the source of truth.
/// Do not use MediaQuery width to determine the internal layout because
/// this widget may be rendered inside a much narrower carousel card.
class ProductShowcaseSection extends StatefulWidget {
  const ProductShowcaseSection({super.key});

  @override
  State<ProductShowcaseSection> createState() => _ProductShowcaseSectionState();
}

class _ProductShowcaseSectionState extends State<ProductShowcaseSection>
    with SingleTickerProviderStateMixin {
  // ===========================================================================
  // THEME
  // ===========================================================================

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF7EA4FF);
  static const Color _surface = Color(0xFFF7F9FC);

  // ===========================================================================
  // SHOWCASE CONTENT
  // ===========================================================================

  static const List<_ShowcaseProduct> _products = [
    _ShowcaseProduct(
      image: 'assets/illustrations/a2_utility_plan_compare.png',
      eyebrow: 'SMART UTILITIES',
      title: 'Find the Right Utility Plan',
      description:
          'Compare electricity providers, data bundles, and airtime plans '
          'to find the option that fits your everyday needs.',
      buttonLabel: 'Compare Plans',
    ),
    _ShowcaseProduct(
      image: 'assets/illustrations/a2_rewards.png',
      eyebrow: 'REWARDS',
      title: 'Get More From Every Experience',
      description:
          'Discover rewards and connected benefits designed to make your '
          'everyday GiftPay experience more valuable.',
      buttonLabel: 'Explore Rewards',
    ),
    _ShowcaseProduct(
      image: 'assets/illustrations/a2_travel.png',
      eyebrow: 'TRAVEL',
      title: 'Plan More of Your Journey',
      description:
          'Explore connected travel experiences and manage more of your '
          'journey from one familiar GiftPay platform.',
      buttonLabel: 'Explore Travel',
    ),
    _ShowcaseProduct(
      image: 'assets/illustrations/a2_shopping.png',
      eyebrow: 'DIGITAL COMMERCE',
      title: 'A Better Way to Shop',
      description:
          'Bring digital commerce and everyday purchases into one connected '
          'experience built around the way you already use your devices.',
      buttonLabel: 'Explore Shopping',
    ),
    _ShowcaseProduct(
      image: 'assets/illustrations/a2_aviation.png',
      eyebrow: 'AVIATION',
      title: 'Take Your Travel Further',
      description:
          'Discover flight booking experiences for local and international '
          'travel without leaving the wider GiftPay ecosystem.',
      buttonLabel: 'Book a Flight',
    ),
    _ShowcaseProduct(
      image: 'assets/illustrations/a2_rides.png',
      eyebrow: 'MOBILITY',
      title: 'Move Around With Ease',
      description:
          'Access connected ride experiences and manage more of your daily '
          'mobility from the GiftPay platform.',
      buttonLabel: 'Explore Rides',
    ),
  ];

  // ===========================================================================
  // ANIMATION
  // ===========================================================================

  late final AnimationController _transitionController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  Timer? _rotationTimer;

  int _currentIndex = 0;

  bool _isPointerInside = false;
  bool _isTransitioning = false;

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: .965, end: 1).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: Curves.easeOutCubic,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(.02, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _transitionController,
            curve: Curves.easeOutCubic,
          ),
        );

    _transitionController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startAutoRotation();
    });
  }

  void _startAutoRotation() {
    _rotationTimer?.cancel();

    _rotationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      if (_isPointerInside) return;
      if (_isTransitioning) return;

      _showNext();
    });
  }

  // ===========================================================================
  // ROTATION
  // ===========================================================================

  Future<void> _showNext() async {
    if (!mounted || _isTransitioning) return;

    _isTransitioning = true;

    try {
      await _transitionController.reverse();

      if (!mounted) return;

      setState(() {
        _currentIndex = (_currentIndex + 1) % _products.length;
      });

      await _transitionController.forward();
    } finally {
      _isTransitioning = false;
    }
  }

  Future<void> _showPrevious() async {
    if (!mounted || _isTransitioning) return;

    _isTransitioning = true;

    try {
      await _transitionController.reverse();

      if (!mounted) return;

      setState(() {
        _currentIndex =
            (_currentIndex - 1 + _products.length) % _products.length;
      });

      await _transitionController.forward();
    } finally {
      _isTransitioning = false;
    }
  }

  Future<void> _selectProduct(int index) async {
    if (!mounted || index == _currentIndex || _isTransitioning) return;

    _isTransitioning = true;

    try {
      await _transitionController.reverse();

      if (!mounted) return;

      setState(() {
        _currentIndex = index;
      });

      await _transitionController.forward();
    } finally {
      _isTransitioning = false;
    }
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _transitionController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;

        // This is intentionally based on the widget's actual allocated width,
        // NOT the browser/device width.
        final bool isCompact = availableWidth < 760;
        final bool isVeryCompact = availableWidth < 520;

        return MouseRegion(
          onEnter: (_) {
            _isPointerInside = true;
          },
          onExit: (_) {
            _isPointerInside = false;
          },
          child: _buildShowcaseCard(
            isCompact: isCompact,
            isVeryCompact: isVeryCompact,
            availableWidth: availableWidth,
          ),
        );
      },
    );
  }

  // ===========================================================================
  // MAIN CARD
  // ===========================================================================

  Widget _buildShowcaseCard({
    required bool isCompact,
    required bool isVeryCompact,
    required double availableWidth,
  }) {
    final _ShowcaseProduct product = _products[_currentIndex];

    final double horizontalPadding = isVeryCompact
        ? 14
        : isCompact
        ? 18
        : 30;

    final double verticalPadding = isVeryCompact
        ? 14
        : isCompact
        ? 20
        : 30;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minWidth: 0),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isCompact ? 22 : 34),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, _surface, _blue.withOpacity(.035)],
        ),
        border: Border.all(color: _navy.withOpacity(.075)),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(.055),
            blurRadius: isCompact ? 24 : 45,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: isCompact
          ? _buildCompactLayout(product, isVeryCompact: isVeryCompact)
          : _buildDesktopLayout(product),
    );
  }

  // ===========================================================================
  // COMPACT CAROUSEL LAYOUT
  // ===========================================================================

  Widget _buildCompactLayout(
    _ShowcaseProduct product, {
    required bool isVeryCompact,
  }) {
    final double imageHeight = isVeryCompact ? 185 : 235;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopBar(isCompact: true),

        const SizedBox(height: 14),

        _buildImageStage(product, height: imageHeight, isCompact: true),

        const SizedBox(height: 18),

        _buildProductContent(
          product,
          isCompact: true,
          isVeryCompact: isVeryCompact,
        ),

        const SizedBox(height: 18),

        _buildNavigation(isCompact: true),
      ],
    );
  }

  // ===========================================================================
  // DESKTOP LAYOUT
  // ===========================================================================

  Widget _buildDesktopLayout(_ShowcaseProduct product) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTopBar(isCompact: false),

        const SizedBox(height: 28),

        SizedBox(
          height: 440,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 11,
                child: _buildImageStage(
                  product,
                  height: double.infinity,
                  isCompact: false,
                ),
              ),

              const SizedBox(width: 38),

              Expanded(
                flex: 8,
                child: Center(
                  child: _buildProductContent(
                    product,
                    isCompact: false,
                    isVeryCompact: false,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        _buildNavigation(isCompact: false),
      ],
    );
  }

  // ===========================================================================
  // TOP BAR
  // ===========================================================================

  Widget _buildTopBar({required bool isCompact}) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          child: Row(
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
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'GIFTPAY PRODUCT EXPERIENCE',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: isCompact ? 7.5 : 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: isCompact ? 1.1 : 1.8,
                    color: _blue,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (!isCompact) ...[
          const SizedBox(width: 12),
          Flexible(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Row(
                key: ValueKey(_isPointerInside),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isPointerInside
                        ? Icons.pause_circle_outline_rounded
                        : Icons.autorenew_rounded,
                    size: 15,
                    color: _blue.withOpacity(.48),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isPointerInside ? 'Rotation paused' : 'Auto showcase',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _navy.withOpacity(.38),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // IMAGE STAGE
  // ===========================================================================

  Widget _buildImageStage(
    _ShowcaseProduct product, {
    required double height,
    required bool isCompact,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isCompact ? 18 : 26),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.1,
            colors: [_blue.withOpacity(.10), _surface, Colors.white],
          ),
          border: Border.all(color: _navy.withOpacity(.065)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: -70,
              top: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _blue.withOpacity(.07),
                ),
              ),
            ),

            Positioned(
              right: -90,
              bottom: -100,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _highlight.withOpacity(.06),
                ),
              ),
            ),

            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Padding(
                      padding: EdgeInsets.all(isCompact ? 6 : 14),
                      child: Image.asset(
                        product.image,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImageFallback();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: isCompact ? 10 : 16,
              right: isCompact ? 10 : 16,
              child: _buildImageCounter(isCompact: isCompact),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageFallback() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 44,
        color: _blue.withOpacity(.30),
      ),
    );
  }

  // ===========================================================================
  // IMAGE COUNTER
  // ===========================================================================

  Widget _buildImageCounter({required bool isCompact}) {
    final String current = (_currentIndex + 1).toString().padLeft(2, '0');

    final String total = _products.length.toString().padLeft(2, '0');

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 9 : 12,
            vertical: isCompact ? 5 : 7,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.76),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(.85)),
          ),
          child: Text(
            '$current / $total',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isCompact ? 8 : 10,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
              color: _navy.withOpacity(.62),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PRODUCT CONTENT
  // ===========================================================================

  Widget _buildProductContent(
    _ShowcaseProduct product, {
    required bool isCompact,
    required bool isVeryCompact,
  }) {
    final double titleSize = isVeryCompact
        ? 22
        : isCompact
        ? 25
        : 38;

    final double bodySize = isVeryCompact
        ? 12.5
        : isCompact
        ? 13.5
        : 16;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.eyebrow,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isCompact ? 7.5 : 9,
              fontWeight: FontWeight.w800,
              letterSpacing: isCompact ? 1.3 : 1.8,
              color: _blue,
            ),
          ),

          SizedBox(height: isCompact ? 9 : 13),

          Text(
            product.title,
            maxLines: isCompact ? 3 : 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: titleSize,
              height: 1.08,
              fontWeight: FontWeight.w800,
              letterSpacing: isCompact ? -.6 : -1.4,
              color: _navy,
            ),
          ),

          SizedBox(height: isCompact ? 10 : 14),

          Text(
            product.description,
            maxLines: isVeryCompact
                ? 4
                : isCompact
                ? 5
                : 8,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: bodySize,
              height: 1.55,
              fontWeight: FontWeight.w400,
              color: _navy.withOpacity(.55),
            ),
          ),

          SizedBox(height: isCompact ? 16 : 24),

          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: GiftPayTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 17 : 27,
                vertical: isCompact ? 10 : 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isCompact ? 10 : 10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.buttonLabel,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: isCompact ? 12.5 : 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 7),
                Icon(Icons.arrow_forward_rounded, size: isCompact ? 15 : 17),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // NAVIGATION
  // ===========================================================================

  Widget _buildNavigation({required bool isCompact}) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          _navigationButton(
            icon: Icons.arrow_back_rounded,
            onPressed: _showPrevious,
            isCompact: isCompact,
          ),

          SizedBox(width: isCompact ? 8 : 14),

          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_products.length, (index) {
                  final bool active = index == _currentIndex;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _selectProduct(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 5,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        width: active ? (isCompact ? 20 : 30) : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active ? _blue : _navy.withOpacity(.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          SizedBox(width: isCompact ? 8 : 14),

          _navigationButton(
            icon: Icons.arrow_forward_rounded,
            onPressed: _showNext,
            isCompact: isCompact,
          ),
        ],
      ),
    );
  }

  Widget _navigationButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isCompact,
  }) {
    final double size = isCompact ? 36 : 42;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _blue.withOpacity(.055),
            borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
            border: Border.all(color: _blue.withOpacity(.10)),
          ),
          child: Icon(
            icon,
            size: isCompact ? 16 : 18,
            color: _navy.withOpacity(.70),
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// SHOWCASE PRODUCT MODEL
// ==============================================================================

class _ShowcaseProduct {
  final String image;
  final String eyebrow;
  final String title;
  final String description;
  final String buttonLabel;

  const _ShowcaseProduct({
    required this.image,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.buttonLabel,
  });
}
