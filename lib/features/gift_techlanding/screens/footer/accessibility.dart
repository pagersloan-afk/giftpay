import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Accessibility",
      description:
          "Tools and features designed to make our platforms accessible to everyone.",
    );
  }
}
