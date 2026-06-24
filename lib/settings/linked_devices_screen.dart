import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class LinkedDevicesScreen extends StatefulWidget {
  const LinkedDevicesScreen({super.key});

  @override
  State<LinkedDevicesScreen> createState() => _LinkedDevicesScreenState();
}

class _LinkedDevicesScreenState extends State<LinkedDevicesScreen> {
  // ⭐ Mocked device list (replace with real API later)
  List<Map<String, dynamic>> devices = [
    {
      "name": "iPhone 14 Pro",
      "location": "Port Harcourt, Nigeria",
      "lastActive": "Active now",
      "isCurrent": true,
      "icon": Icons.phone_iphone,
    },
    {
      "name": "Windows PC",
      "location": "Lagos, Nigeria",
      "lastActive": "2 days ago",
      "isCurrent": false,
      "icon": Icons.computer,
    },
    {
      "name": "Samsung Galaxy S22",
      "location": "Abuja, Nigeria",
      "lastActive": "1 week ago",
      "isCurrent": false,
      "icon": Icons.android,
    },
  ];

  void removeDevice(int index) {
    final device = devices[index];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D21),
        title: const Text(
          "Remove Device",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to remove '${device["name"]}'?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => devices.removeAt(index));
            },
            child: const Text(
              "Remove",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderr(title: "Linked Devices"),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        children: [
          const Text(
            "These are the devices currently logged into your GiftPay account.",
            style: TextStyle(
              color: Color(0xFFE5E7EB),
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          ...List.generate(devices.length, (index) {
            final d = devices[index];

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),

                  child: Row(
                    children: [
                      Icon(d["icon"], color: Colors.white, size: 28),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d["name"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              d["location"],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              d["lastActive"],
                              style: TextStyle(
                                color: d["isCurrent"]
                                    ? Colors.greenAccent
                                    : Colors.white54,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (!d["isCurrent"])
                        TextButton(
                          onPressed: () => removeDevice(index),
                          child: const Text(
                            "Remove",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
              ],
            );
          }),
        ],
      ),
    );
  }
}
