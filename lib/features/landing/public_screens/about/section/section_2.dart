import 'package:flutter/material.dart';

class AdditionalCardsSection extends StatefulWidget {
  const AdditionalCardsSection({super.key});

  @override
  State<AdditionalCardsSection> createState() => _AdditionalCardsSectionState();
}

class _AdditionalCardsSectionState extends State<AdditionalCardsSection>
    with SingleTickerProviderStateMixin {
  final ScrollController _controller = ScrollController();

  late final AnimationController _animationController;

  int _currentIndex = 0;
  double _parallaxShift = 0;

  final List<_AdditionalCardData> _cards = const [
    _AdditionalCardData(
      imagePath: "assets/icons/responsibility-icon.png",
      title: "Security & Trust",
      description:
          "GiftPay is committed to secure transactions, fraud prevention, and user protection.",
      linkText: "Learn more",
      linkRoute: "/about/security",
    ),
    _AdditionalCardData(
      imagePath: "assets/icons/news-icon.png",
      title: "GiftPay News",
      description:
          "Stay updated with new features, partnerships, and product releases.",
      linkText: "Learn more",
      linkRoute: "/about/news",
    ),
    _AdditionalCardData(
      imagePath: "assets/icons/stories-icon.png",
      title: "Customer Stories",
      description:
          "Real experiences from people and businesses using GiftPay every day.",
      linkText: "Get inspired",
      linkRoute: "/about/stories",
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _controller.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_controller.hasClients) return;

    final value = (_controller.offset / 400).clamp(0.0, 1.0);

    setState(() {
      _parallaxShift = value;
    });
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleScroll)
      ..dispose();

    _animationController.dispose();

    super.dispose();
  }

  void _scrollTo(int index, double cardWidth) {
    if (!_controller.hasClients) return;

    final target = index * (cardWidth + 20);

    _controller.animateTo(
      target.clamp(0.0, _controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    final cardWidth = isMobile ? width * 0.84 : width * 0.43;

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
      child: Transform.translate(
        offset: Offset(0, (1 - _animationController.value) * 35),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment(-1 + _parallaxShift * 0.2, -1),
                end: Alignment(1, 1 - _parallaxShift * 0.2),
                colors: [
                  const Color(0xFF273D68).withOpacity(0.96),
                  const Color(0xFF4A6BB8).withOpacity(0.88),
                  const Color(0xFFEAF0FA).withOpacity(0.94),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF17243D).withOpacity(0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 42),
                  child: Column(
                    children: [
                      Text(
                        "EXPLORE GIFTPAY",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: isMobile ? 11 : 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: Colors.white.withOpacity(0.72),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Designed around trust, people, and progress",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: isMobile ? 22 : 30,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Discover the stories, ideas, and principles behind the GiftPay experience.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: isMobile ? 13 : 15,
                          height: 1.5,
                          color: Colors.white.withOpacity(0.78),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: isMobile ? 445 : 500,
                  child: Stack(
                    children: [
                      ListView.separated(
                        controller: _controller,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 18 : 42,
                          vertical: 8,
                        ),
                        itemCount: _cards.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 20),
                        itemBuilder: (_, index) {
                          final card = _cards[index];

                          return SizedBox(
                            width: cardWidth,
                            child: AnimatedAdditionalCard(
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
                          left: 10,
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
                          right: 10,
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

                const SizedBox(height: 10),

                _CarouselIndicator(
                  count: _cards.length,
                  currentIndex: _currentIndex,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdditionalCardData {
  final String imagePath;
  final String title;
  final String description;
  final String linkText;
  final String linkRoute;

  const _AdditionalCardData({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.linkText,
    required this.linkRoute,
  });
}

class AnimatedAdditionalCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final String linkText;
  final String linkRoute;

  const AnimatedAdditionalCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.linkText,
    required this.linkRoute,
  });

  @override
  State<AnimatedAdditionalCard> createState() => _AnimatedAdditionalCardState();
}

class _AnimatedAdditionalCardState extends State<AnimatedAdditionalCard> {
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
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hovered ? 0.12 : 0.07),
                blurRadius: _hovered ? 24 : 16,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Transform.translate(
                  offset: Offset(_parallax, 0),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(widget.imagePath, fit: BoxFit.contain),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 17 : 19,
                  fontWeight: FontWeight.w800,
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

              const SizedBox(height: 14),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, widget.linkRoute);
                },
                child: Text(
                  "${widget.linkText}  →",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3159A8),
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

class HistorySection extends StatefulWidget {
  const HistorySection({super.key});

  @override
  State<HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<HistorySection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
      child: Transform.translate(
        offset: Offset(0, (1 - _controller.value) * 30),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 24 : 44),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.90)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF17243D).withOpacity(0.09),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4A6BB8).withOpacity(0.10),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF4A6BB8),
                    size: 25,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  "Our Journey",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF17243D),
                  ),
                ),

                const SizedBox(height: 14),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Text(
                    "GiftPay started with a mission: make payments simple, fast, and accessible. Today, our vision continues to grow around the people, businesses, and communities we serve.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: isMobile ? 14 : 16,
                      height: 1.65,
                      color: const Color(0xFF5C687B),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/about/history');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF3159A8),
                  ),
                  child: const Text(
                    "Explore our story  →",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
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
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(50),
          ),
        );
      }),
    );
  }
}
