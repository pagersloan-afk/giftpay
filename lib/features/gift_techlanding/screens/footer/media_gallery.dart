import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class MediaGalleryScreen extends StatelessWidget {
  const MediaGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Media Gallery",
      description:
          "Brand assets, product images, press photos, and media resources.",
    );
  }
}
