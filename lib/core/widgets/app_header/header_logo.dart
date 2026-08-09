import 'package:flutter/material.dart';

class HeaderLogo extends StatelessWidget {
  const HeaderLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/landing"),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.55),
                  Colors.white.withOpacity(0.95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Text(
              "GiftPay",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: Colors.white.withOpacity(0.9),
                shadows: [
                  Shadow(
                    blurRadius: 14,
                    color: Colors.black.withOpacity(0.45),
                    offset: const Offset(0, 2),
                  ),
                  Shadow(
                    blurRadius: 22,
                    color: Colors.blue.withOpacity(0.28),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.blue.withOpacity(0.35), Colors.transparent],
                    radius: 0.85,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, 4),
                child: Image.asset(
                  "assets/logo/giftpay_1.png",
                  height: 94,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
