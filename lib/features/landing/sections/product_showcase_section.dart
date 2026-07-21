import 'dart:async';
import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class ProductShowcaseSection extends StatefulWidget {
  const ProductShowcaseSection({super.key});

  @override
  State<ProductShowcaseSection> createState() => _ProductShowcaseSectionState();
}

class _ProductShowcaseSectionState extends State<ProductShowcaseSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _currentIndex = 0;
  Timer? _timer;

  // ⭐ Add unlimited product assets here
  final List<String> showcaseImages = [
    "assets/illustrations/a2_utility_plan_compare.png",
    "assets/illustrations/a2_rewards.png",
    "assets/illustrations/a2_travel.png",
    "assets/illustrations/a2_shopping.png",
    "assets/illustrations/a2_aviation.png",
    "assets/illustrations/a2_rides.png",
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _startAutoRotation();
  }

  void _startAutoRotation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fadeController.reverse().then((_) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % showcaseImages.length;
        });
        _fadeController.forward();
      });
    });

    _fadeController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 900;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12.0 : 24.0,
          vertical: isMobile ? 20.0 : 40.0,
        ),

        child: Container(
          padding: EdgeInsets.all(isMobile ? 16.0 : 28.0),
          decoration: BoxDecoration(
            // ⭐ TV‑screen glass effect
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(isMobile ? 12.0 : 14.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.30),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: isMobile ? 12.0 : 22.0,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final double imgHeight = isMobile ? 240.0 : 320.0;

                  return SizedBox(
                    width: double.infinity,
                    height: imgHeight,

                    // ⭐ Animated TV‑screen fade transition
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          showcaseImages[_currentIndex],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: isMobile ? 16.0 : 20.0),

              Text(
                "Find the Right Utility Plan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 20.0 : 24.0,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: isMobile ? 10.0 : 12.0),

              Text(
                "Compare electricity providers, data bundles, and airtime plans to get the best value.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: isMobile ? 13.0 : 15.0,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              SizedBox(height: isMobile ? 18.0 : 24.0),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: GiftPayTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20.0 : 28.0,
                    vertical: isMobile ? 12.0 : 16.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                child: const Text(
                  "Compare Plans",
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
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
