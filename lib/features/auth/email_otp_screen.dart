import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';
import 'package:utilityhub/core/security/device_trust.dart';
import 'package:utilityhub/features/auth/login/login_success_screen.dart';

class EmailOtpScreen extends StatefulWidget {
  final String email;

  const EmailOtpScreen({super.key, required this.email});

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
  final otpCtrl = TextEditingController();

  bool sending = false;
  bool verifying = false;

  int resendCount = 0; // rate limiting: max 5 per hour
  DateTime? firstResendWindowStart;

  int cooldownSecondsLeft = 0; // 60s cooldown
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    sendOtp(); // initial OTP
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    otpCtrl.dispose();
    super.dispose();
  }

  String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<void> sendOtpEmail(String email, String otp) async {
    final url = Uri.parse(ApiConfig.api("/auth/send-otp"));

    await http.post(url, body: {"email": email, "otp": otp});
  }

  void _startCooldown() {
    cooldownSecondsLeft = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        cooldownSecondsLeft--;
        if (cooldownSecondsLeft <= 0) {
          timer.cancel();
        }
      });
    });
  }

  bool _canResend() {
    final now = DateTime.now();

    // Rate limit window: 1 hour
    if (firstResendWindowStart == null ||
        now.difference(firstResendWindowStart!).inHours >= 1) {
      firstResendWindowStart = now;
      resendCount = 0;
    }

    if (resendCount >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "You have reached the maximum OTP requests for this hour.",
          ),
        ),
      );
      return false;
    }

    if (cooldownSecondsLeft > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please wait $cooldownSecondsLeft seconds before requesting a new OTP.",
          ),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> sendOtp() async {
    if (!_canResend()) return;

    setState(() => sending = true);

    final user = FirebaseAuth.instance.currentUser!;
    final otp = generateOtp();

    final expiresAt = DateTime.now()
        .add(const Duration(minutes: 10))
        .millisecondsSinceEpoch;

    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "pendingOtp": otp,
      "pendingOtpExpiresAt": expiresAt,
    });

    await sendOtpEmail(widget.email, otp);

    resendCount++;
    _startCooldown();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("A new OTP has been sent to your email")),
    );

    setState(() => sending = false);
  }

  Future<void> verifyOtp() async {
    setState(() => verifying = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session error. Please login again.")),
      );
      setState(() => verifying = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final data = doc.data() ?? {};
    final savedOtp = data["pendingOtp"] as String?;
    final expiresAt = data["pendingOtpExpiresAt"] as int?;

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    if (expiresAt != null && nowMs > expiresAt) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP has expired. Please request a new one."),
        ),
      );
      setState(() => verifying = false);
      return;
    }

    if (savedOtp == otpCtrl.text.trim()) {
      await DeviceTrust.markDeviceTrusted(user.uid);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({
            "pendingOtp": FieldValue.delete(),
            "pendingOtpExpiresAt": FieldValue.delete(),
          });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginSuccessScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
    }

    setState(() => verifying = false);
  }

  @override
  Widget build(BuildContext context) {
    final canResend = cooldownSecondsLeft == 0 && !sending;

    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Enter the 6‑digit code sent to your email.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: otpCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "OTP"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: verifying ? null : verifyOtp,
              child: verifying
                  ? const CircularProgressIndicator()
                  : const Text("Verify"),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: canResend ? sendOtp : null,
              child: sending
                  ? const Text("Sending...")
                  : cooldownSecondsLeft > 0
                  ? Text("Resend in ${cooldownSecondsLeft}s")
                  : const Text("Resend OTP"),
            ),

            const SizedBox(height: 8),

            Text(
              "You can request up to 5 OTP codes per hour.",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
