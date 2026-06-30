import 'package:flutter/material.dart';

class CablePackageSection extends StatelessWidget {
  final String? provider;
  final bool loading;
  final List<Map<String, dynamic>> packages;
  final String? selectedCode;
  final Function(String code, int amount) onSelect;

  const CablePackageSection({
    super.key,
    required this.provider,
    required this.loading,
    required this.packages,
    required this.selectedCode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Package",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            if (provider == null)
              const Text(
                "Select a provider first.",
                style: TextStyle(fontSize: 14),
              )
            else if (packages.isEmpty)
              const Text("No packages loaded.", style: TextStyle(fontSize: 14))
            else
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true, // ⭐ prevents overflow
                      value: selectedCode,

                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),

                      dropdownColor: const Color(0xFF1F2937),

                      items: packages.map((p) {
                        return DropdownMenuItem<String>(
                          value: p["code"] as String,
                          child: Text(
                            "${p["name"]} - ₦${p["amount"]}",
                            overflow: TextOverflow.ellipsis, // ⭐ FIX
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),

                      onChanged: (v) {
                        final pkg = packages.firstWhere((p) => p["code"] == v);
                        onSelect(pkg["code"], pkg["amount"]);
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
