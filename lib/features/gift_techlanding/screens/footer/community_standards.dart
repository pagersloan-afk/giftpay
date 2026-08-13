import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class CommunityStandardsScreen extends StatelessWidget {
  const CommunityStandardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Community Standards",
      description:
          "Rules and guidelines that ensure safe and respectful use of our platforms.",
    );
  }
}
