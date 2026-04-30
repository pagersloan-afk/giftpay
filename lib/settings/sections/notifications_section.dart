import 'package:flutter/material.dart';

class NotificationsSection extends StatelessWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _toggle("Push Notifications", true),
        _toggle("Email Alerts", false),
        _toggle("Transaction Updates", true),
        _toggle("Promotional Offers", false),
        _toggle("Security Alerts", true),
      ],
    );
  }

  Widget _toggle(String label, bool value) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      value: value,
      onChanged: (_) {},
      title: Text(
        label,
        style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 15),
      ),
      activeThumbColor: const Color(0xFF0AC8FF),
      activeTrackColor: const Color(0xFF0AC8FF).withOpacity(0.35),
      inactiveThumbColor: Colors.white70,
      inactiveTrackColor: Colors.white24,
    );
  }
}
