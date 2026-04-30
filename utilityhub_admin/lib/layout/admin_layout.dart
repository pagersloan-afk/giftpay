import 'package:flutter/material.dart';
import '../pages/dashboard_page.dart';
import '../pages/giftcard_trades_page.dart';
import '../pages/kyc_admin_page.dart'; // ⭐ NEW IMPORT

class AdminLayout extends StatefulWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int selectedIndex = 0;

  // ⭐ Updated pages list with KYC Admin Page
  final List<Widget> pages = const [
    DashboardPage(), // index 0
    GiftCardTradesPage(), // index 1
    Placeholder(), // index 2 - Rates
    Placeholder(), // index 3 - Users
    Placeholder(), // index 4 - Transactions
    KycAdminPage(), // index 5 - ⭐ NEW KYC PAGE
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            color: Colors.blue.shade900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "UtilityHub Admin",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // ⭐ Updated menu items with KYC Verification
                _menuItem("Dashboard", Icons.dashboard, 0),
                _menuItem("Gift Card Trades", Icons.card_giftcard, 1),
                _menuItem("Rates", Icons.price_change, 2),
                _menuItem("Users", Icons.people, 3),
                _menuItem("Transactions", Icons.receipt_long, 4),
                _menuItem("KYC Verification", Icons.verified_user, 5), // ⭐ NEW
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: pages[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(String title, IconData icon, int index) {
    final bool active = selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() => selectedIndex = index);
      },
      child: Container(
        color: active ? Colors.blue.shade700 : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
