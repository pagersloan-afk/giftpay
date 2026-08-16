import 'package:flutter/material.dart';

import 'about_shared.dart';

class AboutHeader extends StatelessWidget {
  const AboutHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AboutColors.highlight,
                boxShadow: [
                  BoxShadow(
                    color: AboutColors.highlight.withOpacity(0.65),
                    blurRadius: 14,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'ABOUT GIFT TECHNOLOGY',
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
                color: AboutColors.highlight,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Text(
            'Building technology with purpose.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isMobile ? 38 : 58,
              height: 1.0,
              fontWeight: FontWeight.w800,
              letterSpacing: isMobile ? -1.4 : -2.4,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 20),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Text(
            'Gift Technology Ltd is building a connected technology ecosystem designed to make digital services more accessible, useful, and scalable across Africa.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isMobile ? 15 : 18,
              height: 1.7,
              color: Colors.white.withOpacity(0.48),
            ),
          ),
        ),
      ],
    );
  }
}
