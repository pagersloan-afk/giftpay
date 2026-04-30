import 'package:flutter/material.dart';
import 'promo_section.dart';
import 'login_card.dart';

class LoginDesktopLayout extends StatelessWidget {
  const LoginDesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: PromoSection()),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: const LoginCard(),
          ),
        ),
      ],
    );
  }
}
