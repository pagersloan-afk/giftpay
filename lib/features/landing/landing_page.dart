import 'package:flutter/material.dart';

// ⭐ LANDING HEADER + FOOTER
import 'widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';

// ⭐ LANDING SECTIONS
import 'sections/hero_section.dart';
import 'sections/feature_cards_section.dart';
import 'sections/financial_business_showcase_row.dart';
import 'sections/app_showcase_section.dart';
import 'sections/lifestyle_benefits_section.dart';
import 'sections/pricing_section.dart';
import 'sections/product_showcase_section.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      // ⭐ NEW LUXURY HEADER
      appBar: const LandingHeader(),

      body: SingleChildScrollView(
        child: Column(
          children: const [
            HeroSection(),
            FeatureCardsSection(),
            FinancialBusinessShowcaseRow(),
            AppShowcaseSection(),
            LifestyleBenefitsSection(),
            PricingSection(),
            ProductShowcaseSection(),
            LandingFooter(),
          ],
        ),
      ),
    );
  }
}
