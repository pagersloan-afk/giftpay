import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class UtilitiesHubScreen extends StatelessWidget {
  const UtilitiesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Utilities Hub",
      description:
          "Electricity, water, waste management, and essential utility payments.",
    );
  }
}
