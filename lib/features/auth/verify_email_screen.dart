import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool checking = false;
  bool sending = false;

  int cooldown = 0; // seconds remaining
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startCooldown() {
    setState(() => cooldown = 60);

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (cooldown == 0) {
        t.cancel();
      } else {
        setState(() => cooldown--);
      }
    });
  }

  Future<void> _checkVerification() async {
    setState(() => checking = true);

    await FirebaseAuth.instance.currentUser!.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      Navigator.pushReplacementNamed(context, "/login");
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Email not verified yet")));
    }

    setState(() => checking = false);
  }

  Future<void> _resendEmail() async {
    if (cooldown > 0) return;

    setState(() => sending = true);

    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification email sent again")),
      );

      startCooldown();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => sending = false);
  }

  Future<void> _changeEmail() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushNamedAndRemoveUntil(context, "/signup", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "Verify Your Email",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "A verification link has been sent to your email.\nPlease verify to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 30),

            // Check verification button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: checking ? null : _checkVerification,
                child: checking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("I have verified"),
              ),
            ),
            const SizedBox(height: 12),

            // Resend email button with cooldown
            TextButton(
              onPressed: (sending || cooldown > 0) ? null : _resendEmail,
              child: sending
                  ? const CircularProgressIndicator()
                  : Text(
                      cooldown > 0
                          ? "Resend in $cooldown s"
                          : "Resend verification email",
                    ),
            ),

            const SizedBox(height: 20),

            // ⭐ CHANGE EMAIL BUTTON
            TextButton(
              onPressed: _changeEmail,
              child: const Text(
                "Change email",
                style: TextStyle(
                  color: Colors.red,
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
