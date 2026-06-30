import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditDailyTransferLimitScreen extends StatefulWidget {
  const EditDailyTransferLimitScreen({super.key});

  @override
  State<EditDailyTransferLimitScreen> createState() =>
      _EditDailyTransferLimitScreenState();
}

class _EditDailyTransferLimitScreenState
    extends State<EditDailyTransferLimitScreen> {
  bool loading = true;
  bool saving = false;

  String kycStatus = "pending";
  int dailyLimit = 0;

  final limitCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLimit();
  }

  Future<void> _loadLimit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final data = doc.data() ?? {};

    kycStatus = data["kycStatus"] ?? "pending";
    dailyLimit = data["dailyTransferLimit"] ?? 50000;

    limitCtrl.text = dailyLimit.toString();

    setState(() => loading = false);
  }

  Future<void> _saveLimit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (kycStatus != "approved") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("KYC must be approved to customize transfer limits"),
        ),
      );
      return;
    }

    final newLimit = int.tryParse(limitCtrl.text.trim());
    if (newLimit == null || newLimit < 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid daily limit")),
      );
      return;
    }

    setState(() => saving = true);

    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "dailyTransferLimit": newLimit,
    });

    setState(() => saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Daily transfer limit updated")),
    );

    Navigator.pop(context);
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
      appBar: AppBar(title: const Text("Daily Transfer Limit")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kycStatus == "approved"
                  ? "Set your preferred daily transfer limit."
                  : "Your KYC is not approved. You cannot customize limits yet.",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: limitCtrl,
              keyboardType: TextInputType.number,
              enabled: kycStatus == "approved",
              decoration: InputDecoration(
                labelText: kycStatus == "approved"
                    ? "Enter daily limit"
                    : "KYC required",
                labelStyle: const TextStyle(color: Colors.white54),
                disabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0AC8FF)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saving ? null : _saveLimit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0AC8FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: saving
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text("Save Limit"),
            ),
          ],
        ),
      ),
    );
  }
}
