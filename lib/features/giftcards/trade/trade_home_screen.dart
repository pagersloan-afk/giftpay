import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'select_card_type_screen.dart';

class TradeGiftCardHomeScreen extends StatelessWidget {
  const TradeGiftCardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"name": "Apple", "asset": "assets/giftcards/apple.png"},
      {"name": "Steam", "asset": "assets/giftcards/steam.png"},
      {"name": "Amazon", "asset": "assets/giftcards/amazon.png"},
      {"name": "Google Play", "asset": "assets/giftcards/googleplay.png"},
      {"name": "PlayStation", "asset": "assets/giftcards/playstation.png"},
      {"name": "Xbox", "asset": "assets/giftcards/xbox.png"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trade Gift Cards"),
        backgroundColor: Colors.black,
      ),
      body: AppResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GridView.builder(
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, i) {
              final item = categories[i];

              return TradeCard(
                name: item["name"]!,
                asset: item["asset"]!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SelectCardTypeScreen(category: item["name"]!),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// PREMIUM TRADE CARD WIDGET
/// ---------------------------------------------------------------------------

class TradeCard extends StatefulWidget {
  final String name;
  final String asset;
  final VoidCallback onTap;

  const TradeCard({
    super.key,
    required this.name,
    required this.asset,
    required this.onTap,
  });

  @override
  State<TradeCard> createState() => _TradeCardState();
}

class _TradeCardState extends State<TradeCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final scale = hovering ? 1.03 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 180),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1F25), Color(0xFF0D1117)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: hovering
                      ? Colors.blue.withOpacity(0.25)
                      : Colors.black.withOpacity(0.15),
                  blurRadius: hovering ? 20 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: hovering
                    ? Colors.blueAccent.withOpacity(0.4)
                    : Colors.white.withOpacity(0.08),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand logo
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(widget.asset),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
