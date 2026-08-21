import 'package:flutter/material.dart';

import 'login_card.dart';

class LoginMobileLayout extends StatelessWidget {
  const LoginMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final double screenHeight = mediaQuery.size.height;

    final double keyboardHeight = mediaQuery.viewInsets.bottom;

    final double availableHeight = screenHeight - keyboardHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: 24 + keyboardHeight,
          ),

          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: availableHeight > 0 ? availableHeight - 44 : 0,
            ),

            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),

                child: const LoginCard(),
              ),
            ),
          ),
        );
      },
    );
  }
}
