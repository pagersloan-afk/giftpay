import 'package:flutter/material.dart';

class GiftCardsHeroSection extends StatelessWidget {
  const GiftCardsHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SizedBox(
      height: isMobile ? 220 : 400,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/giftcards-hero-lg.png", fit: BoxFit.cover),

          Align(
            alignment: isMobile ? Alignment.bottomCenter : Alignment.bottomLeft,
            child: Container(
              margin: EdgeInsets.all(isMobile ? 12 : 16),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 12,
              ),
              decoration: BoxDecoration(
                color: isMobile
                    ? Colors.transparent
                    : Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Digital Gift Cards for Every Occasion",
                textAlign: isMobile ? TextAlign.center : TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 15 : 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
