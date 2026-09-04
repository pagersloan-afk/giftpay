import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;

import 'package:utilityhub/config/api.dart';

class LoginSuccessScreen extends StatefulWidget {
  const LoginSuccessScreen({super.key});

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confetti;
  late AnimationController _fadeController;

  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    player.play(AssetSource("sounds/login_success.mp3"));

    _confetti = ConfettiController(duration: const Duration(seconds: 1));

    _confetti.play();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    // Security notification must never block login/navigation.
    unawaited(_sendLoginSecurityAlert());

    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;

      await _fadeController.reverse();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil("/home", (_) => false);
    });
  }

  Future<String?> _getDeviceTimezone() async {
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();

      final identifier = timezoneInfo.identifier.trim();

      if (identifier.isEmpty) {
        return null;
      }

      debugPrint("🌍 Device timezone detected: $identifier");

      return identifier;
    } catch (e) {
      debugPrint("⚠️ Unable to detect device timezone: $e");

      return null;
    }
  }

  Future<void> _sendLoginSecurityAlert() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint(
          "⚠️ Login security alert skipped: "
          "no authenticated user",
        );
        return;
      }

      final idToken = await user.getIdToken();

      if (idToken == null || idToken.isEmpty) {
        debugPrint(
          "⚠️ Login security alert skipped: "
          "Firebase ID token unavailable",
        );
        return;
      }

      final deviceTimezone = await _getDeviceTimezone();

      final url = Uri.parse(ApiConfig.apiRoute("/security/login-alert"));

      final payload = <String, dynamic>{"timeZone": deviceTimezone};

      final response = await http
          .post(
            url,
            headers: {
              "Authorization": "Bearer $idToken",
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint("🔐 Login security alert sent successfully");
      } else {
        debugPrint(
          "⚠️ Login security alert returned "
          "${response.statusCode}: ${response.body}",
        );
      }
    } on TimeoutException {
      debugPrint("⚠️ Login security alert timed out");
    } catch (e) {
      debugPrint("⚠️ Login security alert failed: $e");
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    _fadeController.dispose();
    player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.65),
      body: Stack(
        children: [
          Positioned.fill(
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              maxBlastForce: 18,
              minBlastForce: 5,
              gravity: 0.3,
            ),
          ),

          Center(
            child: FadeTransition(
              opacity: _fadeController,
              child: Container(
                width: 340,
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.25),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 70,
                      color: Colors.greenAccent.shade400,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Login Successful",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Welcome back to GiftPay!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
