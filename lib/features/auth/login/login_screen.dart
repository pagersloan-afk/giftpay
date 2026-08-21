import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:utilityhub/core/widgets/giftpay_background.dart';
import 'package:utilityhub/features/landing/widgets/landing_header.dart';

import 'sections/login_desktop_layout.dart';
import 'sections/login_mobile_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // =========================================================================
    // NATIVE MOBILE APP
    //
    // Keep the mobile app focused on the login card.
    // =========================================================================

    if (!kIsWeb) {
      return const GiftPayBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: SafeArea(child: LoginMobileLayout()),
        ),
      );
    }

    // =========================================================================
    // WEB
    //
    // The header remains on the web.
    //
    // Mobile/tablet:
    //   LoginMobileLayout manages its own scrolling.
    //
    // Desktop:
    //   Desktop login is placed inside a SingleChildScrollView.
    //
    // This avoids the previous nested-scroll arrangement that could cause
    // mobile-web login viewport/keyboard issues.
    // =========================================================================

    return GiftPayBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,

        appBar: const LandingHeader(),

        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth > 900;

            // =================================================================
            // MOBILE / TABLET WEB
            // =================================================================

            if (!isDesktop) {
              return FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: const LoginMobileLayout(),
                ),
              );
            }

            // =================================================================
            // DESKTOP WEB
            // =================================================================

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),

              child: FadeTransition(
                opacity: _fade,

                child: SlideTransition(
                  position: _slide,

                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.08),
                            blurRadius: 40,
                            spreadRadius: 4,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),

                      child: const LoginDesktopLayout(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
