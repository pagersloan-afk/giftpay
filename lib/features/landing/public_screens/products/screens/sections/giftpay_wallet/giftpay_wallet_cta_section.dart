import 'package:flutter/material.dart';

class GiftPayWalletCTASection extends StatelessWidget {
  const GiftPayWalletCTASection({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 39, 61, 104),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: const StadiumBorder(),
      ),
      onPressed: () => Navigator.pushNamed(context, '/login'),
      child: const Text(
        "Get Started",
        style: TextStyle(fontFamily: 'SegoeUI', fontSize: 18),
      ),
    );
  }
}
