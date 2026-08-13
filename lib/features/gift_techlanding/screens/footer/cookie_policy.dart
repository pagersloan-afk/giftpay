import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class CookiePolicyScreen extends StatelessWidget {
  const CookiePolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Cookie Policy",
      description:
          "How we use cookies to improve user experience and platform performance.",
    );
  }
}
