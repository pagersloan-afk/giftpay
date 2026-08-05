import 'dart:async';
import 'package:flutter/material.dart';

// 🔵 Luxury Feature Cards Section (No Fade Animations)
class FeatureCardsSection extends StatefulWidget {
  const FeatureCardsSection({super.key});

  @override
  State<FeatureCardsSection> createState() => _FeatureCardsSectionState();
}

class _FeatureCardsSectionState extends State<FeatureCardsSection> {
  final ScrollController _scrollController = ScrollController();

  double parallaxShift = 0.0;
  Timer? _timer;

  // ⭐ Representative colors for each icon
  final Map<String, Color> iconColors = {
    "Electricity": Colors.amber,
    "Airtime": Colors.blueAccent,
    "Data": Colors.green,
    "Gift Cards": Colors.purple,
    "Cable TV": Colors.redAccent,
    "Betting": Colors.orange,
    "Gaming": Colors.deepPurple,
    "Utilities": Colors.teal,
    "Health": Colors.red,
    "Savings": Colors.indigo,
    "Aviation": Colors.blueAccent,
    "Ride Booking": const Color.fromARGB(255, 248, 199, 75),
  };

  // ⭐ All services
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
      "title": "Aviation",
      "subtitle": "Book flights instantly — local & international.",
      "icon": Icons.flight_takeoff,
      "route": "/aviation",
    },
    {
      "title": "Ride Booking",
      "subtitle": "Book Bolt & Uber rides instantly from GiftPay.",
      "icon": Icons.local_taxi,
      "route": "/rides",
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

  @override
  void initState() {
    super.initState();

    // ⭐ Parallax listener
    _scrollController.addListener(() {
      if (!mounted) return;
      setState(() {
        parallaxShift = (_scrollController.offset / 300).clamp(0, 1);
      });
    });

    // ⭐ Start auto-scroll ONLY after first layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(milliseconds: 22), (_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;

      try {
        // ⭐ This was the crashing line before:
        // final max = _scrollController.position.maxScrollExtent;
        final position = _scrollController.position;
        final max = position.maxScrollExtent;
        final current = _scrollController.offset;

        if (current >= max) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(current + 1.1);
        }
      } catch (_) {
        // ⭐ Safety: if dimensions are not ready yet, just skip this tick
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

        // ⭐ Stronger luxury gradient (no fade animation)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1 + parallaxShift, -1),
            end: Alignment(1, 1 - parallaxShift),
            colors: [
              Colors.white.withOpacity(0.90),
              const Color(0xFF273D68).withOpacity(0.85),
              const Color(0xFF4A6BB8).withOpacity(0.75),
              const Color(0xFFE8E8E8).withOpacity(0.70),
            ],
          ),
        ),

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

            // ⭐ Parent overlay card (stronger elevation)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: SizedBox(
                height: isMobile ? 140 : 160,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final s = services[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 18),
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

  // ⭐ Individual service card (stronger standout)
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
        width: isMobile ? 150 : 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 34, color: iconColors[title] ?? Colors.black87),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 15 : 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 12 : 13,
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
