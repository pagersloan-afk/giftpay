import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsSection extends StatefulWidget {
  const NotificationsSection({super.key});

  @override
  State<NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<NotificationsSection> {
  bool pushNotifications = true;
  bool emailAlerts = false;
  bool transactionUpdates = true;
  bool promotionalOffers = false;
  bool securityAlerts = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      pushNotifications = prefs.getBool("push_notifications") ?? true;
      emailAlerts = prefs.getBool("email_alerts") ?? false;
      transactionUpdates = prefs.getBool("transaction_updates") ?? true;
      promotionalOffers = prefs.getBool("promotional_offers") ?? false;
      securityAlerts = prefs.getBool("security_alerts") ?? true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _toggle("Push Notifications", pushNotifications, (v) {
          setState(() => pushNotifications = v);
          _savePreference("push_notifications", v);
        }),
        _toggle("Email Alerts", emailAlerts, (v) {
          setState(() => emailAlerts = v);
          _savePreference("email_alerts", v);
        }),
        _toggle("Transaction Updates", transactionUpdates, (v) {
          setState(() => transactionUpdates = v);
          _savePreference("transaction_updates", v);
        }),
        _toggle("Promotional Offers", promotionalOffers, (v) {
          setState(() => promotionalOffers = v);
          _savePreference("promotional_offers", v);
        }),
        _toggle("Security Alerts", securityAlerts, (v) {
          setState(() => securityAlerts = v);
          _savePreference("security_alerts", v);
        }),
      ],
    );
  }

  Widget _toggle(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      value: value,
      onChanged: onChanged,
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
