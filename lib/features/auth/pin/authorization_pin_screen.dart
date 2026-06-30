import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthorizationPinScreen extends StatefulWidget {
  const AuthorizationPinScreen({super.key});

  @override
  State<AuthorizationPinScreen> createState() => _AuthorizationPinScreenState();
}

class _AuthorizationPinScreenState extends State<AuthorizationPinScreen> {
  final pinCtrl = TextEditingController();
  bool saving = false;

  Future<void> savePin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (pinCtrl.text.length != 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("PIN must be 4 digits")));
      return;
    }

    setState(() => saving = true);

    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "authPin": pinCtrl.text,
    });

    setState(() => saving = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Authorization PIN saved")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Authorization PIN")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Set a 4‑digit authorization PIN for transfers, airtime, data, and bills.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: pinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(labelText: "Enter PIN"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saving ? null : savePin,
              child: saving
                  ? const CircularProgressIndicator()
                  : const Text(
                      "Save PIN",
                      style: TextStyle(
                        fontSize: 14, // ⭐ custom size
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
