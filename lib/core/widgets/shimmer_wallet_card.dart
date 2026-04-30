import 'package:flutter/material.dart';
import 'shimmer_box.dart';

class ShimmerWalletCard extends StatelessWidget {
  const ShimmerWalletCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ShimmerBox(height: 20, width: 120),
          SizedBox(height: 16),
          ShimmerBox(height: 30, width: 180),
          SizedBox(height: 16),
          ShimmerBox(height: 20, width: 100),
        ],
      ),
    );
  }
}
