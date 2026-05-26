import 'package:flutter/material.dart';
import 'package:utilityhub/features/electricity/models/saved_meter.dart';

class SavedMetersList extends StatelessWidget {
  final List<SavedMeter> meters;
  final Function(SavedMeter meter) onSelect;

  const SavedMetersList({
    super.key,
    required this.meters,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (meters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Saved Meters",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        ...meters.map((m) {
          return GestureDetector(
            onTap: () => onSelect(m),
            child: Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flash_on, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.meterNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${m.customerName} • ${m.discoCode} • ${m.meterType == '01' ? 'Prepaid' : 'Postpaid'}",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
