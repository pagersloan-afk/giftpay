import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class BusinessResourcesSection extends StatelessWidget {
  const BusinessResourcesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    final resources = [
      {
        "img": "assets/illustrations/api_docs.png",
        "title": "API Documentation",
        "desc":
            "Integrate GiftPay Business into your internal systems with ease.",
        "button": "View API Docs",
      },
      {
        "img": "assets/illustrations/integration_guides.png",
        "title": "Integration Guides",
        "desc": "Step‑by‑step guides for connecting GiftPay to your workflows.",
        "button": "Explore Guides",
      },
    ];

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: EdgeInsets.all(isMobile ? 16 : 40),

        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: resources.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: isMobile ? 0.95 : 1.15,
          ),
          itemBuilder: (context, index) {
            final item = resources[index];

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(item["img"]!, fit: BoxFit.cover),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    item["title"]!,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    item["desc"]!,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: isMobile ? 13 : 15,
                      color: Colors.black54,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GiftPayTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, isMobile ? 36 : 42),
                      ),
                      child: Text(
                        item["button"]!,
                        style: TextStyle(
                          fontFamily: 'SegoeUI',
                          fontSize: isMobile ? 13 : 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
