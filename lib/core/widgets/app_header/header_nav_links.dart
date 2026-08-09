import 'package:flutter/material.dart';

class HeaderNavLinks extends StatelessWidget {
  final bool showLinks;

  const HeaderNavLinks({super.key, required this.showLinks});

  @override
  Widget build(BuildContext context) {
    if (!showLinks) return const SizedBox.shrink();

    return Row(
      children: [
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/about'),
          child: const Text(
            "About",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 20),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/contact'),
          child: const Text(
            "Contact",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}
