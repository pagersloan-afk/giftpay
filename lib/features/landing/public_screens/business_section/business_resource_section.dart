import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class BusinessResourcesSection extends StatelessWidget {
  const BusinessResourcesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    final resources = [
      {
        "img": "assets/illustrations/api_docs.png",
        "title": "API Documentation",
        "desc":
            "Integrate GiftPay Business into your internal systems with clear documentation and developer-friendly resources.",
        "button": "View API Docs",
        "icon": Icons.code_rounded,
      },
      {
        "img": "assets/illustrations/integration_guides.png",
        "title": "Integration Guides",
        "desc":
            "Follow practical guides for connecting GiftPay to your workflows and existing business infrastructure.",
        "button": "Explore Guides",
        "icon": Icons.account_tree_rounded,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                const Text(
                  "BUSINESS RESOURCES",
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                    color: Color(0xFF4A6BB8),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Everything you need to get started",
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
                  "Explore documentation and practical resources for building with GiftPay Business.",
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

          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = isMobile
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 24) / 2;

              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: resources.map((resource) {
                  return SizedBox(
                    width: cardWidth,
                    child: _ResourceCard(
                      imagePath: resource["img"] as String,
                      title: resource["title"] as String,
                      description: resource["desc"] as String,
                      buttonText: resource["button"] as String,
                      icon: resource["icon"] as IconData,
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

class _ResourceCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final String buttonText;
  final IconData icon;

  const _ResourceCard({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.icon,
  });

  @override
  State<_ResourceCard> createState() => _ResourceCardState();
}

class _ResourceCardState extends State<_ResourceCard> {
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
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _hovered
                ? GiftPayTheme.primaryBlue.withOpacity(0.25)
                : const Color(0xFFE6EBF3),
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
            SizedBox(
              height: isMobile ? 190 : 230,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(widget.imagePath, fit: BoxFit.cover),

                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFF172744).withOpacity(0.36),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    left: 18,
                    bottom: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.18),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(widget.icon, color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                "GIFT PAY",
                                style: const TextStyle(
                                  fontFamily: 'SegoeUI',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(isMobile ? 18 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: isMobile ? 18 : 21,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF172744),
                    ),
                  ),

                  const SizedBox(height: 10),

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

                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GiftPayTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.buttonText,
                          style: const TextStyle(
                            fontFamily: 'SegoeUI',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
