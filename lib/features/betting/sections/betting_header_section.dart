import 'package:flutter/material.dart';

class BettingHeaderSection extends StatelessWidget {
  const BettingHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Icon(Icons.sports_soccer, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Fund your betting wallet instantly — NairaBet, Bet9ja, SportyBet, BetKing, and more.",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
