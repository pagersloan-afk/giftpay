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
    // DESKTOP
    // ==============================================================

    if (width >= desktopMaxWidth + 200) {
      final activeRoute = ModalRoute.of(context)?.settings.name ?? "";

      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSidebar(activeRoute: activeRoute),

          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 180),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: desktopMaxWidth),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // ==============================================================
    // MOBILE / SMALL WEB
    //
    // IMPORTANT:
    // Do NOT wrap child in SingleChildScrollView here.
    // The individual screen handles its own scrolling.
    // ==============================================================

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: child,
      ),
    );
  }
}
