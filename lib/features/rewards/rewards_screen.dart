import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rewards = <Map<String, dynamic>>[
      {
        "title": "Cashback on Airtime",
        "description": "Earn 2% cashback on every airtime purchase.",
        "badge": "Active",
        "color": const Color(0xFF0AC8FF),
      },
      {
        "title": "Referral Bonus",
        "description": "Earn ₦500 when a friend completes KYC.",
        "badge": "Ongoing",
        "color": const Color(0xFFFF8F00),
      },
      {
        "title": "Utility Streak",
        "description": "Pay 5 electricity bills to unlock a bonus.",
        "badge": "Challenge",
        "color": const Color(0xFF4FC3F7),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF05070A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Rewards",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),

      body: rewards.isEmpty
          ? const _RewardsEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: rewards.length,
              itemBuilder: (context, index) {
                final r = rewards[index];
                return _AnimatedRewardCard(
                  delay: index * 120,
                  title: r["title"],
                  description: r["description"],
                  badge: r["badge"],
                  badgeColor: r["color"],
                );
              },
            ),
    );
  }
}

class _RewardsEmptyState extends StatelessWidget {
  const _RewardsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.card_giftcard, size: 80, color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              "No rewards yet",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Use GiftPay for bills, airtime, and transfers to unlock rewards.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedRewardCard extends StatefulWidget {
  final String title;
  final String description;
  final String badge;
  final Color badgeColor;
  final int delay;

  const _AnimatedRewardCard({
    required this.title,
    required this.description,
    required this.badge,
    required this.badgeColor,
    required this.delay,
  });

  @override
  State<_AnimatedRewardCard> createState() => _AnimatedRewardCardState();
}

class _AnimatedRewardCardState extends State<_AnimatedRewardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.badgeColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      widget.badge,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: widget.badgeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                widget.description,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
