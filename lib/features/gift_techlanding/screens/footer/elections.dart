import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class ElectionsScreen extends StatelessWidget {
  const ElectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Elections",
      description:
          "Our approach to secure digital voting, civic engagement, and election integrity.",
    );
  }
}
