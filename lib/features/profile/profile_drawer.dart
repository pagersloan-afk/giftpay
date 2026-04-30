import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: Colors.black, // premium dark base
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⭐ Premium avatar container
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4FC3F7).withOpacity(0.20),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white12,
                    child: Icon(Icons.person, size: 50, color: Colors.white70),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ⭐ Email
              Center(
                child: Text(
                  user?.email ?? "User",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ⭐ Menu items
              _drawerItem(
                icon: Icons.account_balance_wallet,
                label: "Wallet",
                onTap: () => Navigator.pushNamed(context, "/wallet"),
              ),
              _drawerItem(
                icon: Icons.settings,
                label: "Settings",
                onTap: () => Navigator.pushNamed(context, "/settings"),
              ),
              _drawerItem(
                icon: Icons.history,
                label: "Transaction History",
                onTap: () => Navigator.pushNamed(context, "/transactions"),
              ),
              _drawerItem(
                icon: Icons.support_agent,
                label: "Support",
                onTap: () => Navigator.pushNamed(context, "/support"),
              ),

              const Spacer(),

              // ⭐ Logout
              _drawerItem(
                icon: Icons.logout,
                label: "Logout",
                color: Colors.redAccent,
                onTap: () => logout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ⭐ Premium drawer item
  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = const Color(0xFFE5E7EB),
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
