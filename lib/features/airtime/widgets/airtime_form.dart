import 'package:flutter/material.dart';
import '../theme/airtime_theme.dart';

class AirtimeForm extends StatelessWidget {
  final TextEditingController phoneCtrl;
  final TextEditingController amountCtrl;
  final Map<String, String> networkMap;
  final String selectedNetworkCode;
  final Color themeColor;
  final VoidCallback onAutoDetectNetwork;
  final ValueChanged<String?> onNetworkChanged;

  const AirtimeForm({
    super.key,
    required this.phoneCtrl,
    required this.amountCtrl,
    required this.networkMap,
    required this.selectedNetworkCode,
    required this.themeColor,
    required this.onAutoDetectNetwork,
    required this.onNetworkChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: selectedNetworkCode.isEmpty
              ? null
              : selectedNetworkCode,
          items: networkMap.entries.map((entry) {
            final name = entry.key;
            final code = entry.value;

            return DropdownMenuItem(
              value: code,
              child: Row(
                children: [
                  Image.asset(
                    AirtimeTheme.networkLogos[name]!,
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(name),
                ],
              ),
            );
          }).toList(),
          onChanged: onNetworkChanged,

          // ⭐ FIX: remove border override
          decoration: const InputDecoration(labelText: "Network"),

          // ⭐ FIX: force dark dropdown background
          dropdownColor: const Color(0xFF1F2937),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          onChanged: (_) => onAutoDetectNetwork(),
          decoration: const InputDecoration(labelText: "Phone Number"),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Amount (min ₦50)"),
        ),
      ],
    );
  }
}
