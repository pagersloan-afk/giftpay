import 'package:flutter/material.dart';
import 'sidebar_user_header.dart';
import 'sidebar_item.dart';

class AppSidebar extends StatelessWidget {
  final String activeRoute;

  const AppSidebar({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,

      // ⭐ GP‑1 TRANSPARENT SIDEBAR CONTAINER
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04), // transparent glass
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.08), // soft border
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF4FC3F7,
            ).withOpacity(0.08), // subtle cyan glow
            blurRadius: 18,
            offset: const Offset(2, 0),
          ),
        ],
      ),

      child: Scrollbar(
        thumbVisibility: true,
        thickness: 6,
        radius: const Radius.circular(8),

        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            const SidebarUserHeader(),
            const SizedBox(height: 24),

            // ⭐ MAIN SECTION
            _sectionLabel("Main"),
            SidebarItem(
              icon: Icons.dashboard_outlined,
              label: "Dashboard",
              route: "/home",
              activeRoute: activeRoute,
            ),
            SidebarItem(
              icon: Icons.phone_android,
              label: "Buy Airtime",
              route: "/airtime",
              activeRoute: activeRoute,
            ),
            SidebarItem(
              icon: Icons.data_usage,
              label: "Buy Data",
              route: "/data",
              activeRoute: activeRoute,
            ),
            SidebarItem(
              icon: Icons.flash_on,
              label: "Electricity",
              route: "/electricity",
              activeRoute: activeRoute,
            ),
            SidebarItem(
              icon: Icons.tv,
              label: "Cable TV",
              route: "/cable",
              activeRoute: activeRoute,
            ),
            SidebarItem(
              icon: Icons.receipt_long,
              label: "Transactions",
              route: "/transactions",
              activeRoute: activeRoute,
            ),

            const SizedBox(height: 28),
            _divider(),

            // ⭐ FINTECH SECTION
            const SizedBox(height: 20),
            _sectionLabel("Fintech"),
            SidebarItem(
              icon: Icons.account_balance_wallet_outlined,
              label: "Virtual Accounts",
              route: "/virtual-accounts",
              activeRoute: activeRoute,
            ),
            SidebarItem(
              icon: Icons.card_giftcard,
              label: "Gift Cards",
              route: "/giftcards",
              activeRoute: activeRoute,
            ),
            SidebarItem(
              icon: Icons.sports_soccer,
              label: "Betting",
              route: "/betting",
              activeRoute: activeRoute,
            ),

            const SizedBox(height: 28),
            _divider(),

            // ⭐ ACCOUNT SECTION
            const SizedBox(height: 20),
            _sectionLabel("Account"),
            SidebarItem(
              icon: Icons.support_agent,
              label: "Support",
              route: "/support",
              activeRoute: activeRoute,
            ),
            SidebarItem(
              icon: Icons.settings_outlined,
              label: "Settings",
              route: "/settings",
              activeRoute: activeRoute,
            ),
            SidebarItem(
              icon: Icons.logout,
              label: "Logout",
              route: "/logout",
              activeRoute: activeRoute,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ PREMIUM GP‑1 SECTION LABEL
  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.45),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3, // premium spacing
        ),
      ),
    );
  }

  // ⭐ SOFT ACCENT DIVIDER
  Widget _divider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white.withOpacity(0.06), // soft accent line
    );
  }
}
