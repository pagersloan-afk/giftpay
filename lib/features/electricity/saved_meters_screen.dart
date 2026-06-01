import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utilityhub/features/electricity/models/saved_meter.dart';

class SavedMetersScreen extends StatelessWidget {
  final String userId;

  const SavedMetersScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Saved Meters")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("saved_meters")
            .orderBy("lastUsed", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No saved meters yet"));
          }

          final meters = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return SavedMeter(
              meterNumber: data["meterNumber"] ?? "",
              meterType: data["meterType"] ?? "01",
              discoCode: data["discoCode"] ?? "",
              customerName: data["customerName"] ?? "",
              lastUsed: data["lastUsed"] ?? 0,
            );
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meters.length,
            itemBuilder: (context, index) {
              final m = meters[index];
              return Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 12),
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
              );
            },
          );
        },
      ),
    );
  }
}
