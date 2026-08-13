import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Privacy Policy",
      description:
          "How we collect, use, store, and protect your personal information.",
    );
  }
}
