import 'package:flutter/material.dart';

class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Find the best flights",
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Search domestic and international routes.",
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }
}
