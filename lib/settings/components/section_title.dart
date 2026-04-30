import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFE5E7EB),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 2,
          width: 48,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0AC8FF), Color(0xFF0288D1)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
        ),
      ],
    );
  }
}
