import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class AboutGiftTechScreen extends StatelessWidget {
  const AboutGiftTechScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "About Gift Technology Ltd",
      description:
          "Learn about our mission, leadership, history, and vision for Africa’s digital future.",
    );
  }
}
