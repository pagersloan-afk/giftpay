import 'package:flutter/material.dart';

class GiftCardsFeaturedBrandsSection extends StatelessWidget {
  const GiftCardsFeaturedBrandsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final brands = [
      "assets/brands/apple.png",
      "assets/brands/netflix.png",
      "assets/brands/spotify.png",
      "assets/brands/amazon.png",
      "assets/brands/playstation.png",
      "assets/brands/xbox.png",
    ];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            "Featured Brands",
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
            children: brands.map((path) {
              return Container(
                width: isMobile ? 120 : 140,
                height: isMobile ? 120 : 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.70),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Image.asset(path, fit: BoxFit.contain),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
