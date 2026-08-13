import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class BrandResourcesScreen extends StatelessWidget {
  const BrandResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Brand Resources",
      description:
          "Logos, typography, colors, and brand guidelines for partners and media.",
    );
  }
}
