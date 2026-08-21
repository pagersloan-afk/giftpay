import 'package:flutter/material.dart';

class GiftTechFooterHeader extends StatefulWidget
    implements PreferredSizeWidget {
  const GiftTechFooterHeader({
    super.key,
    this.aboutRoute = '/about-gifttech',
    this.productsRoute = '/products',
    this.communityRoute = '/community',
    this.contactRoute = '/contact',
  });

  /// Dedicated About page route.
  final String aboutRoute;

  /// Dedicated Products page route.
  final String productsRoute;

  /// Dedicated Community page route.
  final String communityRoute;

  /// Dedicated Contact page route.
  final String contactRoute;

  @override
  Size get preferredSize => const Size.fromHeight(78);

  @override
  State<GiftTechFooterHeader> createState() => _GiftTechFooterHeaderState();
}

class _GiftTechFooterHeaderState extends State<GiftTechFooterHeader> {
  static const Color _navy = Color(0xFF273D68);
  static const Color _softBlue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF7EA4FF);

  String? _hoveredItem;

  // ===========================================================================
  // ROUTE / PAGE HELPERS
  // ===========================================================================

  String _currentRoute(BuildContext context) {
    return ModalRoute.of(context)?.settings.name ?? '/gifttech';
  }

  bool _isGiftTechHome(BuildContext context) {
    final route = _currentRoute(context);

    return route == '/gifttech' || route == '/' || route.isEmpty;
  }

  String _pageTitle(BuildContext context) {
    final route = _currentRoute(context);

    switch (route) {
      case '/about-gifttech':
        return 'About Gift Technology';

      case '/products':
        return 'Products';

      case '/community':
        return 'Community';

      case '/contact':
        return 'Contact';

      case '/giftpay-wallet':
        return 'GiftPay Wallet';

      case '/giftpos':
        return 'GiftPOS';

      case '/giftcard-marketplace':
        return 'Gift Card Marketplace';

      case '/utilities-hub':
        return 'Utilities Hub';

      case '/gifttech-bulk-electricity':
        return 'Bulk Electricity';

      case '/corporate-data':
        return 'Corporate Data';

      case '/gifttech-airtime-distribution':
        return 'Airtime Distribution';

      case '/gift-tech-help-center':
        return 'Help Center';

      case '/order-status':
        return 'Order Status';

      case '/returns':
        return 'Returns';

      case '/find-store':
        return 'Find a Store';

      case '/legal':
        return 'Legal';

      case '/terms-of-sale':
        return 'Terms of Sale';

      case '/safety-center':
        return 'Safety Center';

      case '/creators':
        return 'Creators';

      case '/developers':
        return 'Developers';

      case '/business':
        return 'Business';

      case '/nonprofits':
        return 'Nonprofits';

      case '/download-sdks':
        return 'Download SDKs';

      case '/partner-program':
        return 'Partner Program';

      case '/tech-for-good':
        return 'Tech for Good';

      case '/data-privacy':
        return 'Data Privacy';

      case '/responsibility':
        return 'Responsible Practices';

      case '/accessibility':
        return 'Accessibility';

      case '/elections':
        return 'Elections';

      case '/company-info':
        return 'Company Information';

      case '/careers':
        return 'Careers';

      case '/media':
        return 'Media Gallery';

      case '/brand-resources':
        return 'Brand Resources';

      case '/investors':
        return 'Investors';

      case '/newsroom':
        return 'Newsroom';

      case '/community-standards':
        return 'Community Standards';

      case '/privacy-policy':
        return 'Privacy Policy';

      case '/terms':
        return 'Terms';

      case '/cookie-policy':
        return 'Cookie Policy';

      default:
        return _formatRouteTitle(route);
    }
  }

  String _formatRouteTitle(String route) {
    if (route.isEmpty || route == '/') {
      return 'Gift Technology';
    }

    final cleaned = route
        .replaceFirst('/', '')
        .replaceAll('-', ' ')
        .replaceAll('_', ' ');

    if (cleaned.isEmpty) {
      return 'Gift Technology';
    }

    return cleaned
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }

  // ===========================================================================
  // NAVIGATION
  // ===========================================================================

  void _navigate(BuildContext context, String route) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    // Prevent unnecessary navigation when already on the requested page.
    if (currentRoute == route) {
      return;
    }

    Navigator.of(context).pushNamed(route);
  }

  // ===========================================================================
  // MOBILE BACK
  //
  // Important:
  //
  // When a visitor navigates:
  //
  // /gifttech
  //     ↓
  // /products
  //
  // the browser receives a Flutter navigation history entry.
  //
  // Pressing the mobile browser BACK button therefore returns to /gifttech.
  //
  // The visible in-app back button also uses Navigator.pop(), keeping both
  // navigation systems synchronized.
  // ===========================================================================

  void _handleMobileBack(BuildContext context) {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    // If the visitor opened an inner page directly from a URL, there may be
    // no Flutter route underneath it. In that case return to the Gift
    // Technology landing page instead of allowing the back button to appear
    // useless.
    navigator.pushReplacementNamed('/gifttech');
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 760;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: _navy.withOpacity(0.97),
          border: Border(
            bottom: BorderSide(color: _highlight.withOpacity(0.12), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 30),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: isMobile
                    ? _buildMobileHeader(context)
                    : _buildDesktopHeader(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // DESKTOP HEADER
  //
  // Desktop keeps the original Gift Technology navigation.
  // ===========================================================================

  Widget _buildDesktopHeader(BuildContext context) {
    return Row(
      children: [
        _buildBrand(context),
        const Spacer(),
        _buildDesktopNavigation(context),
      ],
    );
  }

  Widget _buildDesktopNavigation(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNavItem(
          context,
          label: 'About',
          icon: Icons.business_outlined,
          route: widget.aboutRoute,
        ),
        _buildNavItem(
          context,
          label: 'Products',
          icon: Icons.grid_view_rounded,
          route: widget.productsRoute,
        ),
        _buildNavItem(
          context,
          label: 'Community',
          icon: Icons.groups_outlined,
          route: widget.communityRoute,
        ),
        _buildNavItem(
          context,
          label: 'Contact',
          icon: Icons.mail_outline_rounded,
          route: widget.contactRoute,
        ),
        const SizedBox(width: 8),
        _buildSearchButton(context),
      ],
    );
  }

  // ===========================================================================
  // MOBILE HEADER
  //
  // LANDING PAGE:
  //
  //     [ MENU ] [ GIFT TECHNOLOGY ] [ SEARCH ]
  //
  // INNER PAGE:
  //
  //     [ ← ] [ PAGE TITLE                  ] [ SEARCH ]
  //
  // This is the important behavioral change.
  // ===========================================================================

  Widget _buildMobileHeader(BuildContext context) {
    final bool isHome = _isGiftTechHome(context);

    if (isHome) {
      return _buildMobileHomeHeader(context);
    }

    return _buildMobileInnerPageHeader(context);
  }

  // ===========================================================================
  // MOBILE HOME HEADER
  // ===========================================================================

  Widget _buildMobileHomeHeader(BuildContext context) {
    return Row(
      children: [
        _buildMobileMenuButton(context),
        const SizedBox(width: 12),
        Expanded(child: _buildBrand(context)),
        const SizedBox(width: 8),
        _buildSearchButton(context),
      ],
    );
  }

  // ===========================================================================
  // MOBILE INNER PAGE HEADER
  // ===========================================================================

  Widget _buildMobileInnerPageHeader(BuildContext context) {
    final title = _pageTitle(context);

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          _buildMobileBackButton(context),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.05,
              ),
            ),
          ),

          const SizedBox(width: 8),

          _buildSearchButton(context),
        ],
      ),
    );
  }

  // ===========================================================================
  // MOBILE BACK BUTTON
  // ===========================================================================

  Widget _buildMobileBackButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _handleMobileBack(context),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.045),
            border: Border.all(color: Colors.white.withOpacity(0.075)),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // MOBILE MENU BUTTON
  // ===========================================================================

  Widget _buildMobileMenuButton(BuildContext context) {
    return Builder(
      builder: (buttonContext) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Scaffold.of(buttonContext).openDrawer();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withOpacity(0.045),
                border: Border.all(color: Colors.white.withOpacity(0.075)),
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // BRAND
  // ===========================================================================

  Widget _buildBrand(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/gifttech', (route) => false);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBrandMark(),
          const SizedBox(width: 11),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'GIFT TECHNOLOGY',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: isMobile ? 13 : 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: isMobile ? 1.05 : 1.35,
                    color: Colors.white,
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(height: 2),
                  Text(
                    'DIGITAL INFRASTRUCTURE FOR AFRICA',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.35,
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandMark() {
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
          BoxShadow(
            color: _softBlue.withOpacity(0.18),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
    );
  }

  // ===========================================================================
  // DESKTOP NAVIGATION ITEM
  // ===========================================================================

  Widget _buildNavItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String route,
  }) {
    final isHovered = _hoveredItem == label;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hoveredItem = label;
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredItem = null;
        });
      },
      child: GestureDetector(
        onTap: () => _navigate(context, route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: isHovered
                ? Colors.white.withOpacity(0.055)
                : Colors.transparent,
            border: Border.all(
              color: isHovered
                  ? _highlight.withOpacity(0.11)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isHovered ? _highlight : Colors.white.withOpacity(0.62),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isHovered
                      ? Colors.white
                      : Colors.white.withOpacity(0.72),
                  letterSpacing: 0.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SEARCH
  // ===========================================================================

  Widget _buildSearchButton(BuildContext context) {
    return Tooltip(
      message: 'Search',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: () {
            _showSearchNotice(context);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: Colors.white.withOpacity(0.035),
              border: Border.all(color: Colors.white.withOpacity(0.065)),
            ),
            child: Icon(
              Icons.search_rounded,
              size: 20,
              color: Colors.white.withOpacity(0.72),
            ),
          ),
        ),
      ),
    );
  }

  void _showSearchNotice(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _navy,
          elevation: 12,
          margin: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Row(
            children: [
              Icon(Icons.search_rounded, color: _highlight, size: 19),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search is coming soon.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ===========================================================================
  // MOBILE DRAWER
  //
  // This drawer is ONLY shown from the Gift Technology landing page header.
  //
  // When a drawer item is selected:
  //
  //     drawer
  //       ↓
  //     Navigator.pop()
  //       ↓
  //     Navigator.pushNamed()
  //       ↓
  //     new page
  //
  // Therefore the drawer does not remain over the new page.
  // ===========================================================================

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0A1020),
      elevation: 20,
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
                  _buildDrawerSectionLabel('EXPLORE'),

                  const SizedBox(height: 8),

                  _buildDrawerItem(
                    context,
                    icon: Icons.business_outlined,
                    title: 'About',
                    subtitle: 'Our company, mission & vision',
                    route: widget.aboutRoute,
                  ),

                  _buildDrawerItem(
                    context,
                    icon: Icons.grid_view_rounded,
                    title: 'Products',
                    subtitle: 'Platforms & digital solutions',
                    route: widget.productsRoute,
                  ),

                  _buildDrawerItem(
                    context,
                    icon: Icons.groups_outlined,
                    title: 'Community',
                    subtitle: 'People, programs & impact',
                    route: widget.communityRoute,
                  ),

                  _buildDrawerItem(
                    context,
                    icon: Icons.mail_outline_rounded,
                    title: 'Contact',
                    subtitle: 'Talk to Gift Technology',
                    route: widget.contactRoute,
                  ),

                  const SizedBox(height: 22),

                  _buildDrawerSectionLabel('COMPANY'),

                  const SizedBox(height: 8),

                  _buildDrawerInfo(
                    icon: Icons.location_on_outlined,
                    text: 'Port Harcourt, Rivers, Nigeria',
                  ),

                  _buildDrawerInfo(
                    icon: Icons.language_rounded,
                    text: 'gifttechnologyltd.com',
                  ),

                  _buildDrawerInfo(
                    icon: Icons.email_outlined,
                    text: 'support@gifttechnologyltd.com',
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
          _buildBrandMark(),

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
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close_rounded, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSectionLabel(String text) {
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

  Widget _buildDrawerItem(
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
            // Close the drawer FIRST.
            Navigator.of(context).pop();

            // Then create a new route in Flutter's navigation stack.
            _navigate(context, route);
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

  Widget _buildDrawerInfo({required IconData icon, required String text}) {
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
