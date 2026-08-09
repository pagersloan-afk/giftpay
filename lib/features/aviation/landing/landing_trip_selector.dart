import 'package:flutter/material.dart';

class LandingTripSelector extends StatelessWidget {
  const LandingTripSelector({super.key});

  Widget _item(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: active
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.06),
        border: Border.all(
          color: active
              ? Colors.white.withOpacity(0.35)
              : Colors.white.withOpacity(0.12),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(active ? 0.95 : 0.70),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _item("One‑way", true),
        _item("Round‑trip", false),
        _item("Multi‑city", false),
      ],
    );
  }
}
