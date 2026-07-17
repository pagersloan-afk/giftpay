import 'package:flutter/material.dart';

class LifestyleBenefitsSection extends StatelessWidget {
  const LifestyleBenefitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 24 : 40,
        ),

        // ⭐ Removed gray background
        // color: const Color(0xFFF9F9F9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Lifestyle Benefits Designed for You",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontWeight: FontWeight.w700,
                fontSize: isMobile ? 22 : 28,
                color: Colors.black87,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 32),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20, // ⭐ tightened spacing
              runSpacing: 20,
              children: [
                _benefit(
                  title: "GiftPay Rewards",
                  subtitle: "Earn cashback on every utility purchase.",
                  image: "assets/illustrations/rewards.png",
                  isMobile: isMobile,
                ),
                _benefit(
                  title: "GiftPay Travel",
                  subtitle: "Redeem rewards for flights and hotels.",
                  image: "assets/illustrations/travel.png",
                  isMobile: isMobile,
                ),
                _benefit(
                  title: "GiftPay Shopping",
                  subtitle: "Get exclusive deals and discounts.",
                  image: "assets/illustrations/shopping.png",
                  isMobile: isMobile,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefit({
    required String title,
    required String subtitle,
    required String image,
    required bool isMobile,
  }) {
    return Container(
      width: isMobile ? double.infinity : 350, // ⭐ reduced from 380 → 360
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: isMobile ? 120 : 140,
            child: Image.asset(image, fit: BoxFit.contain),
          ),

          const SizedBox(height: 20),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontWeight: FontWeight.w700,
              fontSize: isMobile ? 18 : 20,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isMobile ? 13 : 15,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
