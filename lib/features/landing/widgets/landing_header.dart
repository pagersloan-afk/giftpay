import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class LandingHeader extends StatefulWidget implements PreferredSizeWidget {
  const LandingHeader({super.key});

  static const double headerHeight = 72;

  @override
  Size get preferredSize => const Size.fromHeight(headerHeight);

  @override
  State<LandingHeader> createState() => _LandingHeaderState();
}

class _LandingHeaderState extends State<LandingHeader> {
  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF75A1FF);

  final LayerLink _productsLayerLink = LayerLink();

  OverlayEntry? _productsOverlay;
  bool _productsHovered = false;

  @override
  void dispose() {
    _removeProductsOverlay();
    super.dispose();
  }

  // ===========================================================================
  // ROUTE HELPERS
  // ===========================================================================

  String? _currentRoute(BuildContext context) {
    return ModalRoute.of(context)?.settings.name;
  }

  bool _isGiftPayLandingRoute(BuildContext context) {
    final route = _currentRoute(context);

    return route == null ||
        route == '/' ||
        route == '/landing' ||
        route == '/giftpay';
  }

  String _pageTitle(BuildContext context) {
    final route = _currentRoute(context);

    const titles = <String, String>{
      '/login': 'Sign In',
      '/signup': 'Create Account',
      '/signup-pin': 'Create PIN',
      '/signup-wallet': 'Create Wallet',
      '/giftpay-business': 'Business',
      '/personal': 'Personal',
      '/bulk-electricity': 'Bulk Electricity',
      '/airtime-distribution': 'Airtime Distribution',
      '/corporate_data': 'Corporate Data',
      '/p-wallet': 'GiftPay Wallet',
      '/business-dashboard': 'Business Dashboard',
      '/api': 'GiftPay API',
      '/gift-cards': 'Gift Cards',
      '/rewards': 'Rewards',
      '/contact_us': 'Contact',
      '/about_us': 'About GiftPay',
      '/press': 'Press',
      '/security': 'Security',
      '/giftpay-careers': 'Careers',
      '/add-money': 'Add Money',
      '/aviation-public': 'Flight Booking',
    };

    if (route != null && titles.containsKey(route)) {
      return titles[route]!;
    }

    if (route == null || route.isEmpty || route == '/') {
      return 'GiftPay';
    }

    final clean = route.replaceFirst('/', '').replaceAll('-', ' ');

    return clean
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool isMobile = width < 700;
    final bool isTablet = width >= 700 && width < 1050;

    final bool showMobileInnerHeader =
        isMobile && !_isGiftPayLandingRoute(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _navy,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile
                      ? 16
                      : isTablet
                      ? 24
                      : 32,
                  vertical: 12,
                ),
                child: showMobileInnerHeader
                    ? _buildMobileInnerHeader(context)
                    : isMobile
                    ? _buildMobileLandingHeader(context)
                    : _buildWebHeader(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // DESKTOP / TABLET WEB HEADER
  // ===========================================================================

  Widget _buildWebHeader(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool compact = width < 900;

    return SizedBox(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBrand(context),

          SizedBox(width: compact ? 18 : 28),

          _buildNavLink(
            context,
            label: 'Business',
            route: '/giftpay-business',
            compact: compact,
          ),

          _buildNavLink(
            context,
            label: 'Personal',
            route: '/personal',
            compact: compact,
          ),

          _buildProductsNav(context, compact: compact),

          _buildNavLink(
            context,
            label: 'About',
            route: '/about_us',
            compact: compact,
          ),

          _buildNavLink(
            context,
            label: 'Contact',
            route: '/contact_us',
            compact: compact,
          ),

          SizedBox(width: compact ? 8 : 12),

          _buildSearchButton(compact: compact),

          SizedBox(width: compact ? 8 : 14),

          _buildSignInButton(context, compact: compact),
        ],
      ),
    );
  }

  // ===========================================================================
  // GIFT PAY BRAND
  // ===========================================================================

  Widget _buildBrand(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).pushNamed('/giftpay');
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFEAF0FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: _lightBlue.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'G',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _navy,
                ),
              ),
            ),
          ),
          const SizedBox(width: 11),
          const Text(
            'GiftPay',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MOBILE LANDING HEADER
  // ===========================================================================

  Widget _buildMobileLandingHeader(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          _buildMobileMenuButton(context),

          const SizedBox(width: 12),

          Expanded(child: _buildBrand(context)),

          const SizedBox(width: 8),

          _buildMobileSignIn(context),
        ],
      ),
    );
  }

  // ===========================================================================
  // MOBILE INNER PAGE HEADER
  // ===========================================================================

  Widget _buildMobileInnerHeader(BuildContext context) {
    final title = _pageTitle(context);

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Material(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(11),
            child: InkWell(
              borderRadius: BorderRadius.circular(11),
              onTap: () async {
                final navigator = Navigator.of(context);

                final didPop = await navigator.maybePop();

                if (!didPop && mounted) {
                  navigator.pushReplacementNamed('/giftpay');
                }
              },
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 8),

          _buildMobileBrandMark(),
        ],
      ),
    );
  }

  Widget _buildMobileBrandMark() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: _lightBlue.withOpacity(0.16), blurRadius: 12),
        ],
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: _navy,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // MOBILE MENU BUTTON
  // ===========================================================================

  Widget _buildMobileMenuButton(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () => _openMobileDrawer(context),
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(Icons.menu_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  // ===========================================================================
  // MOBILE SIGN IN
  // ===========================================================================

  Widget _buildMobileSignIn(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/login');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        elevation: 0,
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'Sign In',
        style: TextStyle(
          fontFamily: 'SegoeUI',
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ===========================================================================
  // DESKTOP NAV LINK
  // ===========================================================================

  Widget _buildNavLink(
    BuildContext context, {
    required String label,
    required String route,
    required bool compact,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pushNamed(route);
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 13,
            vertical: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'SegoeUI',
            color: Colors.white.withOpacity(0.88),
            fontWeight: FontWeight.w600,
            fontSize: compact ? 13 : 14,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PRODUCTS
  // ===========================================================================

  Widget _buildProductsNav(BuildContext context, {required bool compact}) {
    return MouseRegion(
      onEnter: (_) {
        _productsHovered = true;
        _showProductsOverlay(context);
      },
      onExit: (_) {
        _productsHovered = false;
        _scheduleProductsOverlayRemoval();
      },
      child: CompositedTransformTarget(
        link: _productsLayerLink,
        child: TextButton(
          onPressed: () {
            if (_productsOverlay == null) {
              _showProductsOverlay(context);
            } else {
              _removeProductsOverlay();
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 13,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Products',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  color: Colors.white.withOpacity(0.88),
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 13 : 14,
                ),
              ),
              const SizedBox(width: 5),
              AnimatedRotation(
                turns: _productsOverlay != null ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Colors.white.withOpacity(0.70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductsOverlay(BuildContext context) {
    if (_productsOverlay != null) return;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final double menuWidth = screenWidth < 620 ? screenWidth - 24 : 570;

    _productsOverlay = OverlayEntry(
      builder: (overlayContext) {
        return Positioned(
          width: menuWidth,
          child: CompositedTransformFollower(
            link: _productsLayerLink,
            showWhenUnlinked: false,
            offset: screenWidth >= 620
                ? const Offset(-205, 48)
                : Offset(-(menuWidth / 2) + 45, 48),
            child: MouseRegion(
              onEnter: (_) {
                _productsHovered = true;
              },
              onExit: (_) {
                _productsHovered = false;
                _scheduleProductsOverlayRemoval();
              },
              child: Material(
                color: Colors.transparent,
                child: _buildProductsMenu(context),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_productsOverlay!);

    if (mounted) {
      setState(() {});
    }
  }

  void _scheduleProductsOverlayRemoval() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!_productsHovered) {
        _removeProductsOverlay();
      }
    });
  }

  void _removeProductsOverlay() {
    _productsOverlay?.remove();
    _productsOverlay = null;

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildProductsMenu(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final narrow = width < 620;

    return Container(
      margin: const EdgeInsets.only(top: 7),
      padding: EdgeInsets.all(narrow ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _blue.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.16),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductGroup(
                  title: 'Utilities',
                  icon: Icons.bolt_rounded,
                  items: [
                    _ProductMenuItem(
                      'Bulk Electricity Tokens',
                      '/bulk-electricity',
                      Icons.bolt_rounded,
                    ),
                    _ProductMenuItem(
                      'Airtime Distribution',
                      '/airtime-distribution',
                      Icons.phone_android_rounded,
                    ),
                    _ProductMenuItem(
                      'Corporate Data Plans',
                      '/corporate_data',
                      Icons.wifi_rounded,
                    ),
                    _ProductMenuItem(
                      'GiftPay Wallet',
                      '/p-wallet',
                      Icons.account_balance_wallet_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildProductGroup(
                  title: 'Lifestyle',
                  icon: Icons.auto_awesome_rounded,
                  items: [
                    _ProductMenuItem(
                      'Gift Cards',
                      '/gift-cards',
                      Icons.card_giftcard_rounded,
                    ),
                    _ProductMenuItem(
                      'Flight Booking',
                      '/aviation-public',
                      Icons.flight_takeoff_rounded,
                    ),
                    _ProductMenuItem(
                      'GiftPay Personal',
                      '/personal',
                      Icons.person_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildProductGroup(
                  title: 'Business',
                  icon: Icons.business_center_rounded,
                  items: [
                    _ProductMenuItem(
                      'Business Dashboard',
                      '/business-dashboard',
                      Icons.dashboard_rounded,
                    ),
                    _ProductMenuItem('GiftPay API', '/api', Icons.api_rounded),
                  ],
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildProductGroup(
                    title: 'Utilities',
                    icon: Icons.bolt_rounded,
                    items: [
                      _ProductMenuItem(
                        'Bulk Electricity Tokens',
                        '/bulk-electricity',
                        Icons.bolt_rounded,
                      ),
                      _ProductMenuItem(
                        'Airtime Distribution',
                        '/airtime-distribution',
                        Icons.phone_android_rounded,
                      ),
                      _ProductMenuItem(
                        'Corporate Data Plans',
                        '/corporate_data',
                        Icons.wifi_rounded,
                      ),
                      _ProductMenuItem(
                        'GiftPay Wallet',
                        '/p-wallet',
                        Icons.account_balance_wallet_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProductGroup(
                    title: 'Lifestyle',
                    icon: Icons.auto_awesome_rounded,
                    items: [
                      _ProductMenuItem(
                        'Gift Cards',
                        '/gift-cards',
                        Icons.card_giftcard_rounded,
                      ),
                      _ProductMenuItem(
                        'Flight Booking',
                        '/aviation-public',
                        Icons.flight_takeoff_rounded,
                      ),
                      _ProductMenuItem(
                        'GiftPay Personal',
                        '/personal',
                        Icons.person_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProductGroup(
                    title: 'Business',
                    icon: Icons.business_center_rounded,
                    items: [
                      _ProductMenuItem(
                        'Business Dashboard',
                        '/business-dashboard',
                        Icons.dashboard_rounded,
                      ),
                      _ProductMenuItem(
                        'GiftPay API',
                        '/api',
                        Icons.api_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProductGroup({
    required String title,
    required IconData icon,
    required List<_ProductMenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _blue.withOpacity(0.09),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 15, color: _blue),
            ),
            const SizedBox(width: 9),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                color: _navy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(_buildProductItem),
      ],
    );
  }

  Widget _buildProductItem(_ProductMenuItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          _removeProductsOverlay();
          Navigator.of(context).pushNamed(item.route);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
          child: Row(
            children: [
              Icon(item.icon, size: 16, color: _blue.withOpacity(0.72)),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _navy,
                  ),
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

  Widget _buildSearchButton({required bool compact}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(compact ? 7 : 9),
          child: Icon(
            Icons.search_rounded,
            size: compact ? 19 : 20,
            color: Colors.white.withOpacity(0.78),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // DESKTOP SIGN IN
  // ===========================================================================

  Widget _buildSignInButton(BuildContext context, {required bool compact}) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/login');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 20,
          vertical: 11,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      child: Text(
        'Sign In',
        style: TextStyle(
          fontFamily: 'SegoeUI',
          fontSize: compact ? 12.5 : 13.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ===========================================================================
  // MOBILE DRAWER
  // ===========================================================================

  void _openMobileDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.55,
          maxChildSize: 0.94,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _navy.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 16, 12),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Explore GiftPay',
                            style: TextStyle(
                              fontFamily: 'SegoeUI',
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: _navy,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: _navy.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
                      children: [
                        _drawerNavItem(
                          sheetContext,
                          label: 'Business',
                          icon: Icons.business_center_outlined,
                          route: '/giftpay-business',
                        ),
                        _drawerNavItem(
                          sheetContext,
                          label: 'Personal',
                          icon: Icons.person_outline_rounded,
                          route: '/personal',
                        ),
                        _drawerProductsSection(sheetContext),
                        _drawerNavItem(
                          sheetContext,
                          label: 'About',
                          icon: Icons.info_outline_rounded,
                          route: '/about_us',
                        ),
                        _drawerNavItem(
                          sheetContext,
                          label: 'Contact',
                          icon: Icons.mail_outline_rounded,
                          route: '/contact_us',
                        ),
                        const SizedBox(height: 14),
                        Divider(color: _navy.withOpacity(0.08)),
                        const SizedBox(height: 10),
                        _drawerNavItem(
                          sheetContext,
                          label: 'Search',
                          icon: Icons.search_rounded,
                          route: null,
                        ),
                        const SizedBox(height: 8),
                        _drawerSignIn(sheetContext),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _drawerProductsSection(BuildContext sheetContext) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: _blue.withOpacity(0.035),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Theme(
        data: Theme.of(sheetContext).copyWith(
          dividerColor: Colors.transparent,
          splashColor: _blue.withOpacity(0.06),
          highlightColor: _blue.withOpacity(0.04),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 10, 10),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.07),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.grid_view_rounded, size: 19, color: _blue),
          ),
          title: const Text(
            'Products',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          iconColor: _blue,
          collapsedIconColor: _navy.withOpacity(0.35),
          children: [
            _drawerProductGroup(
              sheetContext,
              title: 'Utilities',
              icon: Icons.bolt_rounded,
              items: [
                _ProductMenuItem(
                  'Bulk Electricity Tokens',
                  '/bulk-electricity',
                  Icons.bolt_rounded,
                ),
                _ProductMenuItem(
                  'Airtime Distribution',
                  '/airtime-distribution',
                  Icons.phone_android_rounded,
                ),
                _ProductMenuItem(
                  'Corporate Data Plans',
                  '/corporate_data',
                  Icons.wifi_rounded,
                ),
                _ProductMenuItem(
                  'GiftPay Wallet',
                  '/p-wallet',
                  Icons.account_balance_wallet_rounded,
                ),
              ],
            ),

            const SizedBox(height: 10),

            _drawerProductGroup(
              sheetContext,
              title: 'Lifestyle',
              icon: Icons.auto_awesome_rounded,
              items: [
                _ProductMenuItem(
                  'Gift Cards',
                  '/gift-cards',
                  Icons.card_giftcard_rounded,
                ),
                _ProductMenuItem(
                  'Flight Booking',
                  '/aviation-public',
                  Icons.flight_takeoff_rounded,
                ),
                _ProductMenuItem(
                  'GiftPay Personal',
                  '/personal',
                  Icons.person_rounded,
                ),
              ],
            ),

            const SizedBox(height: 10),

            _drawerProductGroup(
              sheetContext,
              title: 'Business',
              icon: Icons.business_center_rounded,
              items: [
                _ProductMenuItem(
                  'Business Dashboard',
                  '/business-dashboard',
                  Icons.dashboard_rounded,
                ),
                _ProductMenuItem('GiftPay API', '/api', Icons.api_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerProductGroup(
    BuildContext sheetContext, {
    required String title,
    required IconData icon,
    required List<_ProductMenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _blue.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 15, color: _blue),
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: _navy,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        ...items.map((item) => _drawerProductItem(sheetContext, item)),
      ],
    );
  }

  Widget _drawerProductItem(BuildContext sheetContext, _ProductMenuItem item) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        Navigator.of(sheetContext).pop();
        Navigator.of(context).pushNamed(item.route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        child: Row(
          children: [
            Icon(item.icon, size: 16, color: _blue.withOpacity(0.72)),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _navy,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 11,
              color: _navy.withOpacity(0.25),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerNavItem(
    BuildContext sheetContext, {
    required String label,
    required IconData icon,
    required String? route,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _blue.withOpacity(0.07),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 19, color: _blue),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _navy,
          ),
        ),
        trailing: Icon(
          route == null
              ? Icons.search_rounded
              : Icons.arrow_forward_ios_rounded,
          size: 13,
          color: _navy.withOpacity(0.30),
        ),
        onTap: () {
          Navigator.of(sheetContext).pop();

          if (route != null) {
            Navigator.of(context).pushNamed(route);
          }
        },
      ),
    );
  }

  Widget _drawerSignIn(BuildContext sheetContext) {
    return Material(
      color: _navy,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.of(sheetContext).pop();
          Navigator.of(context).pushNamed('/login');
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Icon(Icons.login_rounded, color: Colors.white, size: 19),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sign in to your GiftPay account',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white70,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductMenuItem {
  final String title;
  final String route;
  final IconData icon;

  const _ProductMenuItem(this.title, this.route, this.icon);
}
