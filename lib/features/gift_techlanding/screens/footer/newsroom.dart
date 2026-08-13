import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class NewsroomScreen extends StatelessWidget {
  const NewsroomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Newsroom",
      description: "Press releases, announcements, and media coverage.",
    );
  }
}
