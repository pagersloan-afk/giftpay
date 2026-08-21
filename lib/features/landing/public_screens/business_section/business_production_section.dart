import 'package:flutter/material.dart';

class BusinessProductsSection extends StatelessWidget {
  const BusinessProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 700;
    final isTablet = width >= 700 && width < 1100;

    final products = [
      {
        "img": "assets/illustrations/bulk_electricity.png",
        "title": "Bulk Electricity Tokens",
        "desc":
            "Instant multi-meter electricity token generation for offices, facilities, and distributed teams.",
        "tag": "UTILITY MANAGEMENT",
      },
      {
        "img": "assets/illustrations/airtime_distribution.png",
        "title": "Airtime Distribution",
        "desc":
            "Automate staff airtime top-ups and monthly communication allowances without manual processing.",
        "tag": "TEAM BENEFITS",
      },
      {
        "img": "assets/illustrations/corporate_data.png",
        "title": "Corporate Data Plans",
        "desc":
            "Manage and automate corporate data bundles for teams, devices, and connected operations.",
        "tag": "CONNECTIVITY",
      },
    ];

    return _BusinessSectionShell(
      eyebrow: "BUSINESS SOLUTIONS",
      title: "Everything your team needs to stay connected",
      description:
          "Simplify recurring utility operations with centralized tools designed for modern businesses.",
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = isMobile ? 1 : 3;

          final cardWidth = columns == 1
              ? constraints.maxWidth
              : (constraints.maxWidth - 48) / 3;

          return Wrap(
            spacing: 24,
            runSpacing: 24,
            children: products.map((product) {
              return SizedBox(
                width: cardWidth,
                child: _ProductCard(
                  imagePath: product["img"]!,
                  title: product["title"]!,
                  description: product["desc"]!,
                  tag: product["tag"]!,
                  compact: isTablet,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final String tag;
  final bool compact;

  const _ProductCard({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.tag,
    required this.compact,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return MouseRegion(
      onEnter: (_) {
        if (!isMobile) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) {
        if (!isMobile) {
          setState(() => _hovered = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -7 : 0, 0),
        padding: EdgeInsets.all(isMobile ? 18 : 22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _hovered
                ? const Color(0xFF4A6BB8).withOpacity(0.28)
                : Colors.white.withOpacity(0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF273D68,
              ).withOpacity(_hovered ? 0.14 : 0.07),
              blurRadius: _hovered ? 28 : 18,
              offset: Offset(0, _hovered ? 14 : 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: isMobile ? 190 : 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF2F5FA), Color(0xFFE7EDF7)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AnimatedScale(
                  scale: _hovered ? 1.055 : 1.0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  child: Image.asset(widget.imagePath, fit: BoxFit.contain),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF273D68).withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.tag,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: Color(0xFF355A8A),
                ),
              ),
            ),

            const SizedBox(height: 13),

            Text(
              widget.title,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF172744),
                height: 1.2,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              widget.description,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 13 : 14,
                color: const Color(0xFF596579),
                height: 1.55,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Text(
                  "Built for business",
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF355A8A),
                  ),
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: _hovered ? 34 : 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF273D68),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessSectionShell extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;
  final Widget child;

  const _BusinessSectionShell({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                Text(
                  eyebrow,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                    color: Color(0xFF4A6BB8),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontWeight: FontWeight.w800,
                    fontSize: isMobile ? 26 : 34,
                    height: 1.15,
                    letterSpacing: -0.6,
                    color: const Color(0xFF172744),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: isMobile ? 13 : 15,
                    color: const Color(0xFF657086),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 28 : 38),

          child,
        ],
      ),
    );
  }
}
