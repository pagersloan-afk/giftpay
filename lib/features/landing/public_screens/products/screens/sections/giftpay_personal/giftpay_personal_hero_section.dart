import 'package:flutter/material.dart';

class GiftPayPersonalHeroSection extends StatelessWidget {
  const GiftPayPersonalHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 40 : 80,
      ),
      decoration: const BoxDecoration(color: Color.fromARGB(255, 39, 61, 104)),
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: const [
          Text(
            "GiftPay Personal",
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Instant electricity, airtime, and data purchases — all in one simple personal dashboard.",
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
