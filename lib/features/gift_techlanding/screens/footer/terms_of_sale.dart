import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class TermsOfSaleScreen extends StatelessWidget {
  const TermsOfSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Terms of Sale",
      description:
          "Understand the terms governing purchases, subscriptions, and transactions.",
    );
  }
}
