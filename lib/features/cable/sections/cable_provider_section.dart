import 'package:flutter/material.dart';

class CableProviderSection extends StatelessWidget {
  final String? selected;
  final Function(String) onSelect;

  const CableProviderSection({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // ⭐ FULL WIDTH
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06), // your GP‑1 card
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Provider",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip("DStv", "dstv"),
              _chip("GOtv", "gotv"),
              _chip("StarTimes", "startimes"),
              _chip("Showmax", "showmax"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final isSelected = selected == value;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
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
      onSelected: (_) => onSelect(value),
    );
  }
}
