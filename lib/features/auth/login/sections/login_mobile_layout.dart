import 'package:flutter/material.dart';
import 'login_card.dart';

class LoginMobileLayout extends StatelessWidget {
  const LoginMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [SizedBox(height: 40), LoginCard(), SizedBox(height: 40)],
    );
  }
}
