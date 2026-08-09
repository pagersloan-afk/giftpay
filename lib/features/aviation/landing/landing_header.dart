import 'package:flutter/material.dart';

class LandingHeader extends StatelessWidget {
  const LandingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Book Flights",
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Search and book flights across Nigeria and international routes.",
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
