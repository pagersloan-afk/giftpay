import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Legal",
      description:
          "Review legal documents, compliance information, and regulatory disclosures.",
    );
  }
}
