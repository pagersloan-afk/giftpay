import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utilityhub/features/electricity/models/saved_meter.dart';

class SavedMetersList extends StatelessWidget {
  final List<SavedMeter> meters;
  final Function(SavedMeter meter) onSelect;
  final String userId;
  final VoidCallback onViewAll; // ⭐ callback to navigate to SavedMetersScreen

  const SavedMetersList({
    super.key,
    required this.meters,
    required this.onSelect,
    required this.userId,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (meters.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    // ⭐ Only show 4 most recent
    final recentMeters = meters.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Saved Meters", style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),

        ...recentMeters.map((m) {
          return GestureDetector(
            onTap: () async {
              onSelect(m);
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(userId)
                  .collection("saved_meters")
                  .doc(m.meterNumber)
                  .update({"lastUsed": DateTime.now().millisecondsSinceEpoch});
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  Icon(Icons.flash_on, color: theme.colorScheme.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.meterNumber,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${m.customerName} • ${m.discoCode} • ${m.meterType == '01' ? 'Prepaid' : 'Postpaid'}",
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(userId)
                          .collection("saved_meters")
                          .doc(m.meterNumber)
                          .delete();
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),

        // ⭐ Show "View All" if more than 4
        if (meters.length > 4)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onViewAll,
              child: const Text("View All"),
            ),
          ),
      ],
    );
  }
}
