import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class HeroMarqueeSection extends StatelessWidget {
  const HeroMarqueeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Container(
      width: double.infinity,
      height: isMobile ? 300 : 500,
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isMobile ? 18 : 28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17243D).withOpacity(0.14),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/about-hero-lg.png", fit: BoxFit.cover),

          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF071120).withOpacity(0.78),
                ],
              ),
            ),
          ),

          Positioned(
            left: isMobile ? 20 : 42,
            right: isMobile ? 20 : 42,
            bottom: isMobile ? 20 : 36,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: const Text(
                    "ABOUT GIFTPAY",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Empowering payments for people and businesses",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: isMobile ? 25 : 40,
                    height: 1.08,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Secure digital tools designed around the way people live, work, and transact.",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: isMobile ? 13 : 16,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.84),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThreeCardSection extends StatefulWidget {
  const ThreeCardSection({super.key});

  @override
  State<ThreeCardSection> createState() => _ThreeCardSectionState();
}

class _ThreeCardSectionState extends State<ThreeCardSection> {
  final ScrollController _controller = ScrollController();

  int _currentIndex = 0;

  final List<_InfoCardData> _cards = const [
    _InfoCardData(
      imagePath: "assets/icons/card-investor-relations.png",
      title: "GiftPay for Partners",
      description:
          "Helping businesses scale with secure payments, APIs, and enterprise tools.",
      linkText: "Learn more",
      linkRoute: "/about/partners",
    ),
    _InfoCardData(
      imagePath: "assets/icons/card-leadership.png",
      title: "Leadership & Vision",
      description:
          "Guided by innovation, transparency, and a mission to simplify digital payments.",
      linkText: "Learn more",
      linkRoute: "/about/leadership",
    ),
    _InfoCardData(
      imagePath: "assets/icons/card-accessibility.png",
      title: "Accessibility & Inclusion",
      description:
          "Building financial tools that work for everyone, everywhere.",
      linkText: "Learn more",
      linkRoute: "/about/accessibility",
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollTo(int index, double cardWidth) {
    final target = index * (cardWidth + 20);

    _controller.animateTo(
      target.clamp(0.0, _controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 768;

        final cardWidth = isMobile ? width * 0.84 : width * 0.43;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
          child: Column(
            children: [
              SizedBox(
                height: isMobile ? 465 : 560,
                child: Stack(
                  children: [
                    ListView.separated(
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 4 : 36,
                        vertical: 10,
                      ),
                      itemCount: _cards.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 20),
                      itemBuilder: (_, index) {
                        final card = _cards[index];

                        return SizedBox(
                          width: cardWidth,
                          child: AnimatedInfoCard(
                            imagePath: card.imagePath,
                            title: card.title,
                            description: card.description,
                            linkText: card.linkText,
                            linkRoute: card.linkRoute,
                          ),
                        );
                      },
                    ),

                    if (!isMobile)
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

                    if (!isMobile)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: _ArrowButton(
                          icon: Icons.arrow_forward_ios,
                          onTap: () {
                            if (_currentIndex < _cards.length - 1) {
                              _scrollTo(_currentIndex + 1, cardWidth);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              _CarouselIndicator(
                count: _cards.length,
                currentIndex: _currentIndex,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCardData {
  final String imagePath;
  final String title;
  final String description;
  final String linkText;
  final String linkRoute;

  const _InfoCardData({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.linkText,
    required this.linkRoute,
  });
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
  bool _hovered = false;
  double _parallax = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return MouseRegion(
      onEnter: (_) {
        if (!isMobile) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) {
        if (!isMobile) {
          setState(() {
            _hovered = false;
            _parallax = 0;
          });
        }
      },
      onHover: (event) {
        if (!isMobile) {
          setState(() {
            _parallax = (event.localPosition.dx - 150) / 45;
          });
        }
      },
      child: AnimatedScale(
        scale: _hovered ? 1.025 : 1,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.94),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF17243D,
                ).withOpacity(_hovered ? 0.14 : 0.08),
                blurRadius: _hovered ? 28 : 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Transform.translate(
                  offset: Offset(_parallax, 0),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(widget.imagePath, fit: BoxFit.contain),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  fontSize: isMobile ? 17 : 20,
                  color: const Color(0xFF17243D),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 13 : 14,
                  height: 1.55,
                  color: const Color(0xFF647084),
                ),
              ),

              const SizedBox(height: 18),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, widget.linkRoute);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GiftPayTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 18 : 22,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  widget.linkText,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
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

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Ink(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.94),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF17243D)),
          ),
        ),
      ),
    );
  }
}

class _CarouselIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _CarouselIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? GiftPayTheme.primaryBlue : const Color(0xFFB8C1D0),
            borderRadius: BorderRadius.circular(50),
          ),
        );
      }),
    );
  }
}

class CareerPromoSection extends StatefulWidget {
  const CareerPromoSection({super.key});

  @override
  State<CareerPromoSection> createState() => _CareerPromoSectionState();
}

class _CareerPromoSectionState extends State<CareerPromoSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _hovered = false;
  double _parallax = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final slide =
              (1 - Curves.easeOutCubic.transform(_controller.value)) * 35;

          return Transform.translate(
            offset: Offset(0, slide),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
              child: MouseRegion(
                onEnter: (_) {
                  if (!isMobile) {
                    setState(() => _hovered = true);
                  }
                },
                onExit: (_) {
                  if (!isMobile) {
                    setState(() {
                      _hovered = false;
                      _parallax = 0;
                    });
                  }
                },
                onHover: (event) {
                  if (!isMobile) {
                    setState(() {
                      _parallax = (event.localPosition.dx - 250) / 50;
                    });
                  }
                },
                child: AnimatedScale(
                  scale: _hovered ? 1.015 : 1,
                  duration: const Duration(milliseconds: 240),
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 20 : 34),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF172A4F),
                          Color(0xFF273D68),
                          Color(0xFF4A6BB8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF17243D).withOpacity(0.20),
                          blurRadius: 30,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: isMobile
                        ? Column(
                            children: [
                              _promoImage(),
                              const SizedBox(height: 24),
                              _promoContent(context, true),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: _promoImage()),
                              const SizedBox(width: 36),
                              Expanded(child: _promoContent(context, false)),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _promoImage() {
    return Transform.translate(
      offset: Offset(_parallax, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8AA8EA).withOpacity(0.28),
                  blurRadius: 50,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          Image.asset(
            "assets/icons/career-promo.png",
            width: 300,
            height: 300,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

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
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 24 : 32,
            height: 1.15,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          "Join GiftPay and help create secure, fast, and accessible financial tools for millions.",
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isMobile ? 14 : 16,
            height: 1.55,
            color: Colors.white.withOpacity(0.82),
          ),
        ),

        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/about/careers');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: GiftPayTheme.primaryBlue,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: const Text(
            "Join GiftPay",
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
