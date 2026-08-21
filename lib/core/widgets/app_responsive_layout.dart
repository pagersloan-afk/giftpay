import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/sidebar/app_sidebar.dart';

class AppResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double desktopMaxWidth;

  const AppResponsiveLayout({
    super.key,
    required this.child,
    this.desktopMaxWidth = 550,
  });

  bool _isAuthOrLanding(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "";

    // No sidebar on authentication / landing screens.
    return route == "/login" ||
        route == "/signup" ||
        route == "/reset" ||
        route == "/verify";
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // ==============================================================
    // AUTH / LANDING
    // ==============================================================

    if (_isAuthOrLanding(context)) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: child,
        ),
      );
    }

    // ==============================================================
    // DESKTOP WEB / LARGE SCREEN
    //
    // Existing desktop navigation remains exactly the same:
    //
    // AppSidebar → content
    // ==============================================================

    if (width >= desktopMaxWidth + 200) {
      final activeRoute = ModalRoute.of(context)?.settings.name ?? "";

      return Row(
        children: [
          AppSidebar(activeRoute: activeRoute),

          Expanded(
            child: SingleChildScrollView(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 180),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: desktopMaxWidth),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // ==============================================================
    // MOBILE WEB + MOBILE APP
    //
    // Navigation is NOT handled here.
    //
    // The mobile-web Drawer is supplied by HomeScreen using the SAME
    // AppSidebar.
    //
    // Android/iOS continues using the existing HomeShell navigation.
    // ==============================================================

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: child,
      ),
    );
  }
}
