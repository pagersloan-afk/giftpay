import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:utilityhub/features/home/widgets/home_service_card.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  // ⭐ Get logged‑in user ID
  String get userId => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, dynamic>>> grouped = {
      "Send & Receive": [
        {"title": "Transfer", "icon": Icons.send, "route": "/transfer"},
        {"title": "Card", "icon": Icons.credit_card, "route": "/wallet"},
        {"title": "Network", "icon": Icons.network_check, "route": "/settings"},
        {"title": "Recurring", "icon": Icons.repeat, "route": "/settings"},
        {"title": "USSD", "icon": Icons.dialpad, "route": "/settings"},
      ],

      "Bills & Recharges": [
        {"title": "Airtime", "icon": Icons.phone_android, "route": "/airtime"},
        {"title": "Data", "icon": Icons.wifi, "route": "/data"},
        {"title": "Education", "icon": Icons.school, "route": "/education"},
        {
          "title": "Electricity",
          "icon": Icons.flash_on,
          "route": "/electricity",
        },
        {
          "title": "Government",
          "icon": Icons.account_balance,
          "route": "/settings",
        },
        {"title": "TV", "icon": Icons.tv, "route": "/cable"},
        {"title": "Association", "icon": Icons.groups, "route": "/settings"},
        {"title": "Religion", "icon": Icons.church, "route": "/settings"},
        {"title": "Taxes", "icon": Icons.receipt_long, "route": "/settings"},
      ],

      "Lifestyle": [
        {"title": "Betting", "icon": Icons.sports_soccer, "route": "/betting"},
        {"title": "Gaming", "icon": Icons.sports_esports, "route": "/psgames"},
        {
          "title": "Gift Cards",
          "icon": Icons.card_giftcard,
          "route": "/giftcards",
        },
        {
          "title": "Utilities",
          "icon": Icons.lightbulb,
          "route": "/electricity",
        },
        {
          "title": "Health",
          "icon": Icons.health_and_safety,
          "route": "/settings",
        },
      ],

      "Finance": [
        {"title": "Savings", "icon": Icons.savings, "route": "/savings"},
      ],

      "Accounts & Settings": [
        {
          "title": "Statement",
          "icon": Icons.receipt_long,
          "route": "/statement",
        },
        {"title": "Limits", "icon": Icons.lock, "route": "/settings"},
        {"title": "Settings", "icon": Icons.settings, "route": "/settings"},

        {
          "title": "Logout",
          "icon": Icons.logout,
          "route": "/login",
          "iconColor": Colors.redAccent,
        },
      ],
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "All Services",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final sectionName = grouped.keys.elementAt(index);
          final items = grouped[sectionName]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 10),
                child: Text(
                  sectionName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
              ),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.92,
                ),
                itemBuilder: (context, i) {
                  final s = items[i];
                  return HomeServiceCard(
                    title: s["title"],
                    icon: s["icon"],
                    route: s["route"],
                    iconColor: s["iconColor"],
                    userId: userId, // ⭐ REQUIRED
                  );
                },
              ),

              const SizedBox(height: 18),

              if (index != grouped.length - 1)
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(top: 6, bottom: 6),
                  color: Colors.white.withOpacity(0.08),
                ),
            ],
          );
        },
      ),
    );
  }
}
