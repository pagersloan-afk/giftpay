import 'package:flutter/material.dart';

class CableHeaderSection extends StatelessWidget {
  const CableHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.tv, size: 32, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Pay for DStv, GOtv, StarTimes and Showmax easily.",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
