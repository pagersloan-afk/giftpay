import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utilityhub/core/security/device_trust.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class LinkedDevicesScreen extends StatefulWidget {
  const LinkedDevicesScreen({super.key});

  @override
  State<LinkedDevicesScreen> createState() => _LinkedDevicesScreenState();
}

class _LinkedDevicesScreenState extends State<LinkedDevicesScreen> {
  String? currentDeviceId;

  @override
  void initState() {
    super.initState();
    loadCurrentDeviceId();
  }

  Future<void> loadCurrentDeviceId() async {
    currentDeviceId = await DeviceTrust.getDeviceId();
    setState(() {});
  }

  IconData _deviceIcon(String type) {
    switch (type) {
      case "android":
        return Icons.android;
      case "ios":
        return Icons.phone_iphone;
      default:
        return Icons.devices;
    }
  }

  void _removeDevice(String userId, String deviceId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D21),
        title: const Text(
          "Remove Device",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to remove this device?",
          style: TextStyle(color: Colors.white70),
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
            onPressed: () async {
              Navigator.pop(context);

              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(userId)
                  .collection("devices")
                  .doc(deviceId)
                  .delete();

              if (deviceId == currentDeviceId) {
                await DeviceTrust.clearDeviceTrust();
              }

              setState(() {});
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
    final user = FirebaseAuth.instance.currentUser!;
    final devicesRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("devices")
        .orderBy("lastLogin", descending: true);

    return Scaffold(
      appBar: const AppHeaderr(title: "Linked Devices"),
      body: StreamBuilder<QuerySnapshot>(
        stream: devicesRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No linked devices found.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView(
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

              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final deviceId = data["deviceId"];
                final isCurrent = deviceId == currentDeviceId;

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _deviceIcon(data["deviceType"]),
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data["deviceName"] ?? "Unknown Device",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isCurrent ? "This device" : "Trusted device",
                                  style: TextStyle(
                                    color: isCurrent
                                        ? Colors.greenAccent
                                        : Colors.white54,
                                    fontSize: 12.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Last active: ${data["lastLogin"] != null ? data["lastLogin"].toDate().toString() : "Unknown"}",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.55),
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (!isCurrent)
                            TextButton(
                              onPressed: () =>
                                  _removeDevice(user.uid, deviceId),
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
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
