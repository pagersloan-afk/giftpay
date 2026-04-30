import 'package:flutter/material.dart';

class PreferencesSection extends StatelessWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _toggle("Dark Mode", true),
        _toggle("Use System Theme", false),
        _divider(),
        _item("Currency Display"),
        _divider(),
        _item("Language"),
        _divider(),
        _item("Quick Actions Customization"),
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

  Widget _item(String label) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        label,
        style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 15),
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
