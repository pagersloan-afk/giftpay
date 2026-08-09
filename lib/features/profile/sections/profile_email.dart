import 'package:flutter/material.dart';

class ProfileEmail extends StatelessWidget {
  final String email;

  const ProfileEmail({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 14),
        Text(
          email,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE5E7EB),
          ),
        ),
        const SizedBox(height: 26),
      ],
    );
  }
}
