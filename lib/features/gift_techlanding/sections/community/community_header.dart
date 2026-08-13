import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class CommunityHeader extends StatelessWidget {
  final bool isMobile;

  const CommunityHeader({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Community & Ecosystem",
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: isMobile ? 27 : 35,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: const Color(0xFF142850),
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(
                  "Connect with our developer ecosystem, explore community programs, follow our updates, and discover the platforms powering Africa’s digital future.",
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: isMobile ? 14.5 : 16,
                    height: 1.55,
                    color: Colors.black.withOpacity(0.62),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (!isMobile) _GlowBadge(),
      ],
    );
  }
}

class _GlowBadge extends StatefulWidget {
  @override
  State<_GlowBadge> createState() => _GlowBadgeState();
}

class _GlowBadgeState extends State<_GlowBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: GiftPayTheme.primaryBlue.withOpacity(
              0.06 + (_glowController.value * 0.03),
            ),
            border: Border.all(
              color: GiftPayTheme.primaryBlue.withOpacity(0.12),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: GiftPayTheme.primaryBlue,
                  boxShadow: [
                    BoxShadow(
                      color: GiftPayTheme.primaryBlue.withOpacity(0.45),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Explore GiftTech Community",
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: GiftPayTheme.primaryBlue,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
