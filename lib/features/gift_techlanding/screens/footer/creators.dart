import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class CreatorsScreen extends StatelessWidget {
  const CreatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Creators",
      description:
          "Tools, monetization programs, and resources for creators across Africa.",
    );
  }
}
