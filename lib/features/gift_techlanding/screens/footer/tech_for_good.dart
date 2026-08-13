import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class TechForGoodScreen extends StatelessWidget {
  const TechForGoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Tech for Good",
      description:
          "Initiatives that use technology to improve lives, communities, and opportunities.",
    );
  }
}
