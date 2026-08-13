import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class OrderStatusScreen extends StatelessWidget {
  const OrderStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GiftTechPageTemplate(
      title: "Order Status",
      description:
          "Track your Gift Technology orders, subscriptions, and service requests.",
    );
  }
}
