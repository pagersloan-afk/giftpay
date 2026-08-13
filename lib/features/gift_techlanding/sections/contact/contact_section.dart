import 'package:flutter/material.dart';
import 'package:utilityhub/features/landing/widgets/parent_overlay_card.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

import 'contact_grid.dart';
import 'contact_form.dart';

class GiftTechContactSection extends StatelessWidget {
  const GiftTechContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 40 : 80,
      ),
      child: ParentOverlayCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Contact Us",
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 26 : 34,
                fontWeight: FontWeight.w800,
                color: const Color.fromARGB(255, 20, 40, 80),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "We’re here to help. Reach out to our support team, business department, or corporate office for assistance.",
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 15 : 17,
                height: 1.6,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 40),

            const ContactGrid(),

            const SizedBox(height: 60),

            ContactForm(isMobile: isMobile),
          ],
        ),
      ),
    );
  }
}
