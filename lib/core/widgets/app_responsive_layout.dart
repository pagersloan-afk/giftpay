import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/sidebar/app_sidebar.dart';

class AppResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const AppResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth = 640,
  });

  bool _isLoginScreen() {
    return child.runtimeType.toString() == "LoginScreen";
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > maxWidth + 200;

        if (_isLoginScreen()) {
          return child;
        }

        if (isDesktop) {
          return Row(
            children: [
              AppSidebar(
                activeRoute: ModalRoute.of(context)!.settings.name ?? "",
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 140),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return child;
      },
    );
  }
}
