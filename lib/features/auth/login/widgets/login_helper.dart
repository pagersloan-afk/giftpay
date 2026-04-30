import 'package:flutter/material.dart';

/// This wrapper ensures the LoginScreen keeps its full-width desktop layout.
/// It completely bypasses AppResponsiveLayout.
class LoginResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const LoginResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;

        // Desktop → allow full width
        if (isDesktop) {
          return child;
        }

        // Mobile → full width (same as before)
        return child;
      },
    );
  }
}
