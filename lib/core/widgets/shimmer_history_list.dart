import 'package:flutter/material.dart';
import 'shimmer_list_tile.dart';

class ShimmerHistoryList extends StatelessWidget {
  const ShimmerHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        10,
        (i) => const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: ShimmerListTile(),
        ),
      ),
    );
  }
}
