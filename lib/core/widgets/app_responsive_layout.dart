import 'package:flutter/material.dart';

import 'package:utilityhub/core/widgets/sidebar/app_sidebar.dart';
import 'package:utilityhub/core/widgets/responsive/responsive_content_width.dart';

class AppResponsiveLayout extends StatelessWidget {
  final Widget child;

  const AppResponsiveLayout({super.key, required this.child});

  bool _isAuthOrLanding(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "";

    return route == "/login" ||
        route == "/signup" ||
        route == "/reset" ||
        route == "/verify";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
    // DESKTOP / TABLET WEB
    // ==============================================================

    if (screenWidth >= 750) {
      final activeRoute = ModalRoute.of(context)?.settings.name ?? "";

      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ----------------------------------------------------------
          // DESKTOP SIDEBAR
          // ----------------------------------------------------------
          AppSidebar(activeRoute: activeRoute),

          // ----------------------------------------------------------
          // RESPONSIVE APPLICATION BODY
          //
          // The body is intentionally biased toward the sidebar
          // rather than mathematically centered.
          // ----------------------------------------------------------
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
