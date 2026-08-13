import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class DevelopersScreen extends StatelessWidget {
  const DevelopersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Developers",
      description:
          "API documentation, SDKs, sandbox environments, and developer tools.",
    );
  }
}
