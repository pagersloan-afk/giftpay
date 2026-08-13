import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class ReturnsScreen extends StatelessWidget {
  const ReturnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Returns",
      description:
          "Learn about our return policies, eligibility, timelines, and refund processing.",
    );
  }
}
