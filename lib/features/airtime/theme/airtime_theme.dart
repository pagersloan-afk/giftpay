// lib/features/airtime/theme/airtime_theme.dart
import 'package:flutter/material.dart';

class AirtimeTheme {
  static const Map<String, String> networkLogos = {
    "MTN": "assets/networks/mtn.png",
    "GLO": "assets/networks/glo.jpg",
    "Airtel": "assets/networks/airtel.png",
    "9mobile": "assets/networks/9mobile.png",
  };

  static const Map<String, Color> networkColors = {
    "MTN": Color(0xFFFFCC00),
    "GLO": Color(0xFF00A859),
    "9mobile": Color(0xFF006E3A),
    "Airtel": Color(0xFFE60000),
  };

  static Color themeColorFor(
    Map<String, String> networkMap,
    String selectedCode,
  ) {
    if (networkMap.isEmpty || selectedCode.isEmpty) return Colors.blue;

    final entry = networkMap.entries.firstWhere(
      (e) => e.value == selectedCode,
      orElse: () => const MapEntry("MTN", "01"),
    );

    return networkColors[entry.key] ?? Colors.blue;
  }
}
