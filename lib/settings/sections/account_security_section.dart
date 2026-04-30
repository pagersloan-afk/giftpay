import 'package:flutter/material.dart';

class AccountSecuritySection extends StatelessWidget {
  const AccountSecuritySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _item("Profile Information"),
        _divider(),
        _item("Change Password"),
        _divider(),
        _item("Two‑Factor Authentication"),
        _divider(),
        _item("Linked Devices"),
        _divider(),
        _item("Logout", isDestructive: true),
      ],
    );
  }

  Widget _item(String label, {bool isDestructive = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : const Color(0xFFE5E7EB),
          fontSize: 15,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white54,
        size: 20,
      ),
      onTap: () {},
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: const Color(0xFF0AC8FF).withOpacity(0.18));
  }
}
