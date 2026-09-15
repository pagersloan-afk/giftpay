import 'package:flutter/material.dart';

import '../controller/airtime_controller.dart';
import '../theme/airtime_theme.dart';

class AirtimeForm extends StatelessWidget {
  final TextEditingController phoneCtrl;
  final TextEditingController amountCtrl;

  final Map<String, String> networkMap;
  final String selectedNetworkCode;
  final Color themeColor;

  final VoidCallback onAutoDetectNetwork;
  final ValueChanged<String?> onNetworkChanged;

  final List<RecentAirtimeNumber> recentNumbers;

  final ValueChanged<RecentAirtimeNumber> onRecentNumberSelected;

  final ValueChanged<String> onRecentNumberRemoved;

  const AirtimeForm({
    super.key,
    required this.phoneCtrl,
    required this.amountCtrl,
    required this.networkMap,
    required this.selectedNetworkCode,
    required this.themeColor,
    required this.onAutoDetectNetwork,
    required this.onNetworkChanged,
    required this.recentNumbers,
    required this.onRecentNumberSelected,
    required this.onRecentNumberRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ======================================================
        // RECENT NUMBERS
        // ======================================================
        if (recentNumbers.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Recent Numbers",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: themeColor,
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recentNumbers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),

              itemBuilder: (context, index) {
                final recent = recentNumbers[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(14),

                  onTap: () {
                    onRecentNumberSelected(recent);
                  },

                  child: Container(
                    width: 170,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: themeColor.withOpacity(0.25)),
                      color: themeColor.withOpacity(0.06),
                    ),

                    child: Stack(
                      children: [
                        // ==================================================
                        // PHONE ICON
                        // ==================================================
                        Positioned(
                          left: 0,
                          top: 10,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: themeColor.withOpacity(0.12),
                            ),
                            child: Icon(
                              Icons.phone_android,
                              size: 20,
                              color: themeColor,
                            ),
                          ),
                        ),

                        // ==================================================
                        // REMOVE BUTTON
                        // ==================================================
                        Positioned(
                          right: -6,
                          top: -8,
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.more_vert,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            onSelected: (value) {
                              if (value == "remove") {
                                onRecentNumberRemoved(recent.phone);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem<String>(
                                value: "remove",
                                child: Text("Remove"),
                              ),
                            ],
                          ),
                        ),

                        // ==================================================
                        // PHONE + NETWORK
                        // ==================================================
                        Positioned(
                          left: 48,
                          right: 4,
                          top: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recent.phone,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.visible,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 4),

                              if (recent.network.isNotEmpty)
                                Text(
                                  recent.network,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),
        ],
        // ======================================================
        // NETWORK
        // ======================================================
        DropdownButtonFormField<String>(
          initialValue: selectedNetworkCode.isEmpty
              ? null
              : selectedNetworkCode,

          items: networkMap.entries.map((entry) {
            final name = entry.key;
            final code = entry.value;

            return DropdownMenuItem<String>(
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

          decoration: const InputDecoration(labelText: "Network"),

          dropdownColor: const Color(0xFF1F2937),
        ),

        const SizedBox(height: 16),

        // ======================================================
        // PHONE
        // ======================================================
        TextField(
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          onChanged: (_) {
            onAutoDetectNetwork();
          },
          decoration: const InputDecoration(labelText: "Phone Number"),
        ),

        const SizedBox(height: 16),

        // ======================================================
        // AMOUNT
        // ======================================================
        TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Amount (min ₦50)"),
        ),
      ],
    );
  }
}
