import 'package:flutter/material.dart';

import 'gifttech_dedicated_page_template.dart';

class GiftTechCommunityScreen extends StatelessWidget {
  const GiftTechCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechDedicatedPageTemplate(
      title: 'Community',
      eyebrow: 'THE GIFT TECHNOLOGY ECOSYSTEM',
      icon: Icons.groups_rounded,
      description:
          'We are building an ecosystem where creators, developers, businesses, partners, nonprofits, and communities can participate in Africa’s digital future.',
      metaLabel: 'ECOSYSTEM',
      metaValue: 'People • Partners • Builders',
      secondaryMetaLabel: 'FOCUS',
      secondaryMetaValue: 'Digital inclusion & opportunity',
      child: const _CommunityContent(),
    );
  }
}

class _CommunityContent extends StatelessWidget {
  const _CommunityContent();

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        'Creators',
        'Resources and opportunities for creators building audiences, products, and digital businesses across Africa.',
        Icons.auto_awesome_rounded,
      ),
      (
        'Developers',
        'APIs, SDKs, technical infrastructure, and developer resources for building on Gift Technology.',
        Icons.code_rounded,
      ),
      (
        'Businesses',
        'Technology that helps merchants and organizations manage payments, utilities, transactions, and digital operations.',
        Icons.business_outlined,
      ),
      (
        'Partners',
        'Strategic relationships that extend the reach and usefulness of the Gift Technology ecosystem.',
        Icons.handshake_outlined,
      ),
      (
        'Nonprofits',
        'Technology pathways that can support organizations working toward meaningful social and community outcomes.',
        Icons.volunteer_activism_outlined,
      ),
      (
        'Tech for Good',
        'Exploring practical ways technology can improve access, efficiency, inclusion, and opportunity.',
        Icons.public_rounded,
      ),
    ];

    final mobile = MediaQuery.sizeOf(context).width < 720;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: mobile ? 1 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: 205,
        ),
        itemBuilder: (context, index) {
          final item = items[index];

          return Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withOpacity(0.032),
              border: Border.all(color: Colors.white.withOpacity(0.065)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color(0xFF4A6BB8).withOpacity(0.13),
                  ),
                  child: Icon(
                    item.$3,
                    color: const Color(0xFF75A1FF),
                    size: 22,
                  ),
                ),
                const SizedBox(height: 17),
                Text(
                  item.$1,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.$2,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 12.5,
                    height: 1.6,
                    color: Colors.white.withOpacity(0.49),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
