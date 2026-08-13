import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class GiftCardMarketplaceScreen extends StatelessWidget {
  const GiftCardMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "GiftCard Marketplace",
      description:
          "Buy, sell, and redeem global gift cards with secure instant delivery.",
    );
  }
}
