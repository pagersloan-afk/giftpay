import 'package:flutter/material.dart';
import 'package:utilityhub/features/landing/public_screens/business_section/business_cta_section.dart';
import 'package:utilityhub/features/landing/public_screens/business_section/business_hero_section.dart';
import 'package:utilityhub/features/landing/public_screens/business_section/business_insight_section.dart';
import 'package:utilityhub/features/landing/public_screens/business_section/business_production_section.dart';
import 'package:utilityhub/features/landing/public_screens/business_section/business_resource_section.dart';

// ⭐ Shared Landing Header + Footer
import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';

// ⭐ Landing Responsive Layout
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

class BusinessPage extends StatelessWidget {
  const BusinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const LandingHeader(),
      body: LandingResponsiveLayout(
        child: Column(
          children: const [
            BusinessHeroSection(),
            SizedBox(height: 40),

            BusinessProductsSection(),
            SizedBox(height: 40),

            BusinessInsightsSection(),
            SizedBox(height: 40),

            BusinessResourcesSection(),
            SizedBox(height: 40),

            BusinessCTASection(),
            SizedBox(height: 40),

            LandingFooter(),
          ],
        ),
      ),
    );
  }
}
