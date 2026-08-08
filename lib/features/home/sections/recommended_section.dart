// lib/features/home/sections/recommended_section.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/home_service_card.dart';

class RecommendedSection extends StatefulWidget {
  const RecommendedSection({super.key});

  @override
  State<RecommendedSection> createState() => _RecommendedSectionState();
}

class _RecommendedSectionState extends State<RecommendedSection>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  Timer? _autoScrollTimer;

  late AnimationController _controller;
  late Animation<Offset> _slide;

  // ⭐ Logged‑in user ID
  String get userId => FirebaseAuth.instance.currentUser!.uid;

  // ⭐ Expanded fallback list (12 items)
  final List<Map<String, dynamic>> fallback = const [
    {
      "title": "Electricity",
      "icon": Icons.flash_on,
      "route": "/electricity",
      "color": Color(0xFFFFD54F),
    },
    {
      "title": "Airtime",
      "icon": Icons.phone_android,
      "route": "/airtime",
      "color": Color(0xFF4FC3F7),
    },
    {
      "title": "Cable TV",
      "icon": Icons.tv,
      "route": "/cable",
      "color": Color(0xFFBA68C8),
    },
    {
      "title": "Data",
      "icon": Icons.wifi,
      "route": "/data",
      "color": Color(0xFF81C784),
    },

    {
      "title": "Flights",
      "icon": Icons.flight_takeoff,
      "route": "/aviation",
      "color": Color(0xFF40C4FF),
    },

    {
      "title": "Gift Cards",
      "icon": Icons.card_giftcard,
      "route": "/giftcards",
      "color": Color(0xFFFF8A65),
    },
    {
      "title": "Education",
      "icon": Icons.school,
      "route": "/education",
      "color": Color(0xFF4DD0E1),
    },
    {
      "title": "Betting",
      "icon": Icons.sports_soccer,
      "route": "/betting",
      "color": Color(0xFFA1887F),
    },
    {
      "title": "Gaming",
      "icon": Icons.sports_esports,
      "route": "/psgames",
      "color": Color(0xFF9575CD),
    },
    {
      "title": "Health",
      "icon": Icons.health_and_safety,
      "route": "/settings",
      "color": Color(0xFFE57373),
    },
    {
      "title": "Government",
      "icon": Icons.account_balance,
      "route": "/settings",
      "color": Color(0xFF64B5F6),
    },
    {
      "title": "Taxes",
      "icon": Icons.receipt_long,
      "route": "/settings",
      "color": Color(0xFF90A4AE),
    },
    {
      "title": "Utilities",
      "icon": Icons.lightbulb,
      "route": "/electricity",
      "color": Color(0xFFFFF176),
    },
  ];

  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    // ⭐ Slide‑in animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // TODO: Replace with Firestore recommended logic
    items = fallback;

    // ⭐ Auto‑scroll
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;

      if (current >= maxScroll) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.animateTo(
          current + 110,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recommended for You",
          style: TextStyle(
            fontSize: 11.50,
            fontWeight: FontWeight.w500,
            color: Color(0xFFE5E7EB),
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 90,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            padding: const EdgeInsets.only(left: 4, right: 4),

            itemBuilder: (context, i) {
              final s = items[i];

              return SlideTransition(
                position: _slide,
                child: SizedBox(
                  width: 90,
                  child: HomeServiceCard(
                    title: s["title"],
                    icon: s["icon"],
                    route: s["route"],
                    iconColor: s["color"],
                    userId: userId,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
