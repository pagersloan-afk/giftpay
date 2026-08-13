import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class CompanyInfoScreen extends StatelessWidget {
  const CompanyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Company Info",
      description:
          "Corporate information, registration details, and operational structure.",
    );
  }
}
