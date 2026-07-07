import 'package:flutter/material.dart';

class LifestyleBenefitsSection extends StatelessWidget {
  const LifestyleBenefitsSection({super.key});

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
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _benefit(
              "GiftPay Rewards",
              "Earn cashback on every utility purchase.",
              isMobile,
            ),
            _benefit(
              "GiftPay Travel",
              "Redeem rewards for flights and hotels.",
              isMobile,
            ),
            _benefit(
              "GiftPay Shopping",
              "Get exclusive deals and discounts.",
              isMobile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefit(String title, String subtitle, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 320,
      padding: const EdgeInsets.all(20),
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
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 16 : 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 13 : 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
