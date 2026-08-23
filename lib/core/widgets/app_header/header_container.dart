import 'dart:ui';

import 'package:flutter/material.dart';

class HeaderContainer extends StatelessWidget {
  final Widget child;

  const HeaderContainer({super.key, required this.child});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final horizontalPadding = width < 700
        ? 14.0
        : width < 1050
        ? 22.0
        : 30.0;

    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  navy,
                  const Color(0xFF2D4778),
                  const Color(0xFF304F83),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.09),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 9),
                ),
                BoxShadow(
                  color: blue.withOpacity(0.055),
                  blurRadius: 36,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Left atmospheric glow.
                Positioned(
                  left: -100,
                  top: -125,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: blue.withOpacity(0.09),
                    ),
                  ),
                ),

                // Right atmospheric glow.
                Positioned(
                  right: -115,
                  top: -155,
                  child: Container(
                    width: 310,
                    height: 310,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightBlue.withOpacity(0.055),
                    ),
                  ),
                ),

                // Very subtle center sheen.
                Positioned(
                  left: 420,
                  top: -180,
                  child: Container(
                    width: 460,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.018),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1440),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
