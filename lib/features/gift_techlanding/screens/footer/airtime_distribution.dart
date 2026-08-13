import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class AirtimeDistributionScreen extends StatelessWidget {
  const AirtimeDistributionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Airtime Distribution",
      description:
          "Automated airtime distribution for agents, resellers, and businesses.",
    );
  }
}
