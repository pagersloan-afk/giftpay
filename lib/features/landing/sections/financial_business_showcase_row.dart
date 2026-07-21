import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/features/landing/sections/business_solutions_section.dart';
import 'package:utilityhub/features/landing/sections/product_showcase_section.dart';
import 'package:utilityhub/features/landing/sections/financial_education_section.dart';

// ⭐ Animated + Luxury Showcase Row (Carousel-style like ThreeCardSection)
class FinancialBusinessShowcaseRow extends StatefulWidget {
  const FinancialBusinessShowcaseRow({super.key});

  @override
  State<FinancialBusinessShowcaseRow> createState() =>
      _FinancialBusinessShowcaseRowState();
}

class _FinancialBusinessShowcaseRowState
    extends State<FinancialBusinessShowcaseRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> slideUp;
  late Animation<double> bgShift;

  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    slideUp = Tween<double>(
      begin: 40,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    bgShift = Tween<double>(
      begin: -0.6,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(int index, double cardWidth) {
    _scrollController.animateTo(
      index * (cardWidth + 20),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
    setState(() => _currentIndex = index);
  }

  Widget _uniformCard(Widget child) {
    return Container(
      constraints: const BoxConstraints(minHeight: 420),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, slideUp.value),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final bool isMobile = width < 768;

              final double cardWidth = isMobile ? width * 0.90 : width * 0.42;

              final cards = [
                _uniformCard(const FinancialEducationSection()),
                _uniformCard(const ProductShowcaseSection()),
                _uniformCard(const BusinessSolutionsSection()),
              ];

              return Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 1400),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12.0 : 16.0,
                    vertical: isMobile ? 24.0 : 40.0,
                  ),

                  // ⭐ Animated luxury gradient background
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(bgShift.value, -1),
                      end: Alignment(1, bgShift.value),
                      colors: [
                        Colors.white.withOpacity(0.90),
                        const Color(0xFF273D68).withOpacity(0.85),
                        const Color(0xFF4A6BB8).withOpacity(0.75),
                        const Color(0xFFE8E8E8).withOpacity(0.70),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Learn, Compare, and Automate — All in One Platform",
                        style: TextStyle(
                          fontFamily: 'SegoeUI',
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? 22.0 : 28.0,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        height: isMobile ? 520 : 660,
                        child: Stack(
                          children: [
                            ListView.separated(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: cards.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 20),
                              itemBuilder: (_, index) {
                                return SizedBox(
                                  width: cardWidth,
                                  child: cards[index],
                                );
                              },
                            ),

                            if (!isMobile) ...[
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                child: _ArrowButton(
                                  icon: Icons.arrow_back_ios_new,
                                  onTap: () {
                                    if (_currentIndex > 0) {
                                      _scrollTo(_currentIndex - 1, cardWidth);
                                    }
                                  },
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: _ArrowButton(
                                  icon: Icons.arrow_forward_ios,
                                  onTap: () {
                                    if (_currentIndex < cards.length - 1) {
                                      _scrollTo(_currentIndex + 1, cardWidth);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          cards.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: _currentIndex == i ? 14 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentIndex == i
                                  ? const Color(0xFF0033CC)
                                  : Colors.black26,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
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

// You already have _ArrowButton defined in your ThreeCardSection file.
// Reuse the same implementation here.
// ⭐ Arrow Button Widget
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}

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
  double hoverScale = 1.0;
  double parallaxOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return MouseRegion(
      onEnter: (_) {
        if (!isMobile) {
          setState(() => hoverScale = 1.03);
        }
      },
      onExit: (_) {
        if (!isMobile) {
          setState(() => hoverScale = 1.0);
        }
      },
      onHover: (event) {
        if (!isMobile) {
          setState(() => parallaxOffset = (event.localPosition.dx - 150) / 40);
        }
      },
      child: AnimatedScale(
        scale: hoverScale,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ⭐ Parallax icon
              Transform.translate(
                offset: Offset(parallaxOffset, 0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double iconSize = constraints.maxWidth * 0.80;
                    return SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: Image.asset(widget.imagePath, fit: BoxFit.contain),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 15 : 17,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 13 : 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 14),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, widget.linkRoute);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GiftPayTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 20,
                    vertical: isMobile ? 8 : 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  widget.linkText,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
