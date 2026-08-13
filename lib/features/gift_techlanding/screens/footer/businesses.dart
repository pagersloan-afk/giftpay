import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class BusinessesScreen extends StatelessWidget {
  const BusinessesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Businesses",
      description:
          "Enterprise solutions for payments, utilities, data, and digital operations.",
    );
  }
}
