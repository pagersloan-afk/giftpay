import 'package:flutter/material.dart';

class BettingProviderSection extends StatelessWidget {
  final String? selected;
  final Function(String) onSelect;

  const BettingProviderSection({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final providers = [
      "NAIRABET",
      "BET9JA",
      "SPORTYBET",
      "BETKING",
      "MSPORT",
      "1XBET",
    ];

    return Container(
      width: double.infinity, // ⭐ FULL WIDTH LIKE OTHER SECTIONS
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06), // GP‑1 transparent card
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.all(16),

      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: providers.map((p) {
          final isSelected = selected == p;

          return ChoiceChip(
            label: Text(p, style: const TextStyle(color: Colors.white)),
            selected: isSelected,
            selectedColor: Colors.blue.withOpacity(0.20),
            backgroundColor: Colors.white.withOpacity(0.06),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(
                color: isSelected ? Colors.blue : Colors.white24,
                width: isSelected ? 2 : 1,
              ),
            ),
            onSelected: (_) => onSelect(p),
          );
        }).toList(),
      ),
    );
  }
}
