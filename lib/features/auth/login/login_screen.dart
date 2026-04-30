import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:utilityhub/core/widgets/giftpay_background.dart';
import 'package:utilityhub/core/widgets/app_header.dart';
import 'package:utilityhub/features/auth/login/sections/financial_business_showcase_row.dart';

import 'sections/hero_section.dart';
import 'sections/feature_cards_section.dart';
import 'sections/app_showcase_section.dart';
import 'sections/lifestyle_benefits_section.dart';
import 'sections/footer_section.dart';

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

    // ⭐ WEB USERS → full landing page
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
                  // ⭐ Desktop → Hero + LoginCard
                  if (isDesktop) const LoginDesktopLayout(),

                  // ⭐ Mobile Web → Hero only
                  if (!isDesktop) const HeroSection(),

                  const FeatureCardsSection(),
                  const FinancialBusinessShowcaseRow(),
                  const AppShowcaseSection(),
                  const LifestyleBenefitsSection(),
                  const FooterSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
