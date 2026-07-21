import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class GiftCardsCategoriesSection extends StatelessWidget {
  const GiftCardsCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final categories = [
      {
        "title": "Airtime & Data",
        "image": "assets/icons/catalog-airtime.png",
        "route": "/giftcards/airtime",
      },
      {
        "title": "Shopping",
        "image": "assets/icons/catalog-shopping.png",
        "route": "/giftcards/shopping",
      },
      {
        "title": "Entertainment",
        "image": "assets/icons/catalog-entertainment.png",
        "route": "/giftcards/entertainment",
      },
      {
        "title": "Gaming",
        "image": "assets/icons/catalog-gaming.png",
        "route": "/giftcards/gaming",
      },
    ];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            "Categories",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: isMobile ? 22 : 26,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: isMobile ? 16 : 20,
            runSpacing: isMobile ? 16 : 20,
            alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
            children: categories.map((item) {
              return _CategoryCard(
                title: item["title"]!,
                imagePath: item["image"]!,
                route: item["route"]!,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String route;

  const _CategoryCard({
    required this.title,
    required this.imagePath,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: isMobile ? double.infinity : 260,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.70),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(imagePath, height: isMobile ? 120 : 140),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: isMobile ? 15 : 17,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, route);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GiftPayTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 18 : 20,
                vertical: isMobile ? 8 : 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Explore",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
