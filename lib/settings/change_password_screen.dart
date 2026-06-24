import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool loading = false;
  bool showCurrent = false;
  bool showNew = false;
  bool showConfirm = false;

  final auth = FirebaseAuth.instance;

  Future<void> changePassword() async {
    final user = auth.currentUser;

    if (user == null) {
      _toast("User not logged in");
      return;
    }

    if (newCtrl.text.trim() != confirmCtrl.text.trim()) {
      _toast("New passwords do not match");
      return;
    }

    if (newCtrl.text.trim().length < 6) {
      _toast("Password must be at least 6 characters");
      return;
    }

    setState(() => loading = true);

    try {
      // ⭐ STEP 1 — Re-authenticate user
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentCtrl.text.trim(),
      );

      await user.reauthenticateWithCredential(cred);

      // ⭐ STEP 2 — Update password
      await user.updatePassword(newCtrl.text.trim());

      _toast("Password updated successfully");

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _toast(e.message ?? "Error updating password");
    }

    setState(() => loading = false);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ⭐ USE YOUR CUSTOM HEADER
      appBar: const AppHeaderr(title: "Change Password"),

      body: AppResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ⭐ CURRENT PASSWORD
              TextField(
                controller: currentCtrl,
                obscureText: !showCurrent,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showCurrent ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => showCurrent = !showCurrent),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ⭐ NEW PASSWORD
              TextField(
                controller: newCtrl,
                obscureText: !showNew,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showNew ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => showNew = !showNew),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ⭐ CONFIRM PASSWORD
              TextField(
                controller: confirmCtrl,
                obscureText: !showConfirm,
                decoration: InputDecoration(
                  labelText: "Confirm New Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showConfirm ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => showConfirm = !showConfirm),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : changePassword,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Update Password"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
