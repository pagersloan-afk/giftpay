import 'package:flutter/material.dart';

import 'package:utilityhub/core/widgets/sidebar/app_sidebar.dart';
import 'package:utilityhub/core/widgets/responsive/responsive_content_width.dart';

class AppResponsiveLayout extends StatelessWidget {
  final Widget child;

  const AppResponsiveLayout({super.key, required this.child});

  bool _isAuthOrLanding(String route) {
    return route == "/login" ||
        route == "/signup" ||
        route == "/reset" ||
        route == "/verify";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final route = ModalRoute.of(context)?.settings.name ?? "";

    // ==============================================================
    // AUTH / LANDING
    // ==============================================================

    if (_isAuthOrLanding(route)) {
      final isSignup = route == "/signup";
      final maxWidth = isSignup && screenWidth >= 750 ? 860.0 : 420.0;

      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      );
    }

    // ==============================================================
    // DESKTOP / TABLET WEB
    // ==============================================================

    if (screenWidth >= 750) {
      final activeRoute = route;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSidebar(activeRoute: activeRoute),

          Expanded(
            child: Align(
              alignment: const Alignment(-0.18, -1.0),
              child: ResponsiveContentWidth(child: child),
            ),
          ),
        ],
      );
    }

    // ==============================================================
    // MOBILE / SMALL WEB
    // ==============================================================

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: child,
      ),
    );
  }
}
