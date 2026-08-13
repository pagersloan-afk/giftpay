import 'package:flutter/material.dart';
import 'community_card.dart';
import 'community_scroll_helper.dart';

class CommunityGrid extends StatefulWidget {
  const CommunityGrid({super.key});

  @override
  State<CommunityGrid> createState() => _CommunityGridState();
}

class _CommunityGridState extends State<CommunityGrid>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  bool _isHovering = false;

  final List<Map<String, dynamic>> _items = [
    {
      "title": "Developer Hub",
      "icon": Icons.code_rounded,
      "route": "/developers",
      "text": "API docs, SDKs, sandbox tools, and integration guides.",
    },
    {
      "title": "Community Programs",
      "icon": Icons.groups_rounded,
      "route": "/partner-program", // FIXED
      "text": "Events, partnerships, ambassadors, and innovation challenges.",
    },
    {
      "title": "Blog & Updates",
      "icon": Icons.auto_stories_rounded,
      "route": "/newsroom", // FIXED
      "text": "Product updates, engineering stories, and company news.",
    },
    {
      "title": "Support Center",
      "icon": Icons.support_agent_rounded,
      "route": "/help-center", // FIXED
      "text": "Help articles, FAQs, and customer support resources.",
    },
    {
      "title": "Careers",
      "icon": Icons.work_outline_rounded,
      "route": "/careers",
      "text": "Join our team and help build Africa’s digital future.",
    },
    {
      "title": "Social Media",
      "icon": Icons.public_rounded,
      "route": "/media-gallery", // FIXED
      "text": "Follow our journey across the social platforms.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startAutoScroll(_scrollController, () => _isHovering);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: SizedBox(
        height: 215,
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final item = _items[index];
            return CommunityCard(
              title: item["title"],
              text: item["text"],
              route: item["route"],
              icon: item["icon"],
            );
          },
        ),
      ),
    );
  }
}
