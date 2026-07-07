import 'package:flutter/material.dart';
import 'package:utilityhub/features/auth/login/sections/login_card.dart';
import 'package:utilityhub/features/auth/login/sections/promo_section.dart';

class LoginDesktopLayout extends StatelessWidget {
  const LoginDesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: PromoSection()),
            const SizedBox(width: 40),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: const LoginCard(),
            ),
          ],
        ),
      ),
    );
  }
}
