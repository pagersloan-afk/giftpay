import 'package:flutter/material.dart';

class TicketHeader extends StatelessWidget {
  const TicketHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Boarding Pass",
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Your flight has been confirmed.",
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }
}
