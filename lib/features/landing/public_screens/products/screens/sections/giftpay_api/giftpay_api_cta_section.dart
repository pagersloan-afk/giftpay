import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class GiftPayApiCTASection extends StatelessWidget {
  const GiftPayApiCTASection({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, '/api-docs'),
      style: ElevatedButton.styleFrom(
        // ✅ Uniform GiftPay global button color
        backgroundColor: GiftPayTheme.primaryBlue,
        foregroundColor: Colors.white,

        // ✅ Keep your exact measurements
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      child: const Text(
        "View API Documentation",
        style: TextStyle(fontFamily: 'SegoeUI', fontSize: 18),
      ),
    );
  }
}
