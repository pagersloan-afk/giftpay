import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_picker/country_picker.dart';
import 'package:utilityhub/core/security/device_trust.dart';
import 'package:utilityhub/features/auth/login/signup/screens/signup_identity_screen.dart';
import 'package:utilityhub/features/auth/login/signup/screens/signup_bank_account_screen.dart';
import 'package:utilityhub/features/wallet/services/virtual_account_service.dart';
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
  bool _hasNavigated = false;

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
        await _routeAfterEmailVerification();
      }
    });
  }

  // ⭐ Manual check button
  Future<void> _checkVerification() async {
    if (checking) return;
    setState(() => checking = true);

    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      await GiftPayWalletInitializer.createPrimaryWalletIfMissing();
      await _routeAfterEmailVerification();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Email not verified yet")));
    }

    if (mounted) setState(() => checking = false);
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

  // Select the onboarding verification step from the backend's active
  // provider. The backend .env remains the single source of truth.
  Future<void> _routeAfterEmailVerification() async {
    if (_hasNavigated || !mounted) return;
    try {
      final config = await VirtualAccountService().getConfig();
      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;

      if ((config['provider'] ?? '').toString().toLowerCase() == 'paystack') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: '/signup-bank-account'),
            builder: (_) => const SignupBankAccountScreen(),
          ),
        );
        return;
      }

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
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your email is verified, but we could not load the signup verification settings. Please try again. ${error.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
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
