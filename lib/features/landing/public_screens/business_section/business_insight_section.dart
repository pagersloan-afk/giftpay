import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class BusinessInsightsSection extends StatelessWidget {
  const BusinessInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 700;

    final insights = [
      {
        "img": "assets/illustrations/automation.png",
        "title": "Automation & Efficiency",
        "desc":
            "Reduce repetitive work with automated utility distribution workflows built around your team's needs.",
        "button": "Learn more",
        "icon": Icons.auto_awesome_rounded,
      },
      {
        "img": "assets/illustrations/spend_optimization.png",
        "title": "Utility Spend Optimization",
        "desc":
            "Track usage, reduce waste, and gain better visibility into recurring monthly utility expenses.",
        "button": "View insights",
        "icon": Icons.insights_rounded,
      },
      {
        "img": "assets/illustrations/api_integration.png",
        "title": "API Integrations",
        "desc":
            "Connect GiftPay Business to your internal systems and create seamless automated workflows.",
        "button": "Explore API",
        "icon": Icons.integration_instructions_rounded,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      child: Column(
        children: [
          _SectionHeading(
            eyebrow: "WHY GIFT PAY BUSINESS",
            title: "Designed around the way businesses operate",
            description:
                "From automation to integration, GiftPay helps your organization manage everyday utility operations with less friction.",
            isMobile: isMobile,
          ),

          SizedBox(height: isMobile ? 28 : 38),

          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = isMobile
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 48) / 3;

              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: insights.map((item) {
                  return SizedBox(
                    width: cardWidth,
                    child: _InsightCard(
                      imagePath: item["img"] as String,
                      title: item["title"] as String,
                      description: item["desc"] as String,
                      buttonText: item["button"] as String,
                      icon: item["icon"] as IconData,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final String buttonText;
  final IconData icon;

  const _InsightCard({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.icon,
  });

  @override
  State<_InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<_InsightCard> {
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
        transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
        padding: EdgeInsets.all(isMobile ? 18 : 22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _hovered
                ? GiftPayTheme.primaryBlue.withOpacity(0.25)
                : const Color(0xFFE7ECF4),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF273D68,
              ).withOpacity(_hovered ? 0.13 : 0.06),
              blurRadius: _hovered ? 28 : 18,
              offset: Offset(0, _hovered ? 14 : 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: isMobile ? 180 : 205,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF4F7FC), Color(0xFFEAF0F8)],
                ),
              ),
              child: AnimatedScale(
                scale: _hovered ? 1.04 : 1.0,
                duration: const Duration(milliseconds: 350),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(widget.imagePath, fit: BoxFit.contain),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF273D68),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 17),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: isMobile ? 17 : 19,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF172744),
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              widget.description,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 13 : 14,
                color: const Color(0xFF657086),
                height: 1.55,
              ),
            ),

            const SizedBox(height: 18),

            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: GiftPayTheme.primaryBlue,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.buttonText,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;
  final bool isMobile;

  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
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
              fontSize: isMobile ? 26 : 34,
              fontWeight: FontWeight.w800,
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
              height: 1.55,
              color: const Color(0xFF657086),
            ),
          ),
        ],
      ),
    );
  }
}
