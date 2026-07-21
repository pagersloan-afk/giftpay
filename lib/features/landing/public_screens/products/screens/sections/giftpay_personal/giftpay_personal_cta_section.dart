import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class GiftPayPersonalCTASection extends StatelessWidget {
  const GiftPayPersonalCTASection({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, '/login'),
      style: ElevatedButton.styleFrom(
        backgroundColor: GiftPayTheme.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      child: const Text(
        "Create Personal Account",
        style: TextStyle(fontFamily: 'SegoeUI', fontSize: 18),
      ),
    );
  }
}
