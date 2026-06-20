// lib/features/services/services_screen.dart
import 'package:flutter/material.dart';
import '../home/widgets/home_service_card.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {"title": "Transfer", "icon": Icons.send, "route": "/transfer"},
      {"title": "Airtime", "icon": Icons.phone_android, "route": "/airtime"},
      {"title": "Data", "icon": Icons.wifi, "route": "/data"},
      {"title": "Electricity", "icon": Icons.flash_on, "route": "/electricity"},
      {"title": "Betting", "icon": Icons.sports_soccer, "route": "/betting"},
      {"title": "Savings", "icon": Icons.savings, "route": "/savings"},
      {"title": "Education", "icon": Icons.school, "route": "/education"},
      {"title": "Statement", "icon": Icons.receipt_long, "route": "/statement"},
      {
        "title": "Gift Cards",
        "icon": Icons.card_giftcard,
        "route": "/giftcards",
      },
      {"title": "Rewards", "icon": Icons.star, "route": "/rewards"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Services"),
        backgroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: services.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // ⭐ 4 per row
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, i) {
            final s = services[i];
            return HomeServiceCard(
              title: s["title"] as String,
              icon: s["icon"] as IconData,
              route: s["route"] as String,
            );
          },
        ),
      ),
    );
  }
}
