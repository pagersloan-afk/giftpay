import 'package:flutter/material.dart';

class DataNetworkSection extends StatelessWidget {
  final String selectedNetworkCode;
  final Map<String, String> networkNames;
  final ValueChanged<String?> onChanged;

  // ⭐ Add logos map
  final Map<String, String> networkLogos = const {
    "01": "assets/networks/mtn.png",
    "02": "assets/networks/glo.jpg",
    "03": "assets/networks/9mobile.png",
    "04": "assets/networks/airtel.png",
  };

  const DataNetworkSection({
    super.key,
    required this.selectedNetworkCode,
    required this.networkNames,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedNetworkCode,
      isExpanded: true,
      dropdownColor: const Color(0xFF1F2937),

      decoration: const InputDecoration(
        labelText: "Network",
        border: OutlineInputBorder(),
      ),

      // ⭐ Selected item UI (logo + name inline)
      selectedItemBuilder: (context) {
        return networkNames.entries.map((entry) {
          return Row(
            children: [
              Image.asset(networkLogos[entry.key]!, width: 22, height: 22),
              const SizedBox(width: 10),
              Text(entry.value, style: const TextStyle(fontSize: 15)),
            ],
          );
        }).toList();
      },

      // ⭐ Dropdown items (logo + name inline)
      items: networkNames.entries.map((entry) {
        return DropdownMenuItem(
          value: entry.key,
          child: Row(
            children: [
              Image.asset(networkLogos[entry.key]!, width: 22, height: 22),
              const SizedBox(width: 10),
              Text(entry.value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        );
      }).toList(),

      onChanged: onChanged,
    );
  }
}
