import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class InvestorsScreen extends StatelessWidget {
  const InvestorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Investors",
      description:
          "Financial reports, investor updates, and corporate governance information.",
    );
  }
}
