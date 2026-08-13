import 'package:flutter/material.dart';
import 'package:utilityhub/features/gift_techlanding/widgets/gifttech_background.dart';
import 'package:utilityhub/features/gift_techlanding/widgets/gifttech_header.dart';
import 'package:utilityhub/features/gift_techlanding/widgets/gifttech_footer.dart';
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

class GiftTechPageTemplate extends StatefulWidget {
  final String title;
  final String description;
  final Widget? child;

  const GiftTechPageTemplate({
    super.key,
    required this.title,
    required this.description,
    this.child,
  });

  @override
  State<GiftTechPageTemplate> createState() => _GiftTechPageTemplateState();
}

class _GiftTechPageTemplateState extends State<GiftTechPageTemplate> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _productsKey = GlobalKey();
  final GlobalKey _communityKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GiftTechHeader(
        onAboutTap: () => _scrollTo(_aboutKey),
        onProductsTap: () => _scrollTo(_productsKey),
        onCommunityTap: () => _scrollTo(_communityKey),
        onContactTap: () => _scrollTo(_contactKey),
      ),

      body: GiftTechBackground(
        child: LandingResponsiveLayout(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // TITLE
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // DESCRIPTION
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 18,
                      height: 1.6,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // OPTIONAL CONTENT
                if (widget.child != null) widget.child!,

                const SizedBox(height: 80),

                // ABOUT SECTION TARGET
                Container(key: _aboutKey),

                // PRODUCTS SECTION TARGET
                Container(key: _productsKey),

                // COMMUNITY SECTION TARGET
                Container(key: _communityKey),

                // CONTACT SECTION TARGET
                Container(key: _contactKey),

                const GiftTechFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
