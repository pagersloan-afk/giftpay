import 'package:flutter/material.dart';

class PreferencesSection extends StatefulWidget {
  const PreferencesSection({super.key});

  @override
  State<PreferencesSection> createState() => _PreferencesSectionState();
}

class _PreferencesSectionState extends State<PreferencesSection> {
  bool darkMode = true;
  bool systemTheme = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _toggle(
          label: "Dark Mode",
          value: darkMode,
          onChanged: (v) {
            setState(() => darkMode = v);

            // ⭐ If user enables system theme, disable manual dark mode
            if (systemTheme && v) {
              setState(() => systemTheme = false);
            }
          },
        ),

        _toggle(
          label: "Use System Theme",
          value: systemTheme,
          onChanged: (v) {
            setState(() => systemTheme = v);

            // ⭐ If system theme is enabled, disable manual dark mode
            if (v) setState(() => darkMode = false);
          },
        ),

        _divider(),

        _item(
          label: "Currency Display",
          onTap: () => Navigator.pushNamed(context, "/currency-display"),
        ),

        _divider(),

        _item(
          label: "Language",
          onTap: () => Navigator.pushNamed(context, "/language"),
        ),

        _divider(),

        _item(
          label: "Quick Actions Customization",
          onTap: () => Navigator.pushNamed(context, "/quick-actions"),
        ),
      ],
    );
  }

  // ⭐ TOGGLE ITEM
  Widget _toggle({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      value: value,
      onChanged: onChanged,
      title: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFE5E7EB),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      activeThumbColor: const Color(0xFF0AC8FF),
      activeTrackColor: const Color(0xFF0AC8FF).withOpacity(0.35),
      inactiveThumbColor: Colors.white70,
      inactiveTrackColor: Colors.white24,
    );
  }

  // ⭐ NAVIGATION ITEM
  Widget _item({required String label, required VoidCallback onTap}) {
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
                style: const TextStyle(
                  color: Color(0xFFE5E7EB),
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

  // ⭐ DIVIDER
  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: const Color(0xFF0AC8FF).withOpacity(0.18),
    );
  }
}
