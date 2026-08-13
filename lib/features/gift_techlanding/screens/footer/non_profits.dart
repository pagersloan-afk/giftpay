import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class NonProfitsScreen extends StatelessWidget {
  const NonProfitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Non‑profits",
      description:
          "Digital tools and support programs for NGOs and social impact organizations.",
    );
  }
}
