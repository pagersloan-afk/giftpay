// lib/features/home/widgets/home_services_grid.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_service_card.dart';

class HomeServicesGrid extends StatelessWidget {
  const HomeServicesGrid({super.key});

  // ⭐ Get logged‑in user ID
  String get userId => FirebaseAuth.instance.currentUser!.uid;

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
      {"title": "More", "icon": Icons.apps, "route": "/services"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.48,
      ),
      itemBuilder: (context, i) {
        final s = services[i];
        return HomeServiceCard(
          title: s["title"] as String,
          icon: s["icon"] as IconData,
          route: s["route"] as String,
          userId: userId, // ⭐ REQUIRED FIX
        );
      },
    );
  }
}
