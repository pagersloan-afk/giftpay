import 'package:flutter/material.dart';

// Shared Landing Header + Footer
import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';

// Shared Responsive Layout
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

// Corporate Data Sections
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/corporate_data/corporate_data_hero_section.dart';
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/corporate_data/corporate_data_features_section.dart';
import 'package:utilityhub/features/landing/public_screens/products/screens/sections/corporate_data/corporate_data_cta_section.dart';

class CorporateDataPage extends StatelessWidget {
  const CorporateDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF9FAFC),
      appBar: LandingHeader(),
      body: LandingResponsiveLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CorporateDataHeroSection(),
            SizedBox(height: 48),
            CorporateDataFeaturesSection(),
            SizedBox(height: 48),
            CorporateDataCTASection(),
            SizedBox(height: 48),
            LandingFooter(),
          ],
        ),
      ),
    );
  }
}
