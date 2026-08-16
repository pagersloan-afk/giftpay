import 'package:flutter/material.dart';
import 'package:utilityhub/features/gift_techlanding/sections/built_for_africa_section.dart';
import 'package:utilityhub/features/gift_techlanding/sections/businesses_section.dart';
import 'package:utilityhub/features/gift_techlanding/sections/ecosystem_section.dart';

// ⭐ Parent Landing Sections
import 'package:utilityhub/features/gift_techlanding/sections/hero_section.dart';

import 'package:utilityhub/features/gift_techlanding/sections/infrastructure_section.dart';
import 'package:utilityhub/features/gift_techlanding/sections/products_section.dart';
import 'package:utilityhub/features/gift_techlanding/sections/community/community_section.dart';
import 'package:utilityhub/features/gift_techlanding/sections/contact/contact_section.dart';
import 'package:utilityhub/features/gift_techlanding/sections/trust_section.dart';

// ⭐ Parent Landing Header + Footer
import 'package:utilityhub/features/gift_techlanding/widgets/gifttech_footer.dart';
import 'package:utilityhub/features/gift_techlanding/widgets/gifttech_header.dart';

// ⭐ Responsive Layout
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

// ⭐ Luxury Animated Background
import 'package:utilityhub/features/gift_techlanding/widgets/gifttech_background.dart';

/// Main Gift Technology landing page.
///
/// Landing architecture:
///
/// HERO
///   ↓
/// ECOSYSTEM
///   ↓
/// PRODUCTS
///   ↓
/// INFRASTRUCTURE
///   ↓
/// BUILT FOR AFRICA
///   ↓
/// FOR BUSINESSES
///   ↓
/// COMMUNITY
///   ↓
/// TRUST / SECURITY
///   ↓
/// CONTACT / CTA
///   ↓
/// FOOTER
///
/// Each major section owns its internal components. This file is only the
/// parent orchestrator responsible for page order, section anchors,
/// navigation, scrolling and the global landing-page shell.
class GiftTechLandingPage extends StatefulWidget {
  const GiftTechLandingPage({super.key});

  @override
  State<GiftTechLandingPage> createState() => _GiftTechLandingPageState();
}

class _GiftTechLandingPageState extends State<GiftTechLandingPage> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // -------------------------------------------------------------------------
  // SECTION NAVIGATION KEYS
  // -------------------------------------------------------------------------

  final GlobalKey _ecosystemKey = GlobalKey();

  final GlobalKey _productsKey = GlobalKey();

  final GlobalKey _infrastructureKey = GlobalKey();

  final GlobalKey _builtForAfricaKey = GlobalKey();

  final GlobalKey _businessesKey = GlobalKey();

  final GlobalKey _communityKey = GlobalKey();

  final GlobalKey _trustKey = GlobalKey();

  final GlobalKey _contactKey = GlobalKey();

  late final GiftTechHeader _header;

  @override
  void initState() {
    super.initState();

    // Keep one header instance so the same navigation callbacks are shared
    // between the desktop header and mobile drawer.
    _header = GiftTechHeader(
      onAboutTap: () => _scrollTo(_ecosystemKey),
      onProductsTap: () => _scrollTo(_productsKey),
      onCommunityTap: () => _scrollTo(_communityKey),
      onContactTap: () => _scrollTo(_contactKey),
    );
  }

  // -------------------------------------------------------------------------
  // SMOOTH SECTION SCROLL
  // -------------------------------------------------------------------------

  Future<void> _scrollTo(GlobalKey key) async {
    final targetContext = key.currentContext;

    if (targetContext == null) {
      return;
    }

    // Close mobile drawer before scrolling.
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();

      await Future<void>.delayed(const Duration(milliseconds: 180));
    }

    if (!mounted) {
      return;
    }

    final refreshedContext = key.currentContext;

    if (refreshedContext == null) {
      return;
    }

    await Scrollable.ensureVisible(
      refreshedContext,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      alignment: 0.04,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // PAGE
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      backgroundColor: const Color(0xFF050B18),

      // ---------------------------------------------------------------------
      // HEADER / MOBILE DRAWER
      // ---------------------------------------------------------------------
      drawer: _header.buildDrawer(context),

      appBar: _header,

      // ---------------------------------------------------------------------
      // GLOBAL LANDING BACKGROUND
      // ---------------------------------------------------------------------
      body: GiftTechBackground(
        child: LandingResponsiveLayout(
          child: Scrollbar(
            controller: _scrollController,

            thumbVisibility: false,

            child: SingleChildScrollView(
              controller: _scrollController,

              physics: const BouncingScrollPhysics(),

              padding: const EdgeInsets.only(bottom: 40),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  // =========================================================
                  // 01 — HERO
                  // =========================================================
                  const HeroSection(),

                  // =========================================================
                  // 02 — THE ECOSYSTEM
                  // Payments • Commerce • Utility
                  // =========================================================
                  Container(
                    key: _ecosystemKey,
                    child: const EcosystemSection(),
                  ),

                  // =========================================================
                  // 03 — PRODUCTS
                  // GiftPay • GiftPOS • Utilities • etc.
                  // =========================================================
                  Container(key: _productsKey, child: const ProductsSection()),

                  // =========================================================
                  // 04 — INFRASTRUCTURE
                  // Payments • APIs • Security
                  // =========================================================
                  Container(
                    key: _infrastructureKey,
                    child: const InfrastructureSection(),
                  ),

                  // =========================================================
                  // 05 — BUILT FOR AFRICA
                  // =========================================================
                  Container(
                    key: _builtForAfricaKey,
                    child: const BuiltForAfricaSection(),
                  ),

                  // =========================================================
                  // 06 — FOR BUSINESSES
                  // =========================================================
                  Container(
                    key: _businessesKey,
                    child: const BusinessesSection(),
                  ),

                  // =========================================================
                  // 07 — COMMUNITY
                  //
                  // CommunitySection remains the parent orchestrator for
                  // the community components. We are NOT replacing the
                  // existing community architecture here.
                  // =========================================================
                  Container(
                    key: _communityKey,
                    child: const CommunitySection(),
                  ),

                  // =========================================================
                  // 08 — TRUST / SECURITY
                  // =========================================================
                  Container(key: _trustKey, child: const TrustSection()),

                  // =========================================================
                  // 09 — CONTACT / CTA
                  // =========================================================
                  GiftTechContactSection(key: _contactKey),

                  // =========================================================
                  // 10 — FOOTER
                  // =========================================================
                  const GiftTechFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
