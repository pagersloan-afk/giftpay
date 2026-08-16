import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:utilityhub/features/gift_techlanding/widgets/gifttech_background.dart';
import 'package:utilityhub/features/gift_techlanding/widgets/gifttech_footer.dart';
import 'package:utilityhub/features/gift_techlanding/widgets/gifttech_footer_header.dart';
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

/// Luxury shell for Gift Technology's primary corporate navigation pages.
///
/// Used by:
/// - About
/// - Products
/// - Community
/// - Contact
///
/// This template is intentionally separate from the footer/legal
/// GiftTechPageTemplate architecture.
class GiftTechDedicatedPageTemplate extends StatefulWidget {
  const GiftTechDedicatedPageTemplate({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.eyebrow = 'GIFT TECHNOLOGY',
    this.icon = Icons.auto_awesome_rounded,
    this.metaLabel = 'COMPANY',
    this.metaValue = 'Gift Technology Ltd',
    this.secondaryMetaLabel = 'LOCATION',
    this.secondaryMetaValue = 'Port Harcourt, Nigeria',
    this.showFooter = true,
  });

  final String title;
  final String description;
  final Widget child;

  final String eyebrow;
  final IconData icon;

  final String metaLabel;
  final String metaValue;

  final String? secondaryMetaLabel;
  final String? secondaryMetaValue;

  final bool showFooter;

  @override
  State<GiftTechDedicatedPageTemplate> createState() =>
      _GiftTechDedicatedPageTemplateState();
}

