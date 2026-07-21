import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class AppShowcaseSection extends StatefulWidget {
  const AppShowcaseSection({super.key});

  @override
  State<AppShowcaseSection> createState() => _AppShowcaseSectionState();
}

class _AppShowcaseSectionState extends State<AppShowcaseSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> bgShift;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    bgShift = Tween<double>(
      begin: -1,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1400),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 24 : 40,
            ),

            // ⭐ Transparent animated container
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(bgShift.value, -1),
                end: Alignment(1, bgShift.value),
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.03),
                  Colors.white.withOpacity(0.08),
                ],
              ),
            ),

            child: _BounceShowcaseCard(isMobile: isMobile),
          ),
        );
      },
    );
  }
}

// ⭐ Bounce animation card (no tilt, no flip)
class _BounceShowcaseCard extends StatefulWidget {
  final bool isMobile;
  const _BounceShowcaseCard({required this.isMobile});

  @override
  State<_BounceShowcaseCard> createState() => _BounceShowcaseCardState();
}

class _BounceShowcaseCardState extends State<_BounceShowcaseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),

      child: ScaleTransition(
        scale: _scaleAnimation,

        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),

          // ⭐ Transparent glass card (clickable)
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.30),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Digital Tools Built for Ease",
                      style: TextStyle(
                        fontFamily: 'SegoeUI',
                        fontWeight: FontWeight.w700,
                        fontSize: widget.isMobile ? 20 : 24,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Track utilities, manage rewards, receive instant notifications, and automate payments.",
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

              if (!widget.isMobile) const SizedBox(width: 24),

              if (!widget.isMobile)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GiftPayTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        "Explore Tools",
                        style: TextStyle(
                          fontFamily: 'SegoeUI',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
