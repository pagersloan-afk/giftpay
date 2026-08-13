import 'package:flutter/material.dart';

// ⭐ Parent Landing Sections
import 'package:utilityhub/features/gift_techlanding/sections/about_section.dart';
import 'package:utilityhub/features/gift_techlanding/sections/community/community_section.dart';
import 'package:utilityhub/features/gift_techlanding/sections/contact/contact_section.dart';
import 'package:utilityhub/features/gift_techlanding/sections/hero_section.dart';
import 'package:utilityhub/features/gift_techlanding/sections/products_section.dart';

// ⭐ Parent Landing Header + Footer
import 'package:utilityhub/features/gift_techlanding/widgets/gifttech_footer.dart';
import 'package:utilityhub/features/gift_techlanding/widgets/gifttech_header.dart';

// ⭐ Responsive Layout
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

// ⭐ NEW Luxury Animated Background
import 'package:utilityhub/features/gift_techlanding/widgets/gifttech_background.dart';

class GiftTechLandingPage extends StatefulWidget {
  const GiftTechLandingPage({super.key});

  @override
  State<GiftTechLandingPage> createState() => _GiftTechLandingPageState();
}

class _GiftTechLandingPageState extends State<GiftTechLandingPage> {
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
              children: [
                const HeroSection(),

                // ABOUT
                Container(key: _aboutKey),
                const AboutSection(),

                // PRODUCTS
                Container(key: _productsKey),
                const ProductsSection(),

                // COMMUNITY
                Container(key: _communityKey),
                const CommunitySection(),

                // CONTACT
                GiftTechContactSection(key: _contactKey),

                const GiftTechFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
