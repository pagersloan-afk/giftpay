import 'package:flutter/material.dart';

class ParentOverlayCard extends StatelessWidget {
  final Widget child;

  const ParentOverlayCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400),
        margin: EdgeInsets.symmetric(
          vertical: isMobile ? 16 : 32,
          horizontal: isMobile ? 12 : 0,
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isMobile ? 14 : 20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: isMobile ? 10 : 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
