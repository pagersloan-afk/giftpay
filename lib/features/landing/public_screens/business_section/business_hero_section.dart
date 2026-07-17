import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class BusinessHeroSection extends StatelessWidget {
  const BusinessHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      width: double.infinity,
      height: isMobile ? null : 480,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/illustrations/business_hero_bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 24 : 60,
      ),
      alignment: isMobile ? Alignment.center : Alignment.centerLeft,

      child: Container(
        padding: EdgeInsets.all(isMobile ? 18 : 32),
        constraints: BoxConstraints(maxWidth: isMobile ? 360 : 420),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: isMobile
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Text(
              "GiftPay for Business",
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontWeight: FontWeight.w700,
                fontSize: isMobile ? 22 : 28,
                color: Colors.black87,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              "Automate bulk electricity tokens, airtime distribution, and corporate data plans — all from one dashboard.",
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 13 : 15,
                color: Colors.black54,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: GiftPayTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Explore Business Solutions",
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
