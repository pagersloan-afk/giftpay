import 'dart:async';
import 'package:flutter/material.dart';

class FeatureCardsSection extends StatefulWidget {
  const FeatureCardsSection({super.key});

  @override
  State<FeatureCardsSection> createState() => _FeatureCardsSectionState();
}

class _FeatureCardsSectionState extends State<FeatureCardsSection> {
  final ScrollController _scrollController = ScrollController();

  // ⭐ All services from your ServicesScreen (public‑facing only)
  final List<Map<String, dynamic>> services = [
    {
      "title": "Electricity",
      "subtitle": "Instant prepaid token delivery.",
      "icon": Icons.flash_on,
      "route": "/electricity",
    },
    {
      "title": "Airtime",
      "subtitle": "Top up all networks instantly.",
      "icon": Icons.phone_android,
      "route": "/airtime",
    },
    {
      "title": "Data",
      "subtitle": "Affordable data bundles.",
      "icon": Icons.wifi,
      "route": "/data",
    },
    {
      "title": "Gift Cards",
      "subtitle": "Global cards with instant delivery.",
      "icon": Icons.card_giftcard,
      "route": "/giftcards",
    },
    {
      "title": "Cable TV",
      "subtitle": "Renew GOtv, DStv, Startimes.",
      "icon": Icons.tv,
      "route": "/cable",
    },
    {
      "title": "Betting",
      "subtitle": "Fund all betting platforms.",
      "icon": Icons.sports_soccer,
      "route": "/betting",
    },
    {
      "title": "Gaming",
      "subtitle": "PS5 & digital game top‑ups.",
      "icon": Icons.sports_esports,
      "route": "/psgames",
    },
    {
      "title": "Utilities",
      "subtitle": "Light, water, internet bills.",
      "icon": Icons.lightbulb,
      "route": "/electricity",
    },
    {
      "title": "Health",
      "subtitle": "Health insurance & services.",
      "icon": Icons.health_and_safety,
      "route": "/settings",
    },
    {
      "title": "Savings",
      "subtitle": "Grow your money securely.",
      "icon": Icons.savings,
      "route": "/savings",
    },
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // ⭐ Auto‑scroll every 30ms (slower + smoother)
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!_scrollController.hasClients) return;

      final max = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;

      if (current >= max) {
        _scrollController.jumpTo(0); // loop
      } else {
        _scrollController.jumpTo(current + 0.7); // slower movement
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 20 : 32,
        ),
        color: const Color(0xFFF9F9F9),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⭐ Section Title
            Padding(
              padding: EdgeInsets.only(bottom: isMobile ? 16 : 24),
              child: Text(
                "GiftPay Services at a Glance",
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 20 : 26,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ),

            // ⭐ Parent overlay card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: SizedBox(
                height: isMobile ? 130 : 150,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final s = services[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _serviceCard(
                        icon: s["icon"],
                        title: s["title"],
                        subtitle: s["subtitle"],
                        route: s["route"],
                        isMobile: isMobile,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ Individual service card (reduced height + tighter spacing)
  Widget _serviceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required bool isMobile,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        width: isMobile ? 150 : 180, // ⭐ smaller width
        padding: const EdgeInsets.all(14), // ⭐ reduced padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // ⭐ smaller radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 30,
              color: const Color.fromARGB(255, 39, 61, 104),
            ), // ⭐ smaller icon
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 14 : 15, // ⭐ reduced font
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 11 : 12, // ⭐ reduced font
                color: Colors.black54,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
