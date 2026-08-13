import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class GiftPOSScreen extends StatelessWidget {
  const GiftPOSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "GiftPOS",
      description:
          "A modern POS system for merchants, businesses, and enterprise operations.",
    );
  }
}
