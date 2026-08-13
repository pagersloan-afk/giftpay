import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class FindStoreScreen extends StatelessWidget {
  const FindStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Find a Store",
      description:
          "Locate authorized Gift Technology stores, service centers, and partner outlets.",
    );
  }
}
