import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class SafetyCenterScreen extends StatelessWidget {
  const SafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Safety Center",
      description:
          "Learn how we protect users, enforce safety standards, and maintain secure digital environments.",
    );
  }
}
