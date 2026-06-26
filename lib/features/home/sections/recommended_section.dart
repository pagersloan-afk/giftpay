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

  // ⭐ Get logged‑in user ID
  String get userId => FirebaseAuth.instance.currentUser!.uid;

  // ⭐ Fallback recommended services WITH COLORS
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

    // TODO: Replace with Firestore user‑recommended logic
    items = fallback;

    // ⭐ Start auto‑scroll
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
                    userId: userId, // ⭐ REQUIRED FIX
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
