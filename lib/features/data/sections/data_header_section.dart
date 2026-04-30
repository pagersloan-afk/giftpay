import 'package:flutter/material.dart';

class DataHeaderSection extends StatelessWidget {
  const DataHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Select Network & Plan",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}
