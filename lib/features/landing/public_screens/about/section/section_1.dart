import 'package:flutter/material.dart';

// ⚫ Hero Marquee
class HeroMarqueeSection extends StatelessWidget {
  const HeroMarqueeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SizedBox(
      height: isMobile ? 220 : 400,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/about-hero-lg.png", fit: BoxFit.cover),
          Align(
            alignment: isMobile ? Alignment.bottomCenter : Alignment.bottomLeft,
            child: Container(
              margin: EdgeInsets.all(isMobile ? 12 : 16),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 12,
              ),
              decoration: BoxDecoration(
                color: isMobile
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Empowering payments for people and businesses",
                textAlign: isMobile ? TextAlign.center : TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 15 : 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🟣 Three-Card Section
class ThreeCardSection extends StatelessWidget {
  const ThreeCardSection({super.key});

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
          InfoCard(
            imagePath: "assets/icons/card-investor-relations.png",
            title: "GiftPay for Partners",
            description:
                "Helping businesses scale with secure payments, APIs, and enterprise tools.",
            linkText: "Learn more",
            linkRoute: "/about/partners",
          ),
          InfoCard(
            imagePath: "assets/icons/card-leadership.png",
            title: "Leadership & Vision",
            description:
                "Guided by innovation, transparency, and a mission to simplify digital payments.",
            linkText: "Learn more",
            linkRoute: "/about/leadership",
          ),
          InfoCard(
            imagePath: "assets/icons/card-accessibility.png",
            title: "Accessibility & Inclusion",
            description:
                "Building financial tools that work for everyone, everywhere.",
            linkText: "Learn more",
            linkRoute: "/about/accessibility",
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final String linkText;
  final String linkRoute;

  const InfoCard({
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
          // ⭐ ICON SECTION — fully responsive & larger
          LayoutBuilder(
            builder: (context, constraints) {
              // ⭐ MAIN CONTROL: Adjust icon size relative to card width
              // Increase 0.30 → 0.40 or 0.50 for bigger icons
              final double iconSize = constraints.maxWidth * 0.80;

              return SizedBox(
                width: iconSize,
                height: iconSize,
                child: Image.asset(
                  imagePath,

                  // ⭐ FIT MODE:
                  // BoxFit.contain → shows full icon clearly
                  // BoxFit.cover → fills the square for bold look
                  fit: BoxFit.contain,
                ),
              );
            },
          ),

          const SizedBox(height: 16),

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

          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, linkRoute);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0033CC),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 20,
                vertical: isMobile ? 8 : 10,
              ),
            ),
            child: Text(
              linkText,
              style: const TextStyle(
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

// 🟡 Career Promo
class CareerPromoSection extends StatelessWidget {
  const CareerPromoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: const Color(0xFFF0F0F0),
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: isMobile
          ? Column(
              children: [
                Image.asset(
                  "assets/icons/career-promo.png",
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                _promoContent(context, isMobile),
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Image.asset(
                    "assets/icons/career-promo.png",
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _promoContent(context, isMobile)),
              ],
            ),
    );
  }

  Widget _promoContent(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          "Build a career that shapes the future of payments",
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 18 : 22,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Join GiftPay and help create secure, fast, and accessible financial tools for millions.",
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isMobile ? 13 : 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/about/careers');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0033CC),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 24,
              vertical: isMobile ? 10 : 12,
            ),
          ),
          child: const Text(
            "Join GiftPay",
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
