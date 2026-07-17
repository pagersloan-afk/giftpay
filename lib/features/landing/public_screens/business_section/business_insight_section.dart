import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class BusinessInsightsSection extends StatelessWidget {
  const BusinessInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    final insights = [
      {
        "img": "assets/illustrations/automation.png",
        "title": "Automation & Efficiency",
        "desc":
            "Reduce manual work with automated utility distribution workflows.",
        "button": "Learn more",
      },
      {
        "img": "assets/illustrations/spend_optimization.png",
        "title": "Utility Spend Optimization",
        "desc":
            "Track usage, reduce waste, and optimize monthly utility expenses.",
        "button": "View insights",
      },
      {
        "img": "assets/illustrations/api_integration.png",
        "title": "API Integrations",
        "desc":
            "Connect GiftPay Business to your internal systems and automate everything.",
        "button": "Explore API",
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
          itemCount: insights.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 3,
            crossAxisSpacing: isMobile ? 12 : 24,
            mainAxisSpacing: isMobile ? 16 : 24,
            childAspectRatio: isMobile ? 0.9 : 0.85,
          ),
          itemBuilder: (context, index) {
            final card = insights[index];

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
                  Expanded(
                    child: Image.asset(
                      card["img"]!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    card["title"]!,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    card["desc"]!,
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
                        card["button"]!,
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
