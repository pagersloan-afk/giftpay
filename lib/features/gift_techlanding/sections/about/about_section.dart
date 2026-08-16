import 'package:flutter/material.dart';
import 'package:utilityhub/features/gift_techlanding/sections/about/about_header.dart';
import 'package:utilityhub/features/gift_techlanding/sections/about/about_main_card.dart';
import 'package:utilityhub/features/gift_techlanding/sections/about/about_principles.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool isMobile = width < 700;
    final bool isTablet = width >= 700 && width < 1100;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? 20
            : isTablet
            ? 34
            : 64,
        vertical: isMobile ? 80 : 120,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AboutHeader(),

              SizedBox(height: isMobile ? 42 : 64),

              const AboutMainCard(),

              SizedBox(height: isMobile ? 16 : 24),

              const AboutPrinciples(),
            ],
          ),
        ),
      ),
    );
  }
}
