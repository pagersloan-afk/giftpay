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
    final String? validSelectedNetwork =
        networkMap.values.contains(selectedNetworkCode)
        ? selectedNetworkCode
        : null;

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
          initialValue: validSelectedNetwork,

          isExpanded: true,

          menuMaxHeight: 300,

          dropdownColor: const Color(0xFF1F2937),

          iconEnabledColor: themeColor,

          style: const TextStyle(color: Colors.white, fontSize: 16),

          items: networkMap.entries.map((entry) {
            final String name = entry.key;
            final String code = entry.value;

            final String? logoPath = AirtimeTheme.networkLogos[name];

            return DropdownMenuItem<String>(
              value: code,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (logoPath != null && logoPath.isNotEmpty)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Image.asset(
                        logoPath,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          return Icon(
                            Icons.sim_card,
                            size: 24,
                            color: themeColor,
                          );
                        },
                      ),
                    )
                  else
                    Icon(Icons.sim_card, size: 24, color: themeColor),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          onChanged: networkMap.isEmpty
              ? null
              : (value) {
                  if (value == null) {
                    return;
                  }

                  onNetworkChanged(value);
                },

          decoration: const InputDecoration(labelText: "Network"),
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
