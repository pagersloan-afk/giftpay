import 'package:flutter/material.dart';

import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

import 'section/contact_hero_section.dart';
import 'section/contact_form_section.dart';
import 'section/contact_location_section.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FD),
      appBar: const LandingHeader(),
      body: LandingResponsiveLayout(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              ContactHeroSection(),

              SizedBox(height: 28),

              ContactFormSection(),

              SizedBox(height: 28),

              ContactLocationSection(),

              SizedBox(height: 50),

              LandingFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
