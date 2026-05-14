import 'package:flutter/material.dart';
import 'login_card.dart';

class LoginMobileLayout extends StatelessWidget {
  const LoginMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420, // ⭐ Wider login card
            ),
            child: const LoginCard(),
          ),
        ),
      ],
    );
  }
}
