import 'package:flutter/material.dart';

class BettingAmountSection extends StatelessWidget {
  final int? amount;
  final Function(int?) onChanged;

  const BettingAmountSection({
    super.key,
    required this.amount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Amount", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),

            TextField(
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final parsed = int.tryParse(v);
                onChanged(parsed);
              },
              decoration: const InputDecoration(
                hintText: "Enter amount (min ₦100)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
