import 'package:flutter/material.dart';

class PressHighlightsSection extends StatefulWidget {
  const PressHighlightsSection({super.key});

  @override
  State<PressHighlightsSection> createState() => _PressHighlightsSectionState();
}

class _PressHighlightsSectionState extends State<PressHighlightsSection> {
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
        final double maxWidth = constraints.maxWidth;
        final bool isMobile = maxWidth < 768;
        final double cardWidth = isMobile ? maxWidth * 0.85 : maxWidth * 0.40;

        final cards = [
          _PressCard(
            imagePath: "assets/icons/press-announcement.png",
            title: "GiftPay Announces Global Expansion",
            description:
                "New partnerships and infrastructure upgrades bring GiftPay to 12 new countries.",
          ),
          _PressCard(
            imagePath: "assets/icons/press-award.png",
            title: "GiftPay Wins Fintech Innovation Award",
            description:
                "Recognized for excellence in secure digital payments and customer experience.",
          ),
          _PressCard(
            imagePath: "assets/icons/press-update.png",
            title: "Major Platform Update Released",
            description:
                "Improved performance, new APIs, and enhanced fraud protection.",
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

class _PressCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const _PressCard({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
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
          Image.asset(imagePath, height: isMobile ? 120 : 160),
          const SizedBox(height: 16),
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
        ],
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
