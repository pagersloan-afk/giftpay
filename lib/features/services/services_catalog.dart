import 'package:flutter/material.dart';

class ServiceItem {
  final String title;
  final IconData icon;
  final String route;

  const ServiceItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}

class ServicesCatalog {
  static const all = <ServiceItem>[
    ServiceItem(title: "Transfer", icon: Icons.send, route: "/transfer"),
    ServiceItem(title: "Airtime", icon: Icons.phone_android, route: "/airtime"),
    ServiceItem(title: "Data", icon: Icons.wifi, route: "/data"),
    ServiceItem(
      title: "Electricity",
      icon: Icons.flash_on,
      route: "/electricity",
    ),
    ServiceItem(title: "Betting", icon: Icons.sports_soccer, route: "/betting"),
    ServiceItem(title: "Savings", icon: Icons.savings, route: "/savings"),
    ServiceItem(title: "Education", icon: Icons.school, route: "/education"),
    ServiceItem(
      title: "Gift Cards",
      icon: Icons.card_giftcard,
      route: "/giftcards",
    ),
    ServiceItem(title: "TV", icon: Icons.tv, route: "/cable"),
    ServiceItem(
      title: "Government",
      icon: Icons.account_balance,
      route: "/settings",
    ),
    ServiceItem(title: "Taxes", icon: Icons.receipt_long, route: "/settings"),
    ServiceItem(
      title: "Health",
      icon: Icons.health_and_safety,
      route: "/settings",
    ),
  ];
}
