import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class CareersValuesSection extends StatefulWidget {
  const CareersValuesSection({super.key});

  @override
  State<CareersValuesSection> createState() => _CareersValuesSectionState();
}

class _CareersValuesSectionState extends State<CareersValuesSection> {
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

        // ⭐ Desktop: Two cards per screen
        final double cardWidth = isMobile ? maxWidth * 0.75 : maxWidth * 0.45;

        final cards = [
          _ValueCard(
            imagePath: "assets/icons/culture-icon.png",
            title: "Culture of Innovation",
            description:
                "We encourage creativity, experimentation, and bold ideas that push payments forward.",
          ),
          _ValueCard(
            imagePath: "assets/icons/team-icon.png",
            title: "People First",
            description:
                "We invest in our teams, support growth, and foster an inclusive workplace.",
          ),
          _ValueCard(
            imagePath: "assets/icons/mission-icon.png",
            title: "Mission Driven",
            description:
                "Every project supports our mission: making payments simple, fast, and accessible.",
          ),
        ];

        return Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            children: [
              SizedBox(
                // ⭐ Adjust section height here
                height: isMobile ? 360 : 380,
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
                          ? GiftPayTheme.primaryBlue
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

class _ValueCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const _ValueCard({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      // ⭐ Card height control
      constraints: BoxConstraints(
        minHeight: isMobile ? 260 : 300,
        maxHeight: isMobile ? 260 : 300,
      ),

      padding: EdgeInsets.all(isMobile ? 12 : 16),
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
          // ⭐ Bold, large icon (adjust here)
          Image.asset(
            imagePath,
            height: isMobile ? 110 : 150, // ← bold icon size
          ),

          const SizedBox(height: 14),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700, // ← bolder title
              fontSize: isMobile ? 15 : 18,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isMobile ? 13 : 14,
                color: Colors.black54,
                height: 1.35,
              ),
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
