import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AccountSecuritySection extends StatelessWidget {
  const AccountSecuritySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _item(
          label: "Profile Information",
          onTap: () => Navigator.pushNamed(context, "/profile"),
        ),
        _divider(),

        // ⭐ NEW — Authorization PIN
        _item(
          label: "Authorization PIN",
          onTap: () => Navigator.pushNamed(context, "/auth-pin"),
        ),
        _divider(),

        // ⭐ NEW — Login & Security
        _item(
          label: "Login & Security",
          onTap: () => Navigator.pushNamed(context, "/login-security"),
        ),
        _divider(),

        // ⭐ NEW — Device Login
        _item(
          label: "Device Login",
          onTap: () => Navigator.pushNamed(context, "/linked-devices"),
        ),
        _divider(),

        // ⭐ NEW — Statements
        _item(
          label: "Statements",
          onTap: () => Navigator.pushNamed(context, "/statement"),
        ),
        _divider(),

        // ⭐ NEW — Limits
        _item(
          label: "Limits",
          onTap: () => Navigator.pushNamed(context, "/limits"),
        ),
        _divider(),

        _item(
          label: "Change Password",
          onTap: () => Navigator.pushNamed(context, "/change-password"),
        ),
        _divider(),

        _item(
          label: "Two‑Factor Authentication",
          onTap: () => Navigator.pushNamed(context, "/2fa"),
        ),
        _divider(),

        _item(
          label: "Linked Devices",
          onTap: () => Navigator.pushNamed(context, "/linked-devices"),
        ),
        _divider(),

        _item(
          label: "Logout",
          isDestructive: true,
          onTap: () => _confirmLogout(context),
        ),
      ],
    );
  }

  Widget _item({
    required String label,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDestructive
                      ? Colors.redAccent
                      : const Color(0xFFE5E7EB),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: const Color(0xFF0AC8FF).withOpacity(0.18),
    );
  }

  void _confirmLogout(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        message: const Text("Are you sure you want to logout?"),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/login",
                (_) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ),
    );
  }
}
