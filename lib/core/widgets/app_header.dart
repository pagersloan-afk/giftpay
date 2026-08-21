import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:utilityhub/core/widgets/app_header/header_container.dart';
import 'package:utilityhub/core/widgets/app_header/header_logo.dart';
import 'package:utilityhub/core/widgets/app_header/header_nav_links.dart';
import 'package:utilityhub/core/widgets/app_header/header_notifications.dart';
import 'package:utilityhub/core/widgets/app_header/header_profile_dropdown.dart';
import 'package:utilityhub/core/widgets/app_header/header_wallet.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool mobileWeb;
  final VoidCallback? onMenuTap;

  const AppHeader({super.key, this.mobileWeb = false, this.onMenuTap});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isLoggedIn = user != null;

    if (mobileWeb) {
      return HeaderContainer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (onMenuTap != null) {
                  onMenuTap!.call();
                  return;
                }
                final scaffoldState = Scaffold.maybeOf(context);
                if (scaffoldState != null) {
                  scaffoldState.openDrawer();
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.10),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const HeaderNotifications(),
                const SizedBox(width: 16),
                if (isLoggedIn)
                  HeaderProfileDropdown(
                    photoUrl: user?.photoURL,
                    alignRight: true,
                  ),
              ],
            ),
          ],
        ),
      );
    }

    if (isMobile) {
      return HeaderContainer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HeaderProfileDropdown(photoUrl: user?.photoURL),
            const Row(children: [HeaderNotifications()]),
          ],
        ),
      );
    }

    return HeaderContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const HeaderLogo(),
          Row(
            children: [
              HeaderNavLinks(showLinks: !isLoggedIn),
              HeaderWallet(showWallet: isLoggedIn),
              const SizedBox(width: 14),
              const HeaderNotifications(),
              const SizedBox(width: 14),
              if (isLoggedIn)
                HeaderProfileDropdown(
                  photoUrl: user?.photoURL,
                  alignRight: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
