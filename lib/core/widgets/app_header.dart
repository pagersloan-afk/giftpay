import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utilityhub/core/widgets/app_header/header_container.dart';
import 'package:utilityhub/core/widgets/app_header/header_logo.dart';
import 'package:utilityhub/core/widgets/app_header/header_nav_links.dart';
import 'package:utilityhub/core/widgets/app_header/header_notifications.dart';
import 'package:utilityhub/core/widgets/app_header/header_profile_dropdown.dart';
import 'package:utilityhub/core/widgets/app_header/header_wallet.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isLoggedIn = user != null;

    return HeaderContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LEFT SIDE
          isMobile
              ? HeaderProfileDropdown(photoUrl: user?.photoURL)
              : const HeaderLogo(),

          // RIGHT SIDE
          Row(
            children: [
              // Desktop navigation links (About / Contact)
              HeaderNavLinks(showLinks: !isMobile && !isLoggedIn),

              // Desktop wallet balance
              HeaderWallet(showWallet: !isMobile && isLoggedIn),

              const SizedBox(width: 14),

              // Notification bell (always visible)
              const HeaderNotifications(),

              const SizedBox(width: 14),

              // ⭐ MOBILE ONLY → PROFILE AVATAR
              if (isMobile && isLoggedIn)
                HeaderProfileDropdown(photoUrl: user?.photoURL),
            ],
          ),
        ],
      ),
    );
  }
}