class _GiftTechDedicatedPageTemplateState
    extends State<GiftTechDedicatedPageTemplate> {
  final ScrollController _scrollController = ScrollController();

  static const Color _navy = Color(0xFF273D68);
  static const Color _softBlue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF75A1FF);
  static const Color _background = Color(0xFF050B18);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,

      // The header's mobile menu uses Scaffold.of(context).openDrawer().
      // Keeping the drawer here means the header remains reusable and
      // does not need to expose its internal drawer implementation.
      drawer: _buildNavigationDrawer(context),

      appBar: GiftTechFooterHeader(
        aboutRoute: '/about',
        productsRoute: '/products',
        communityRoute: '/community',
        contactRoute: '/contact',
      ),

      body: GiftTechBackground(
        child: LandingResponsiveLayout(
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: false,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 36),

                  _buildHero(context),

                  const SizedBox(height: 30),

                  widget.child,

                  if (widget.showFooter) ...[
                    const SizedBox(height: 80),
                    const GiftTechFooter(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HERO
  // ---------------------------------------------------------------------------

  Widget _buildHero(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final isMobile = width < 720;
    final isTablet = width >= 720 && width < 1100;

    final horizontalPadding = isMobile
        ? 18.0
        : isTablet
        ? 30.0
        : 52.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 26 : 34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 56,
              vertical: isMobile ? 32 : 50,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 26 : 34),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.105),
                  Colors.white.withOpacity(0.045),
                  _softBlue.withOpacity(0.055),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: _softBlue.withOpacity(0.11),
                  blurRadius: 80,
                  spreadRadius: -15,
                  offset: const Offset(0, 25),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: isMobile ? _buildMobileHero() : _buildDesktopHero(),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHero() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildHeroCopy()),
        const SizedBox(width: 50),
        _buildHeroOrb(148),
      ],
    );
  }

  Widget _buildMobileHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroOrb(84),
        const SizedBox(height: 26),
        _buildHeroCopy(),
      ],
    );
  }

  Widget _buildHeroCopy() {
    final isMobile = MediaQuery.sizeOf(context).width < 720;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _highlight,
                boxShadow: [
                  BoxShadow(
                    color: _highlight.withOpacity(0.70),
                    blurRadius: 14,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.eyebrow.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.4,
                color: _highlight,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Text(
          widget.title,
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: isMobile ? 42 : 66,
            height: 0.98,
            fontWeight: FontWeight.w800,
            letterSpacing: isMobile ? -1.4 : -2.6,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 22),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            widget.description,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isMobile ? 14.5 : 17,
              height: 1.7,
              color: Colors.white.withOpacity(0.66),
            ),
          ),
        ),

        const SizedBox(height: 28),

        Wrap(
          spacing: 30,
          runSpacing: 16,
          children: [
            _buildMeta(widget.metaLabel, widget.metaValue),
            if (widget.secondaryMetaLabel != null &&
                widget.secondaryMetaValue != null)
              _buildMeta(
                widget.secondaryMetaLabel!,
                widget.secondaryMetaValue!,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.7,
            color: Colors.white.withOpacity(0.30),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.70),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroOrb(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            _highlight.withOpacity(0.20),
            _navy.withOpacity(0.10),
            Colors.transparent,
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.13)),
        boxShadow: [
          BoxShadow(
            color: _softBlue.withOpacity(0.18),
            blurRadius: 50,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.62,
          height: size * 0.62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.045),
            border: Border.all(color: Colors.white.withOpacity(0.11)),
          ),
          child: Icon(widget.icon, size: size * 0.29, color: _highlight),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE NAVIGATION DRAWER
  // ---------------------------------------------------------------------------

  Widget _buildNavigationDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0A1020),
      elevation: 24,
      width: 330,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(context),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                children: [
                  _drawerLabel('EXPLORE'),
                  const SizedBox(height: 9),

                  _drawerItem(
                    context,
                    icon: Icons.business_outlined,
                    title: 'About',
                    subtitle: 'Our company, mission & vision',
                    route: '/about',
                  ),

                  _drawerItem(
                    context,
                    icon: Icons.grid_view_rounded,
                    title: 'Products',
                    subtitle: 'Platforms & digital solutions',
                    route: '/products',
                  ),

                  _drawerItem(
                    context,
                    icon: Icons.groups_outlined,
                    title: 'Community',
                    subtitle: 'People, programs & impact',
                    route: '/community',
                  ),

                  _drawerItem(
                    context,
                    icon: Icons.mail_outline_rounded,
                    title: 'Contact',
                    subtitle: 'Talk to Gift Technology',
                    route: '/contact',
                  ),

                  const SizedBox(height: 24),

                  _drawerLabel('COMPANY'),
                  const SizedBox(height: 9),

                  _drawerInfo(
                    Icons.location_on_outlined,
                    'Port Harcourt, Rivers, Nigeria',
                  ),

                  _drawerInfo(Icons.language_rounded, 'gifttechnologyltd.com'),

                  _drawerInfo(
                    Icons.email_outlined,
                    'support@gifttechnologyltd.com',
                  ),
                ],
              ),
            ),
            _buildDrawerFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 14, 15),
      child: Row(
        children: [
          _drawerBrandMark(),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GIFT TECHNOLOGY',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'DIGITAL INFRASTRUCTURE FOR AFRICA',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _drawerBrandMark() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_softBlue.withOpacity(0.95), _navy],
        ),
        border: Border.all(color: _highlight.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(color: _softBlue.withOpacity(0.18), blurRadius: 18),
        ],
      ),
      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
    );
  }

  Widget _drawerLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'SegoeUI',
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.7,
          color: _highlight,
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(route);
          },
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.025),
              border: Border.all(color: Colors.white.withOpacity(0.055)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _softBlue.withOpacity(0.10),
                  ),
                  child: Icon(icon, color: _highlight, size: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'SegoeUI',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'SegoeUI',
                          fontSize: 9.5,
                          color: Colors.white.withOpacity(0.38),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: Colors.white.withOpacity(0.25),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawerInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.32)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 9.5,
                color: Colors.white.withOpacity(0.38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.055))),
      ),
      child: Text(
        'GIFT TECHNOLOGY LTD  •  PORT HARCOURT, NIGERIA',
        style: TextStyle(
          fontFamily: 'SegoeUI',
          fontSize: 7.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: Colors.white.withOpacity(0.25),
        ),
      ),
    );
  }
}
