import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/sidebar/app_sidebar.dart';

class AppResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double desktopMaxWidth;

  const AppResponsiveLayout({
    super.key,
    required this.child,
    this.desktopMaxWidth = 640,
  });

  bool _isAuthOrLanding(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "";

    // ⭐ NO SIDEBAR ON AUTH SCREENS OR LANDING PAGE
    return route == "/login" ||
        route == "/signup" ||
        route == "/reset" ||
        route == "/verify" ||
        route == "/home"; // ⭐ landing page must NOT show sidebar
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // ⭐ AUTH + LANDING → NO SIDEBAR
    if (_isAuthOrLanding(context)) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: child,
        ),
      );
    }

    // ⭐ DESKTOP MODE → SIDEBAR + CONTENT
    if (width >= desktopMaxWidth + 200) {
      return Row(
        children: [
          AppSidebar(activeRoute: ModalRoute.of(context)!.settings.name ?? ""),
          Expanded(
            child: SingleChildScrollView(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 140),
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

    // ⭐ MOBILE MODE → FULL WIDTH
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: child,
      ),
    );
  }
}
