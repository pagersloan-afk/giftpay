import 'package:flutter/material.dart';
import 'package:utilityhub/main.dart';

class GiftPaySplash extends StatefulWidget {
  const GiftPaySplash({super.key});

  @override
  State<GiftPaySplash> createState() => _GiftPaySplashState();
}

class _GiftPaySplashState extends State<GiftPaySplash> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const _AuthGateWrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: Center(
        child: Image.asset(
          "assets/logo/giftpay_1.png",
          height: 380,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Wrapper to re‑apply your global background AFTER splash
class _AuthGateWrapper extends StatelessWidget {
  const _AuthGateWrapper();

  @override
  Widget build(BuildContext context) {
    return const AuthGate();
  }
}
