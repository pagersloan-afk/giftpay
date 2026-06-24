import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class QuickActionsCustomizationScreen extends StatefulWidget {
  const QuickActionsCustomizationScreen({super.key});

  @override
  State<QuickActionsCustomizationScreen> createState() =>
      _QuickActionsCustomizationScreenState();
}

class _QuickActionsCustomizationScreenState
    extends State<QuickActionsCustomizationScreen> {
  List<String> actions = [
    "Transfer",
    "Fund Wallet",
    "Airtime",
    "Electricity",
    "Betting",
    "Data",
  ];

  List<String> enabled = [];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    enabled =
        prefs.getStringList("quick_actions") ?? ["Transfer", "Fund Wallet"];
    setState(() {});
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("quick_actions", enabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderr(title: "Quick Actions"),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        children: [
          const Text(
            "Choose which actions appear in your floating Quick Actions button.",
            style: TextStyle(
              color: Color(0xFFE5E7EB),
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          ...actions.map((action) => _toggle(action)).toList(),

          const SizedBox(height: 40),

          _previewFAB(),
        ],
      ),
    );
  }

  Widget _toggle(String label) {
    final isEnabled = enabled.contains(label);

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      value: isEnabled,
      onChanged: (v) {
        setState(() {
          if (v) {
            enabled.add(label);
          } else {
            enabled.remove(label);
          }
        });
        _savePrefs();
      },
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

  Widget _previewFAB() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app, color: Colors.white70, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Preview: ${enabled.join(", ")}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
