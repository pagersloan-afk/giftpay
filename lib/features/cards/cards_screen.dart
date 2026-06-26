import 'package:flutter/material.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = <Map<String, dynamic>>[
      {
        "label": "Primary Virtual Card",
        "masked": "**** **** **** 4821",
        "balance": "₦120,500.00",
        "network": "Visa",
        "color": const Color(0xFF0A4D9C),
      },
      {
        "label": "Utility Card",
        "masked": "**** **** **** 9034",
        "balance": "₦18,200.00",
        "network": "Mastercard",
        "color": const Color(0xFFFF8F00),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF05070A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Cards",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),

      body: cards.isEmpty
          ? const _CardsEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final c = cards[index];
                return _AnimatedCardTile(
                  delay: index * 140,
                  label: c["label"],
                  masked: c["masked"],
                  balance: c["balance"],
                  network: c["network"],
                  color: c["color"],
                );
              },
            ),
    );
  }
}

class _CardsEmptyState extends StatelessWidget {
  const _CardsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.credit_card, size: 80, color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              "No cards yet",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Create a virtual card or request a physical card to get started.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCardTile extends StatefulWidget {
  final String label;
  final String masked;
  final String balance;
  final String network;
  final Color color;
  final int delay;

  const _AnimatedCardTile({
    required this.label,
    required this.masked,
    required this.balance,
    required this.network,
    required this.color,
    required this.delay,
  });

  @override
  State<_AnimatedCardTile> createState() => _AnimatedCardTileState();
}

class _AnimatedCardTileState extends State<_AnimatedCardTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
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
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                widget.color.withOpacity(0.85),
                widget.color.withOpacity(0.45),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    widget.network,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.masked,
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Available balance",
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  Text(
                    widget.balance,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
