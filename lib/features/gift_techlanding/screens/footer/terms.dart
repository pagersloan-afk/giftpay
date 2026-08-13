import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Terms",
      description:
          "Terms and conditions governing the use of Gift Technology platforms.",
    );
  }
}
