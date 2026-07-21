import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class BusinessDashboardCTASection extends StatelessWidget {
  const BusinessDashboardCTASection({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, '/login'),
      style: ElevatedButton.styleFrom(
        // ✅ Uniform color from GiftPayTheme
        backgroundColor: GiftPayTheme.primaryBlue,
        foregroundColor: Colors.white,

        // ✅ Keep your current measurements
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      child: const Text(
        "Get Started",
        style: TextStyle(fontFamily: 'SegoeUI', fontSize: 18),
      ),
    );
  }
}
