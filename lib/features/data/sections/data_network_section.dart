import 'package:flutter/material.dart';

class DataNetworkSection extends StatelessWidget {
  final String selectedNetworkCode;
  final Map<String, String> networkNames;
  final ValueChanged<String?> onChanged;

  const DataNetworkSection({
    super.key,
    required this.selectedNetworkCode,
    required this.networkNames,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedNetworkCode,
      dropdownColor: const Color(0xFF1F2937), // DARK SOLID DROPDOWN
      decoration: const InputDecoration(labelText: "Network"),
      items: networkNames.entries.map((entry) {
        return DropdownMenuItem(value: entry.key, child: Text(entry.value));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
