import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class CorporateDataScreen extends StatelessWidget {
  const CorporateDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Corporate Data Plans",
      description:
          "Affordable and scalable data plans for businesses and enterprise teams.",
    );
  }
}
