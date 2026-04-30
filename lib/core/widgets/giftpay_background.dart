import 'package:flutter/material.dart';

class GiftPayBackground extends StatelessWidget {
  final Widget child;

  const GiftPayBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // ⭐ Darker base (matches SettingsScreen)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF05070A), // deep black-slate
                  Color(0xFF0A0D12), // subtle dark blend
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ⭐ Soft blue glow (top-right)
          Positioned(
            top: -140,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.16),
              ),
            ),
          ),

          // ⭐ Purple glow (bottom-left)
          Positioned(
            bottom: -160,
            left: -120,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.13),
              ),
            ),
          ),

          // ⭐ Subtle center glow (more muted)
          Positioned(
            top: 220,
            left: 60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.025),
              ),
            ),
          ),

          // ⭐ Faded GiftPay watermark (consistent with SettingsScreen)
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.045, // subtle, premium
                child: Image.asset(
                  "assets/logo/giftpay_1.png",
                  width: 480,
                  height: 480,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ⭐ App content
          child,
        ],
      ),
    );
  }
}
