import 'package:flutter/material.dart';

class AirtimeHeroSection extends StatelessWidget {
  const AirtimeHeroSection({super.key});

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
            "Airtime Distribution",
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Automate airtime top‑ups for staff, teams, and personal use.",
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
