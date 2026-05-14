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

  bool _isAuthScreen() {
    final name = child.runtimeType.toString();
    return name.contains("Login") ||
        name.contains("SignUp") ||
        name.contains("Reset") ||
        name.contains("Verify");
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // ⭐ AUTH SCREENS → Centered card with max width
    if (_isAuthScreen()) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: child,
        ),
      );
    }

    // ⭐ DESKTOP MODE
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

    // ⭐ MOBILE MODE → WIDER LAYOUT (less padding + wider maxWidth)
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 14,
        ), // ⭐ wider
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // ⭐ wider
            child: child,
          ),
        ),
      ),
    );
  }
}
