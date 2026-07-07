import 'package:flutter/material.dart';

class FinancialEducationSection extends StatelessWidget {
  const FinancialEducationSection({super.key});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Smart Utility Spending",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 22 : 26,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Learn how to manage electricity, airtime, and data spending with smart budgeting tips and reward strategies.",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isMobile ? 13 : 15,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Browse free resources",
              style: TextStyle(
                fontFamily: 'Inter',
                color: const Color(0xFFB31B1B),
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
