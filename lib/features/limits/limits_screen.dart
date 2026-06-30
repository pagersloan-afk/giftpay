import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class LimitsScreen extends StatefulWidget {
  const LimitsScreen({super.key});

  @override
  State<LimitsScreen> createState() => _LimitsScreenState();
}

class _LimitsScreenState extends State<LimitsScreen> {
  bool loading = true;

  String kycStatus = "pending";

  int dailyTransferLimit = 0;
  int dailyAirtimeLimit = 0;
  int monthlyLimit = 0;

  @override
  void initState() {
    super.initState();
    _loadLimits();
  }

  Future<void> _loadLimits() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final data = doc.data() ?? {};

    kycStatus = data["kycStatus"] ?? "pending";

    dailyTransferLimit = data["dailyTransferLimit"] ?? 500000;
    dailyAirtimeLimit = data["dailyAirtimeLimit"] ?? 100000;
    monthlyLimit = data["monthlyLimit"] ?? 5000000;

    setState(() => loading = false);
  }

  String _formatLimit(int value) {
    if (kycStatus == "approved" && value == -1) {
      return "Unlimited";
    }
    return "₦${value.toString()}";
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF05070A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF05070A),
      appBar: const AppHeaderr(title: "Limits"),

      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.06,
                child: Image.asset(
                  "assets/logo/giftpay_1.png",
                  width: 420,
                  height: 420,
                ),
              ),
            ),
          ),

          AppResponsiveLayout(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Manage your daily and monthly transaction limits.",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 20),

                  _buildLimitTile(
                    context,
                    title: "Daily Transfer Limit",
                    value: _formatLimit(dailyTransferLimit),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/edit-daily-transfer-limit",
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  _buildLimitTile(
                    context,
                    title: "Daily Airtime/Data Limit",
                    value: _formatLimit(dailyAirtimeLimit),
                    onTap: () {
                      Navigator.pushNamed(context, "/edit-daily-airtime-limit");
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitTile(
    BuildContext context, {
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1115),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
