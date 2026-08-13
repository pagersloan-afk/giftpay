import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class DownloadSDKsScreen extends StatelessWidget {
  const DownloadSDKsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Download SDKs",
      description:
          "Access SDKs for GiftPay, GiftPOS, utilities, authentication, and more.",
    );
  }
}
