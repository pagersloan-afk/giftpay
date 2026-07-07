import 'dart:ui';
import 'package:flutter/material.dart';

class BusinessSolutionsSection extends StatelessWidget {
  const BusinessSolutionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // ↓ Reduced vertical padding from 40 → 28
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 28,
      ), // ADJUSTED
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
              children: const [
                Text(
                  "GiftPay for Business",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12), // ↓ Reduced from 16 → 12
                Text(
                  "Automate bulk electricity tokens, airtime distribution, and corporate data plans with ease.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16), // ↓ Reduced from 20 → 16
                Text(
                  "Explore business solutions >",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
