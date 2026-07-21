import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class PressMediaKitSection extends StatelessWidget {
  const PressMediaKitSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            "Media Kit",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: isMobile ? 22 : 26,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Download official logos, product images, and brand guidelines for GiftPay press coverage.",
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 13 : 14,
              color: Colors.black.withOpacity(0.75),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Cards grid
          LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth;
              final bool isNarrow = maxWidth < 900;

              return Wrap(
                spacing: isMobile ? 16 : 20,
                runSpacing: isMobile ? 16 : 20,
                alignment: isMobile
                    ? WrapAlignment.center
                    : WrapAlignment.start,
                children: [
                  _MediaKitCard(
                    title: "Logo Pack",
                    description:
                        "High‑resolution GiftPay logos for print and digital use.",
                    buttonText: "Download logos",
                    icon: Icons.branding_watermark_outlined,
                    onTap: () {
                      // TODO: hook to actual asset / URL
                      Navigator.pushNamed(context, '/press/media-kit/logos');
                    },
                  ),
                  _MediaKitCard(
                    title: "Product Screens",
                    description:
                        "Official app screenshots and UI visuals for articles and features.",
                    buttonText: "Download screens",
                    icon: Icons.phone_iphone,
                    onTap: () {
                      Navigator.pushNamed(context, '/press/media-kit/screens');
                    },
                  ),
                  _MediaKitCard(
                    title: "Brand Guidelines",
                    description:
                        "Usage rules, colors, typography, and spacing for GiftPay branding.",
                    buttonText: "View guidelines",
                    icon: Icons.rule_folder_outlined,
                    onTap: () {
                      Navigator.pushNamed(context, '/press/media-kit/brand');
                    },
                  ),
                  _MediaKitCard(
                    title: "Press Contacts",
                    description:
                        "Reach our communications team for interviews and media requests.",
                    buttonText: "Contact press",
                    icon: Icons.mail_outline,
                    onTap: () {
                      Navigator.pushNamed(context, '/press/contact');
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MediaKitCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final IconData icon;
  final VoidCallback onTap;

  const _MediaKitCard({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.icon,
    required this.onTap,
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
          Icon(icon, size: 32, color: GiftPayTheme.primaryBlue),
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
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 13 : 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onTap,
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
            child: Text(
              buttonText,
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
