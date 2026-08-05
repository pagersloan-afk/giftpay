import 'package:flutter/material.dart';

class NinBvnSection extends StatefulWidget {
  final TextEditingController ninCtrl;
  final TextEditingController bvnCtrl;

  const NinBvnSection({
    super.key,
    required this.ninCtrl,
    required this.bvnCtrl,
  });

  @override
  State<NinBvnSection> createState() => _NinBvnSectionState();
}

class _NinBvnSectionState extends State<NinBvnSection> {
  String selected = "NIN";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ChoiceChip(
              label: const Text("NIN"),
              selected: selected == "NIN",
              onSelected: (_) => setState(() => selected = "NIN"),
            ),
            const SizedBox(width: 12),
            ChoiceChip(
              label: const Text("BVN"),
              selected: selected == "BVN",
              onSelected: (_) => setState(() => selected = "BVN"),
            ),
          ],
        ),

        const SizedBox(height: 16),

        if (selected == "NIN")
          TextField(
            controller: widget.ninCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Enter NIN",
              border: OutlineInputBorder(),
            ),
          ),

        if (selected == "BVN")
          TextField(
            controller: widget.bvnCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Enter BVN",
              border: OutlineInputBorder(),
            ),
          ),
      ],
    );
  }
}
