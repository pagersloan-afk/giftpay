import 'package:flutter/material.dart';

class ResponsiveContentWidth extends StatelessWidget {
  final Widget child;

  const ResponsiveContentWidth({super.key, required this.child});

  static double widthFor(double screenWidth) {
    // --------------------------------------------------------------
    // Normal laptop / small desktop
    // --------------------------------------------------------------

    if (screenWidth <= 1366) {
      return 550;
    }

    // --------------------------------------------------------------
    // 1367 - 1600
    // --------------------------------------------------------------

    if (screenWidth <= 1600) {
      return _lerp(550, 700, screenWidth, 1366, 1600);
    }

    // --------------------------------------------------------------
    // 1601 - 1920
    // --------------------------------------------------------------

    if (screenWidth <= 1920) {
      return _lerp(700, 850, screenWidth, 1600, 1920);
    }

    // --------------------------------------------------------------
    // 1921 - 2200
    // --------------------------------------------------------------

    if (screenWidth <= 2200) {
      return _lerp(850, 950, screenWidth, 1920, 2200);
    }

    // --------------------------------------------------------------
    // 2201 - 2400
    // --------------------------------------------------------------

    if (screenWidth <= 2400) {
      return _lerp(950, 1050, screenWidth, 2200, 2400);
    }

    // --------------------------------------------------------------
    // Very large displays
    // --------------------------------------------------------------

    return 1050;
  }

  static double _lerp(
    double start,
    double end,
    double value,
    double min,
    double max,
  ) {
    final progress = ((value - min) / (max - min)).clamp(0.0, 1.0);

    return start + ((end - start) * progress);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final contentWidth = widthFor(screenWidth);

    return SizedBox(width: contentWidth, child: child);
  }
}
