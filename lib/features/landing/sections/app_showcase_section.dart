import 'package:flutter/material.dart';

class AppShowcaseSection extends StatelessWidget {
  const AppShowcaseSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 24 : 40,
        ),
        color: const Color(0xFFF9F9F9),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Digital Tools Built for Ease",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 20 : 24,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Track utilities, manage rewards, receive instant notifications, and automate payments.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 13 : 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
