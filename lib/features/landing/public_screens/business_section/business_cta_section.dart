import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class BusinessCTASection extends StatelessWidget {
  const BusinessCTASection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 900),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: isMobile ? 32 : 48,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Let’s power your business with automation",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontWeight: FontWeight.w700,
                fontSize: isMobile ? 22 : 28,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              "Speak with a GiftPay Business specialist to explore tailored automation solutions.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 13 : 15,
                color: Colors.black54,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: isMobile ? double.infinity : null,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/contact');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GiftPayTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 32,
                    vertical: isMobile ? 14 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Contact Us",
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
