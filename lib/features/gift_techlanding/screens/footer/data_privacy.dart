import 'package:flutter/material.dart';
import 'package:utilityhub/features/gift_techlanding/screens/gifttech_page_template.dart';

class DataPrivacyScreen extends StatelessWidget {
  const DataPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Data & Privacy",
      description:
          "How we protect user data, enforce privacy standards, and maintain secure systems.",
    );
  }
}
