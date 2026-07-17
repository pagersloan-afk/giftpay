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

// ⭐ NEW PARENT CARD
import 'widgets/parent_overlay_card.dart';

// ⭐ NEW LANDING RESPONSIVE LAYOUT
import 'widgets/landing_responsive_layout.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      appBar: const LandingHeader(),

      body: LandingResponsiveLayout(
        child: Column(
          children: const [
            HeroSection(),

            ParentOverlayCard(child: FeatureCardsSection()),
            ParentOverlayCard(child: FinancialBusinessShowcaseRow()),
            ParentOverlayCard(child: AppShowcaseSection()),
            ParentOverlayCard(child: LifestyleBenefitsSection()),
            ParentOverlayCard(child: PricingSection()),
            ParentOverlayCard(child: ProductShowcaseSection()),

            // ⭐ Footer now OUTSIDE the parent card
            LandingFooter(),
          ],
        ),
      ),
    );
  }
}
