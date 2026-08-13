import 'package:flutter/material.dart';
import 'package:utilityhub/features/landing/widgets/parent_overlay_card.dart';

import 'community_header.dart';
import 'community_grid.dart';

class CommunitySection extends StatelessWidget {
  const CommunitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 900;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 40 : 80,
      ),
      child: ParentOverlayCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommunityHeader(isMobile: isMobile),
            SizedBox(height: isMobile ? 28 : 34),
            const CommunityGrid(),
          ],
        ),
      ),
    );
  }
}
