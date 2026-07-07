import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:utilityhub/core/widgets/giftpay_background.dart';
import 'package:utilityhub/core/widgets/app_header.dart';

import 'sections/login_desktop_layout.dart';
import 'sections/login_mobile_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ⭐ APP USERS → show LoginCard only (no landing page)
    if (!kIsWeb) {
      return const GiftPayBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: LoginMobileLayout(),
        ),
      );
    }

    // ⭐ WEB USERS → show only login UI (NO LANDING SECTIONS)
    return GiftPayBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppHeader(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 900;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // ⭐ Desktop → LoginCard + Promo
                  if (isDesktop) const LoginDesktopLayout(),

                  // ⭐ Mobile Web → LoginCard only
                  if (!isDesktop) const LoginMobileLayout(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
