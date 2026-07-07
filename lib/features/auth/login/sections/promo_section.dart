import 'dart:ui';
import 'package:flutter/material.dart';

class PromoSection extends StatelessWidget {
  const PromoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // ↓ Reduced outer padding from 40 → 28
      padding: const EdgeInsets.all(28), // ADJUSTED
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            // ↓ Reduced inner padding from 40 → 28
            padding: const EdgeInsets.all(28), // ADJUSTED
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Fast, Secure & Global Digital Payments",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 16), // ↓ Reduced from 20 → 16

                const Text(
                  "Transfer money, fund your wallet, buy utilities, and enjoy instant rewards — all in one place.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24), // ↓ Reduced from 30 → 24

                Wrap(
                  spacing: 32, // ↓ Reduced from 40 → 32
                  runSpacing: 16, // ↓ Reduced from 20 → 16
                  children: [
                    _stat("5M+", "Transactions Processed"),
                    _stat("Instant", "Wallet Funding"),
                    _stat("24/7", "Transfers & Support"),
                    _stat("100%", "Token Delivery"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }
}
