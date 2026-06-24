// lib/features/services/services_screen.dart
import 'package:flutter/material.dart';
import 'package:utilityhub/features/home/widgets/home_service_card.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

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

        // ⭐ LOGOUT (RED)
        {
          "title": "Logout",
          "icon": Icons.logout,
          "route": "/login",
          "iconColor": Colors.redAccent, // ⭐ FIXED
        },
      ],
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Services"),
        backgroundColor: Colors.black87,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final sectionName = grouped.keys.elementAt(index);
          final items = grouped[sectionName]!;

          return _AnimatedSection(
            delay: index * 120,
            child: Column(
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
                      iconColor: s["iconColor"], // ⭐ FIXED
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
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedSection extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedSection({required this.child, required this.delay});

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
