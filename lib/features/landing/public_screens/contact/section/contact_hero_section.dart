import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

// 🔵 GiftPay Contact Hero Banner
class ContactHeroSection extends StatelessWidget {
  const ContactHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: double.infinity,
      height: isMobile ? 240 : 400,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/contact.png"),
          fit: BoxFit.cover,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(maxWidth: isMobile ? 320 : 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: isMobile
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Text(
              "Let’s talk payments",
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "GiftPay provides secure, fast, and reliable financial tools for individuals and businesses. Reach out and let’s help you build smarter payment experiences.",
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isMobile ? 13 : 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  // ✅ Uniform color from GiftPayTheme
                  backgroundColor: GiftPayTheme.primaryBlue,
                  foregroundColor: Colors.white,

                  // ✅ Keep your current measurements
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text(
                  "Start the conversation",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
