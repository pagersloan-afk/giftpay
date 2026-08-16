import 'package:flutter/material.dart';

import 'community_card.dart';

class CommunityGrid extends StatelessWidget {
  const CommunityGrid({super.key});

  static const List<_CommunityItem> _items = [
    _CommunityItem(
      title: 'Developer Hub',
      icon: Icons.code_rounded,
      route: '/developers',
      text: 'API docs, SDKs, sandbox tools, and integration guides.',
    ),
    _CommunityItem(
      title: 'Community Programs',
      icon: Icons.groups_rounded,
      route: '/partner-program',
      text: 'Events, partnerships, ambassadors, and innovation challenges.',
    ),
    _CommunityItem(
      title: 'Blog & Updates',
      icon: Icons.auto_stories_rounded,
      route: '/newsroom',
      text: 'Product updates, engineering stories, and company news.',
    ),
    _CommunityItem(
      title: 'Support Center',
      icon: Icons.support_agent_rounded,
      route: '/gift-tech-help-center',
      text: 'Help articles, FAQs, and customer support resources.',
    ),
    _CommunityItem(
      title: 'Careers',
      icon: Icons.work_outline_rounded,
      route: '/careers',
      text: 'Join our team and help build Africa’s digital future.',
    ),
    _CommunityItem(
      title: 'Social Media',
      icon: Icons.public_rounded,
      route: '/media-gallery',
      text: 'Follow our journey across the social platforms.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool isMobile = width < 700;
    final bool isTablet = width >= 700 && width < 1100;

    // ---------------------------------------------------------------
    // MOBILE
    // ---------------------------------------------------------------

    if (isMobile) {
      return Column(
        children: [
          for (int index = 0; index < _items.length; index++) ...[
            _buildCard(_items[index], isMobile: true),
            if (index != _items.length - 1) const SizedBox(height: 14),
          ],
        ],
      );
    }

    // ---------------------------------------------------------------
    // TABLET / DESKTOP
    // ---------------------------------------------------------------

    final int columns = isTablet ? 2 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: isTablet ? 1.55 : 1.45,
      ),
      itemBuilder: (context, index) {
        return _buildCard(_items[index], isMobile: false);
      },
    );
  }

  Widget _buildCard(_CommunityItem item, {required bool isMobile}) {
    return CommunityCard(
      title: item.title,
      text: item.text,
      route: item.route,
      icon: item.icon,
    );
  }
}

class _CommunityItem {
  final String title;
  final String text;
  final String route;
  final IconData icon;

  const _CommunityItem({
    required this.title,
    required this.text,
    required this.route,
    required this.icon,
  });
}
