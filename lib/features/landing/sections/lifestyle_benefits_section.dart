import 'package:flutter/material.dart';

class LifestyleBenefitsSection extends StatefulWidget {
  const LifestyleBenefitsSection({super.key});

  @override
  State<LifestyleBenefitsSection> createState() =>
      _LifestyleBenefitsSectionState();
}

class _LifestyleBenefitsSectionState extends State<LifestyleBenefitsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> slideUp;
  late Animation<double> bgShift;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, slideUp.value),
          child: Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 1400),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 24 : 40,
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
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Lifestyle Benefits Designed for You",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontWeight: FontWeight.w700,
                      fontSize: isMobile ? 22 : 28,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _benefit(
                        title: "GiftPay Rewards",
                        subtitle: "Earn cashback on every utility purchase.",
                        image: "assets/illustrations/rewards.png",
                        isMobile: isMobile,
                      ),
                      _benefit(
                        title: "GiftPay Travel",
                        subtitle: "Redeem rewards for flights and hotels.",
                        image: "assets/illustrations/travel.png",
                        isMobile: isMobile,
                      ),
                      _benefit(
                        title: "GiftPay Shopping",
                        subtitle: "Get exclusive deals and discounts.",
                        image: "assets/illustrations/shopping.png",
                        isMobile: isMobile,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ⭐ Luxury animated benefit card
  Widget _benefit({
    required String title,
    required String subtitle,
    required String image,
    required bool isMobile,
  }) {
    return _AnimatedBenefitCard(
      title: title,
      subtitle: subtitle,
      image: image,
      isMobile: isMobile,
    );
  }
}

// ⭐ Benefit Card with hover + parallax + transparent white
class _AnimatedBenefitCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String image;
  final bool isMobile;

  const _AnimatedBenefitCard({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.isMobile,
  });

  @override
  State<_AnimatedBenefitCard> createState() => _AnimatedBenefitCardState();
}

class _AnimatedBenefitCardState extends State<_AnimatedBenefitCard> {
  double hoverScale = 1.0;
  double parallaxOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hoverScale = 1.03),
      onExit: (_) => setState(() => hoverScale = 1.0),
      onHover: (event) {
        setState(() {
          parallaxOffset = (event.localPosition.dx - 150) / 40;
        });
      },
      child: AnimatedScale(
        scale: hoverScale,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,

        child: Container(
          width: widget.isMobile ? double.infinity : 350,
          padding: const EdgeInsets.all(24),

          // ⭐ Transparent white + glass effect
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.60),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 6),
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
              Transform.translate(
                offset: Offset(parallaxOffset, 0),
                child: SizedBox(
                  height: widget.isMobile ? 120 : 140,
                  child: Image.asset(widget.image, fit: BoxFit.contain),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontWeight: FontWeight.w700,
                  fontSize: widget.isMobile ? 18 : 20,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: widget.isMobile ? 13 : 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
