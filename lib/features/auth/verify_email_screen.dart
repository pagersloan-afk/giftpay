import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_picker/country_picker.dart';
import 'package:utilityhub/core/security/device_trust.dart';
import 'package:utilityhub/features/auth/login/signup/screens/signup_identity_screen.dart';
import 'package:utilityhub/features/wallet/services/giftpay_wallet_initializer.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final Country country;
  final String password;

  const VerifyEmailScreen({
    super.key,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.country,
    required this.password,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool checking = false;
  bool sending = false;

  int cooldown = 60;
  Timer? cooldownTimer;
  Timer? pollTimer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
    _startPolling();
  }

  @override
  void dispose() {
    cooldownTimer?.cancel();
    pollTimer?.cancel();
    super.dispose();
  }

  // ⭐ Countdown timer for resend
  void _startCooldown() {
    cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (cooldown == 0) {
        t.cancel();
      } else {
        setState(() => cooldown--);
      }
    });
  }

  // ⭐ Poll Firebase every 3 seconds
  void _startPolling() {
    pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        pollTimer?.cancel();
        await GiftPayWalletInitializer.createPrimaryWalletIfMissing();
        _goToIdentityScreen();
      }
    });
  }

  // ⭐ Manual check button
  Future<void> _checkVerification() async {
    setState(() => checking = true);

    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      await GiftPayWalletInitializer.createPrimaryWalletIfMissing();
      _goToIdentityScreen();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Email not verified yet")));
    }

    setState(() => checking = false);
  }

  // ⭐ Resend email button
  Future<void> _resendEmail() async {
    if (cooldown > 0) return;

    setState(() => sending = true);

    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification email sent again")),
      );

      cooldown = 60;
      _startCooldown();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => sending = false);
  }

  // ⭐ Change email
  Future<void> _changeEmail() async {
    await DeviceTrust.clearDeviceTrust();
    await FirebaseAuth.instance.signOut();

    Navigator.pushNamedAndRemoveUntil(context, "/signup", (route) => false);
  }

  // ⭐ Route to NIN/BVN screen with full parameters
  void _goToIdentityScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SignupIdentityScreen(
          userId: widget.userId,
          firstName: widget.firstName,
          lastName: widget.lastName,
          email: widget.email,
          phone: widget.phone,
          country: widget.country,
          password: widget.password,
          ninCtrl: TextEditingController(),
          bvnCtrl: TextEditingController(),
        ),
      ),
    );
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

            // ⭐ I have verified button
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

            // ⭐ Resend email button with cooldown
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

            // ⭐ Change email button
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
