import 'package:flutter/material.dart';

// 🔵 Additional Cards Section (Animated + Parallax Background)
class AdditionalCardsSection extends StatefulWidget {
  const AdditionalCardsSection({super.key});

  @override
  State<AdditionalCardsSection> createState() => _AdditionalCardsSectionState();
}

class _AdditionalCardsSectionState extends State<AdditionalCardsSection>
    with SingleTickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  int _currentIndex = 0;

  late AnimationController _bgController;
  late Animation<double> fadeIn;
  late Animation<double> slideUp;

  double parallaxShift = 0.0;

  @override
  void initState() {
    super.initState();

    // ⭐ Background animation controller
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeOut));

    slideUp = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeOutCubic),
    );

    // ⭐ Parallax listener
    _controller.addListener(() {
      setState(() {
        parallaxShift = (_controller.offset / 300).clamp(0, 1);
      });
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _scrollTo(int index, double cardWidth) {
    _controller.animateTo(
      index * (cardWidth + 20),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    final double cardWidth = isMobile ? width * 0.85 : width * 0.40;

    final cards = [
      AnimatedAdditionalCard(
        imagePath: "assets/icons/responsibility-icon.png",
        title: "Security & Trust",
        description:
            "GiftPay is committed to secure transactions, fraud prevention, and user protection.",
        linkText: "Learn more >",
        linkRoute: "/about/security",
      ),
      AnimatedAdditionalCard(
        imagePath: "assets/icons/news-icon.png",
        title: "GiftPay News",
        description:
            "Stay updated with new features, partnerships, and product releases.",
        linkText: "Learn more >",
        linkRoute: "/about/news",
      ),
      AnimatedAdditionalCard(
        imagePath: "assets/icons/stories-icon.png",
        title: "Customer Stories",
        description:
            "Real experiences from people and businesses using GiftPay every day.",
        linkText: "Get inspired >",
        linkRoute: "/about/stories",
      ),
    ];

    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Opacity(
          opacity: fadeIn.value,
          child: Transform.translate(
            offset: Offset(0, slideUp.value),
            child: Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),

              // ⭐ Animated luxury gradient background
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1 + parallaxShift, -1),
                  end: Alignment(1, 1 - parallaxShift),
                  colors: [
                    const Color(0xFF273D68).withOpacity(0.90), // navy
                    const Color(0xFF4A6BB8).withOpacity(0.75), // soft blue
                    const Color(0xFFF0F0F0).withOpacity(0.65), // gray
                    Colors.white.withOpacity(0.55), // transparent white
                  ],
                ),
              ),

              child: Column(
                children: [
                  SizedBox(
                    height: isMobile ? 420 : 480,
                    child: Stack(
                      children: [
                        ListView.separated(
                          controller: _controller,
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
                        duration: const Duration(milliseconds: 250),
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
          ),
        );
      },
    );
  }
}

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
  double hoverScale = 1.0;
  double parallaxOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return MouseRegion(
      onEnter: (_) {
        if (!isMobile) setState(() => hoverScale = 1.03);
      },
      onExit: (_) {
        if (!isMobile) setState(() => hoverScale = 1.0);
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
        child: Transform.translate(
          offset: Offset(parallaxOffset, 0),
          child: AdditionalCard(
            imagePath: widget.imagePath,
            title: widget.title,
            description: widget.description,
            linkText: widget.linkText,
            linkRoute: widget.linkRoute,
          ),
        ),
      ),
    );
  }
}

// 🟣 Individual Card Widget
class AdditionalCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final String linkText;
  final String linkRoute;

  const AdditionalCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.linkText,
    required this.linkRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ⭐ IMAGE SECTION — now expands naturally
          LayoutBuilder(
            builder: (context, constraints) {
              // ⭐ MAIN CONTROL: Adjust image height relative to card width
              // Recommended: 0.45 → 0.60 for large visible images
              final double imgHeight = (constraints.maxWidth * 0.60).clamp(
                180,
                320,
              );

              return SizedBox(
                width: double.infinity,
                height: imgHeight, // ⭐ Card expands automatically
                child: Image.asset(
                  imagePath,

                  // ⭐ FIT MODE:
                  // BoxFit.contain → shows full icon clearly
                  // BoxFit.cover → fills width for dramatic effect
                  fit: BoxFit.contain,
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          Text(
            title,
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
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 13 : 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, linkRoute);
            },
            child: Text(
              linkText,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: isMobile ? 13 : 14,
                color: const Color(0xFF0033CC),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🟠 History Section
class HistorySection extends StatefulWidget {
  const HistorySection({super.key});

  @override
  State<HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<HistorySection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> slideUp;
  late Animation<double> glowShift;

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

    glowShift = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, slideUp.value),
          child: Stack(
            children: [
              // ⭐ Glow background layer
              Positioned.fill(
                child: CustomPaint(
                  painter: _HistoryGlowPainter(glowShift.value),
                ),
              ),

              // ⭐ Main content
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  // ⭐ Transparent white glass effect
                  color: Colors.white.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.30),
                    width: 1.2,
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Our Journey",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: isMobile ? 22 : 26,
                        color: Colors.black87,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      "GiftPay started with a mission: make payments simple, fast, and accessible. Today, millions rely on us for everyday transactions.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.black.withOpacity(0.75),
                        height: 1.55,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/about/history');
                      },
                      child: Text(
                        "Explore our story",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 14 : 16,
                          color: const Color(0xFF0033CC),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ⭐ Glow painter for luxury background
class _HistoryGlowPainter extends CustomPainter {
  final double shift;
  _HistoryGlowPainter(this.shift);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);

    // Top-left glow
    paint.color = const Color(0xFF4A6BB8).withOpacity(0.25 + shift * 0.15);
    canvas.drawCircle(
      Offset(size.width * (0.25 + 0.05 * shift), size.height * 0.22),
      130,
      paint,
    );

    // Bottom-right glow
    paint.color = const Color(0xFF273D68).withOpacity(0.22 + shift * 0.12);
    canvas.drawCircle(
      Offset(size.width * (0.78 - 0.05 * shift), size.height * 0.85),
      170,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _HistoryGlowPainter oldDelegate) =>
      oldDelegate.shift != shift;
}

// ⚪ Footer
class PremiumFooter extends StatelessWidget {
  const PremiumFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final links = [
      {"label": "Privacy & Legal", "route": "/privacy"},
      {"label": "Security", "route": "/security"},
      {"label": "Terms of Use", "route": "/terms"},
      {"label": "Report Fraud", "route": "/fraud"},
      {"label": "Sitemap", "route": "/sitemap"},
      {"label": "About GiftPay", "route": "/about"},
      {"label": "Careers", "route": "/careers"},
      {"label": "Accessibility", "route": "/accessibility"},
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFF222222),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 20 : 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: isMobile ? 12 : 16,
            runSpacing: isMobile ? 8 : 12,
            alignment: WrapAlignment.center,
            children: links
                .map(
                  (link) => TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, link["route"]!);
                    },
                    child: Text(
                      link["label"]!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: isMobile ? 12 : 13,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            "© 2026 GiftPay. All rights reserved.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 11 : 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
