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
              _brandChip(
                label: "DStv",
                value: "dstv",
                assetLogo: "assets/providers/dstv.png",
                brandColor: Color(0xFF0054A6),
              ),
              _brandChip(
                label: "GOtv",
                value: "gotv",
                assetLogo: "assets/providers/gotv.png",
                brandColor: Color(0xFFC8102E),
              ),
              _brandChip(
                label: "StarTimes",
                value: "startimes",
                assetLogo: "assets/providers/startimes.png",
                brandColor: Color(0xFFF58220),
              ),
              _brandChip(
                label: "Showmax",
                value: "showmax",
                assetLogo: "assets/providers/showmax.png",
                brandColor: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _brandChip({
    required String label,
    required String value,
    required String assetLogo,
    required Color brandColor,
  }) {
    final isSelected = selected == value;

    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? brandColor.withOpacity(0.20)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? brandColor : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(assetLogo, height: 20, width: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
