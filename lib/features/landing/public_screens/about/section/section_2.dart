import 'package:flutter/material.dart';

// 🔵 Additional Cards Section
class AdditionalCardsSection extends StatelessWidget {
  const AdditionalCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Wrap(
        spacing: isMobile ? 12 : 20,
        runSpacing: isMobile ? 16 : 20,
        alignment: WrapAlignment.center,
        children: [
          AdditionalCard(
            imagePath: "assets/icons/responsibility-icon.png",
            title: "Security & Trust",
            description:
                "GiftPay is committed to secure transactions, fraud prevention, and user protection.",
            linkText: "Learn more >",
            linkRoute: "/about/security",
          ),
          AdditionalCard(
            imagePath: "assets/icons/news-icon.png",
            title: "GiftPay News",
            description:
                "Stay updated with new features, partnerships, and product releases.",
            linkText: "Learn more >",
            linkRoute: "/about/news",
          ),
          AdditionalCard(
            imagePath: "assets/icons/stories-icon.png",
            title: "Customer Stories",
            description:
                "Real experiences from people and businesses using GiftPay every day.",
            linkText: "Get inspired >",
            linkRoute: "/about/stories",
          ),
        ],
      ),
    );
  }
}

// 🟣 Individual Card Widget
class AdditionalCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final String linkText;
  final String linkRoute;

  const AdditionalCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.linkText,
    required this.linkRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: isMobile ? double.infinity : 300,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ⭐ IMAGE SECTION — now expands naturally
          LayoutBuilder(
            builder: (context, constraints) {
              // ⭐ MAIN CONTROL: Adjust image height relative to card width
              // Recommended: 0.45 → 0.60 for large visible images
              final double imgHeight = constraints.maxWidth * 1.00;

              return SizedBox(
                width: double.infinity,
                height: imgHeight, // ⭐ Card expands automatically
                child: Image.asset(
                  imagePath,

                  // ⭐ FIT MODE:
                  // BoxFit.contain → shows full icon clearly
                  // BoxFit.cover → fills width for dramatic effect
                  fit: BoxFit.contain,
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 15 : 17,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 13 : 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, linkRoute);
            },
            child: Text(
              linkText,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: isMobile ? 13 : 14,
                color: const Color(0xFF0033CC),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🟠 History Section
class HistorySection extends StatelessWidget {
  const HistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Our Journey",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 18 : 22,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "GiftPay started with a mission: make payments simple, fast, and accessible. Today, millions rely on us for everyday transactions.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 13 : 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/about/history');
            },
            child: Text(
              "Explore our story",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: isMobile ? 12 : 14,
                color: const Color(0xFF0033CC),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ⚪ Footer
class PremiumFooter extends StatelessWidget {
  const PremiumFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final links = [
      {"label": "Privacy & Legal", "route": "/privacy"},
      {"label": "Security", "route": "/security"},
      {"label": "Terms of Use", "route": "/terms"},
      {"label": "Report Fraud", "route": "/fraud"},
      {"label": "Sitemap", "route": "/sitemap"},
      {"label": "About GiftPay", "route": "/about"},
      {"label": "Careers", "route": "/careers"},
      {"label": "Accessibility", "route": "/accessibility"},
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFF222222),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 20 : 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: isMobile ? 12 : 16,
            runSpacing: isMobile ? 8 : 12,
            alignment: WrapAlignment.center,
            children: links
                .map(
                  (link) => TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, link["route"]!);
                    },
                    child: Text(
                      link["label"]!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: isMobile ? 12 : 13,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            "© 2026 GiftPay. All rights reserved.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 11 : 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
