import 'package:flutter/material.dart';

class CareersLifeSection extends StatefulWidget {
  const CareersLifeSection({super.key});

  @override
  State<CareersLifeSection> createState() => _CareersLifeSectionState();
}

class _CareersLifeSectionState extends State<CareersLifeSection>
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
                  setState(() {
                    parallaxOffset = (event.localPosition.dx - 150) / 40;
                  });
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
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF273D68).withOpacity(0.95),
                        const Color(0xFF4A6BB8).withOpacity(0.85),
                        const Color(0xFFF9F9F9).withOpacity(0.90),
                      ],
                    ),
                  ),
                  child: isMobile
                      ? Column(
                          children: [
                            _lifeImage(),
                            const SizedBox(height: 16),
                            _lifeContent(isMobile),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(flex: 1, child: _lifeImage()),
                            const SizedBox(width: 24),
                            Expanded(flex: 1, child: _lifeContent(isMobile)),
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

  Widget _lifeImage() {
    return Transform.translate(
      offset: Offset(parallaxOffset, 0),
      child: Image.asset(
        "assets/images/careers-life.png",
        width: double.infinity,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _lifeContent(bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          "Life at GiftPay",
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
          "We celebrate collaboration, diversity, and growth. Our teams work on meaningful projects that impact millions.",
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isMobile ? 13 : 14,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
      ],
    );
  }
}
