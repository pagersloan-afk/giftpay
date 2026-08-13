import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Help Center",
      description:
          "Find answers, guides, troubleshooting steps, and support resources for all Gift Technology products.",
    );
  }
}
