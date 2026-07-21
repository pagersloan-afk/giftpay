import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

// ⚫ Hero Marquee
class HeroMarqueeSection extends StatelessWidget {
  const HeroMarqueeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SizedBox(
      height: isMobile ? 220 : 400,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/about-hero-lg.png", fit: BoxFit.cover),
          Align(
            alignment: isMobile ? Alignment.bottomCenter : Alignment.bottomLeft,
            child: Container(
              margin: EdgeInsets.all(isMobile ? 12 : 16),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 12,
              ),
              decoration: BoxDecoration(
                color: isMobile
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Empowering payments for people and businesses",
                textAlign: isMobile ? TextAlign.center : TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 15 : 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🟣 Three-Card Section (Fully Responsive + Animated)
class ThreeCardSection extends StatefulWidget {
  const ThreeCardSection({super.key});

  @override
  State<ThreeCardSection> createState() => _ThreeCardSectionState();
}

class _ThreeCardSectionState extends State<ThreeCardSection> {
  final ScrollController _controller = ScrollController();
  int _currentIndex = 0;

  void _scrollTo(int index, double cardWidth) {
    _controller.animateTo(
      index * (cardWidth + 20),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // ⭐ TRUE responsive width (1400 max on desktop)
        final double maxWidth = constraints.maxWidth;

        final bool isMobile = maxWidth < 768;

        // ⭐ Card width now based on actual layout width
        final double cardWidth = isMobile
            ? maxWidth * 0.85
            : maxWidth * 0.40; // two cards visible on desktop

        final cards = [
          AnimatedInfoCard(
            imagePath: "assets/icons/card-investor-relations.png",
            title: "GiftPay for Partners",
            description:
                "Helping businesses scale with secure payments, APIs, and enterprise tools.",
            linkText: "Learn more",
            linkRoute: "/about/partners",
          ),
          AnimatedInfoCard(
            imagePath: "assets/icons/card-leadership.png",
            title: "Leadership & Vision",
            description:
                "Guided by innovation, transparency, and a mission to simplify digital payments.",
            linkText: "Learn more",
            linkRoute: "/about/leadership",
          ),
          AnimatedInfoCard(
            imagePath: "assets/icons/card-accessibility.png",
            title: "Accessibility & Inclusion",
            description:
                "Building financial tools that work for everyone, everywhere.",
            linkText: "Learn more",
            linkRoute: "/about/accessibility",
          ),
        ];

        return Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            children: [
              SizedBox(
                height: isMobile ? 420 : (maxWidth * 0.42).clamp(550, 600),

                child: Stack(
                  children: [
                    ListView.separated(
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: cards.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 20),
                      itemBuilder: (_, index) {
                        return SizedBox(width: cardWidth, child: cards[index]);
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
        );
      },
    );
  }
}

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

// 🟡 Career Promo (Animated + Luxury Gradient)
class CareerPromoSection extends StatefulWidget {
  const CareerPromoSection({super.key});

  @override
  State<CareerPromoSection> createState() => _CareerPromoSectionState();
}

class _CareerPromoSectionState extends State<CareerPromoSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> fadeIn;
  late Animation<double> slideUp;

  double hoverScale = 1.0;
  double parallaxOffset = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    slideUp = Tween<double>(
      begin: 40,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: fadeIn.value,
          child: Transform.translate(
            offset: Offset(0, slideUp.value),
            child: MouseRegion(
              onEnter: (_) {
                if (!isMobile) setState(() => hoverScale = 1.03);
              },
              onExit: (_) {
                if (!isMobile) setState(() => hoverScale = 1.0);
              },
              onHover: (event) {
                if (!isMobile) {
                  setState(
                    () => parallaxOffset = (event.localPosition.dx - 150) / 40,
                  );
                }
              },
              child: AnimatedScale(
                scale: hoverScale,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],

                    // ⭐ Luxury multi-layer gradient background
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(
                          0xFF273D68,
                        ).withOpacity(0.95), // GiftPay navy
                        const Color(0xFF4A6BB8).withOpacity(0.85), // soft blue
                        const Color(0xFFF9F9F9).withOpacity(0.90), // white glow
                      ],
                    ),
                  ),

                  child: isMobile
                      ? Column(
                          children: [
                            _promoImage(),
                            const SizedBox(height: 16),
                            _promoContent(context, isMobile),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(flex: 1, child: _promoImage()),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 1,
                              child: _promoContent(context, isMobile),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ⭐ Parallax Image + Glow Pulse (fixed)
  Widget _promoImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow pulse behind image
        AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4A6BB8).withOpacity(0.25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A6BB8).withOpacity(0.45),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
        ),

        // Parallax image
        Transform.translate(
          offset: Offset(parallaxOffset, 0),
          child: Image.asset(
            "assets/icons/career-promo.png",
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  // ⭐ Content stays same but looks better on gradient
  Widget _promoContent(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          "Build a career that shapes the future of payments",
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 18 : 22,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Join GiftPay and help create secure, fast, and accessible financial tools for millions.",
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isMobile ? 13 : 14,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/about/careers');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: GiftPayTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 24,
              vertical: isMobile ? 10 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text(
            "Join GiftPay",
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
