import 'package:flutter/material.dart';
import 'shimmer_box.dart';

class ShimmerServiceCard extends StatelessWidget {
  const ShimmerServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          ShimmerBox(height: 40, width: 40, radius: 50),
          SizedBox(height: 12),
          ShimmerBox(height: 12, width: 80),
        ],
      ),
    );
  }
}
