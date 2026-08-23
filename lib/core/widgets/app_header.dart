import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_header/header_logo.dart';
import 'app_header/header_nav_links.dart';
import 'app_header/header_notifications.dart';
import 'app_header/header_profile_dropdown.dart';
import 'app_header/header_wallet.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool mobileWeb;
  final VoidCallback? onMenuTap;

  const AppHeader({super.key, this.mobileWeb = false, this.onMenuTap});

  // ===========================================================================
  // GIFTPAY AUTHENTICATED DARK SYSTEM
  // ===========================================================================
  //
  // These colors are intentionally different from the public/landing header.
  //
  // GiftPayBackground:
  //   #05070A
  //   #0A0D12
  //
  // GiftPayTheme:
  //   headerDark  #0F1115
  //   primaryBlue #0A4D9C
  //   headerAccent #4FC3F7
  //
  // The authenticated header therefore uses #0F1115 as its dominant surface.
  // ===========================================================================

  static const Color headerDark = Color(0xFF0F1115);
  static const Color deepBackground = Color(0xFF05070A);
  static const Color backgroundBlend = Color(0xFF0A0D12);

  static const Color primaryBlue = Color(0xFF0A4D9C);
  static const Color headerAccent = Color(0xFF4FC3F7);

  static const Color surface = Color(0xFF101827);

  @override
  Size get preferredSize => const Size.fromHeight(72);

  void _openMenu(BuildContext context) {
    if (onMenuTap != null) {
      onMenuTap!.call();
      return;
    }

    final scaffoldState = Scaffold.maybeOf(context);

    if (scaffoldState != null) {
      scaffoldState.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final width = MediaQuery.sizeOf(context).width;

    final isMobile = width < 700;
    final isTablet = width >= 700 && width < 1050;
    final isLoggedIn = user != null;

    // =========================================================================
    // MOBILE WEB
    // =========================================================================

    if (mobileWeb || isMobile) {
      return _DarkHeaderContainer(
        child: Row(
          children: [
            HeaderLogo(compact: true, showWordmark: !isMobile),

            const Spacer(),

            if (isLoggedIn) ...[
              const HeaderWallet(compact: true),
              const SizedBox(width: 8),
            ],

            const HeaderNotifications(),

            const SizedBox(width: 8),

            if (isLoggedIn)
              HeaderProfileDropdown(
                photoUrl: user?.photoURL,
                alignRight: true,
                compact: true,
              ),

            const SizedBox(width: 8),

            GestureDetector(
              onTap: () => _openMenu(context),
              behavior: HitTestBehavior.opaque,
              child: const _HeaderActionButton(icon: Icons.menu_rounded),
            ),
          ],
        ),
      );
    }

    // =========================================================================
    // TABLET
    // =========================================================================

    if (isTablet) {
      return _DarkHeaderContainer(
        child: Row(
          children: [
            const HeaderLogo(),

            const Spacer(),

            if (isLoggedIn) ...[
              const HeaderWallet(compact: true),
              const SizedBox(width: 10),
            ],

            const HeaderNotifications(),

            const SizedBox(width: 10),

            if (isLoggedIn)
              HeaderProfileDropdown(photoUrl: user?.photoURL, alignRight: true),

            const SizedBox(width: 8),

            GestureDetector(
              onTap: () => _openMenu(context),
              behavior: HitTestBehavior.opaque,
              child: const _HeaderActionButton(icon: Icons.menu_rounded),
            ),
          ],
        ),
      );
    }

    // =========================================================================
    // DESKTOP
    // =========================================================================

    return _DarkHeaderContainer(
      child: Row(
        children: [
          const HeaderLogo(),

          const SizedBox(width: 30),

          Expanded(child: HeaderNavLinks(showLinks: isLoggedIn)),

          const SizedBox(width: 18),

          if (isLoggedIn) ...[const HeaderWallet(), const SizedBox(width: 12)],

          const HeaderNotifications(),

          const SizedBox(width: 12),

          if (isLoggedIn)
            HeaderProfileDropdown(photoUrl: user?.photoURL, alignRight: true),
        ],
      ),
    );
  }
}

// =============================================================================
// DARK AUTHENTICATED HEADER CONTAINER
// =============================================================================
//
// This replaces the old HeaderContainer for AppHeader.
//
// IMPORTANT:
// We deliberately do NOT use #273D68 here.
// That color belongs to the public GiftPay brand treatment.
//
// The authenticated dashboard uses:
//   #0F1115 → header
//   #05070A → deepest background
//   #0A0D12 → background blend
//   #0A4D9C → primary blue
//   #4FC3F7 → cyan accent
//
// =============================================================================

class _DarkHeaderContainer extends StatelessWidget {
  final Widget child;

  const _DarkHeaderContainer({required this.child});

  static const Color headerDark = Color(0xFF0F1115);
  static const Color deepBackground = Color(0xFF05070A);
  static const Color backgroundBlend = Color(0xFF0A0D12);

  static const Color primaryBlue = Color(0xFF0A4D9C);
  static const Color headerAccent = Color(0xFF4FC3F7);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final horizontalPadding = width < 700
        ? 14.0
        : width < 1050
        ? 22.0
        : 30.0;

    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          // =========================================================================
          // DARK HEADER SURFACE
          // =========================================================================
          //
          // Almost black, with only a very subtle blue lift toward the right.
          //
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F1115), Color(0xFF0D121B), Color(0xFF0A0D12)],
          ),

          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.075),
              width: 1,
            ),
          ),

          boxShadow: [
            // Deep separation from dashboard
            BoxShadow(
              color: Colors.black.withOpacity(0.42),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),

            // Very subtle GiftPay blue ambient glow
            BoxShadow(
              color: primaryBlue.withOpacity(0.075),
              blurRadius: 32,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRect(
          child: Stack(
            children: [
              // =======================================================================
              // LEFT BLUE AMBIENT GLOW
              // =======================================================================
              Positioned(
                left: -120,
                top: -150,
                child: IgnorePointer(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryBlue.withOpacity(0.075),
                    ),
                  ),
                ),
              ),

              // =======================================================================
              // RIGHT CYAN AMBIENT GLOW
              // =======================================================================
              Positioned(
                right: -120,
                top: -170,
                child: IgnorePointer(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: headerAccent.withOpacity(0.035),
                    ),
                  ),
                ),
              ),

              // =======================================================================
              // SUBTLE INNER HIGHLIGHT
              // =======================================================================
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          headerAccent.withOpacity(0.10),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // =======================================================================
              // HEADER CONTENT
              // =======================================================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MOBILE / TABLET MENU BUTTON
// =============================================================================

class _HeaderActionButton extends StatefulWidget {
  final IconData icon;

  const _HeaderActionButton({required this.icon});

  @override
  State<_HeaderActionButton> createState() => _HeaderActionButtonState();
}

class _HeaderActionButtonState extends State<_HeaderActionButton> {
  bool _hovered = false;

  static const Color primaryBlue = Color(0xFF0A4D9C);
  static const Color headerAccent = Color(0xFF4FC3F7);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
      },
      onExit: (_) {
        setState(() => _hovered = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _hovered
              ? Colors.white.withOpacity(0.085)
              : Colors.white.withOpacity(0.045),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: _hovered
                ? headerAccent.withOpacity(0.22)
                : Colors.white.withOpacity(0.085),
          ),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(_hovered ? 0.18 : 0.055),
              blurRadius: _hovered ? 20 : 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          widget.icon,
          color: Colors.white.withOpacity(0.94),
          size: 22,
        ),
      ),
    );
  }
}
