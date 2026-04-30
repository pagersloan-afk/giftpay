import 'package:flutter/material.dart';
import 'shimmer_box.dart';

class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ShimmerBox(height: 45, width: 45, radius: 50), // avatar
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ShimmerBox(height: 12, width: 140),
              SizedBox(height: 8),
              ShimmerBox(height: 12, width: 90),
            ],
          ),
        ),

        const SizedBox(width: 12),
        const ShimmerBox(height: 12, width: 40),
      ],
    );
  }
}
