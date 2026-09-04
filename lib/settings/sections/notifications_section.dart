import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // ============================================================
  // LOAD PREFERENCES
  // ============================================================

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final user = FirebaseAuth.instance.currentUser;

      bool loadedEmailAlerts = prefs.getBool("email_alerts") ?? false;

      bool loadedTransactionUpdates =
          prefs.getBool("transaction_updates") ?? true;

      // ----------------------------------------------------------
      // Prefer Firestore values when available.
      // ----------------------------------------------------------

      if (user != null) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .get();

          final data = doc.data();

          if (data != null) {
            if (data["emailAlerts"] is bool) {
              loadedEmailAlerts = data["emailAlerts"] as bool;
            }

            if (data["transactionUpdates"] is bool) {
              loadedTransactionUpdates = data["transactionUpdates"] as bool;
            }
          }
        } catch (e) {
          debugPrint(
            "⚠️ Could not load notification preferences from Firestore: $e",
          );
        }
      }

      if (!mounted) return;

      setState(() {
        pushNotifications = prefs.getBool("push_notifications") ?? true;

        emailAlerts = loadedEmailAlerts;

        transactionUpdates = loadedTransactionUpdates;

        promotionalOffers = prefs.getBool("promotional_offers") ?? false;

        securityAlerts = prefs.getBool("security_alerts") ?? true;

        _loading = false;
      });

      // ----------------------------------------------------------
      // Keep Firestore synchronized.
      // ----------------------------------------------------------

      if (user != null) {
        await _saveFirestorePreferences(
          emailAlerts: loadedEmailAlerts,
          transactionUpdates: loadedTransactionUpdates,
        );
      }
    } catch (e) {
      debugPrint("❌ Error loading notification preferences: $e");

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // SAVE LOCAL PREFERENCE
  // ============================================================

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(key, value);
  }

  // ============================================================
  // SAVE FIRESTORE NOTIFICATION PREFERENCES
  // ============================================================

  Future<void> _saveFirestorePreferences({
    required bool emailAlerts,
    required bool transactionUpdates,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "emailAlerts": emailAlerts,
        "transactionUpdates": transactionUpdates,
      }, SetOptions(merge: true));

      debugPrint("✅ Notification preferences saved to Firestore");
    } catch (e) {
      debugPrint("❌ Failed to save notification preferences: $e");
    }
  }

  // ============================================================
  // EMAIL ALERTS
  // ============================================================

  Future<void> _setEmailAlerts(bool value) async {
    setState(() {
      emailAlerts = value;
    });

    await _savePreference("email_alerts", value);

    await _saveFirestorePreferences(
      emailAlerts: value,
      transactionUpdates: transactionUpdates,
    );
  }

  // ============================================================
  // TRANSACTION UPDATES
  // ============================================================

  Future<void> _setTransactionUpdates(bool value) async {
    setState(() {
      transactionUpdates = value;
    });

    await _savePreference("transaction_updates", value);

    await _saveFirestorePreferences(
      emailAlerts: emailAlerts,
      transactionUpdates: value,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        // --------------------------------------------------------
        // PUSH NOTIFICATIONS
        // --------------------------------------------------------
        _toggle("Push Notifications", pushNotifications, (value) {
          setState(() {
            pushNotifications = value;
          });

          _savePreference("push_notifications", value);
        }),

        // --------------------------------------------------------
        // EMAIL ALERTS
        // --------------------------------------------------------
        _toggle("Email Alerts", emailAlerts, (value) {
          _setEmailAlerts(value);
        }),

        // --------------------------------------------------------
        // TRANSACTION UPDATES
        // --------------------------------------------------------
        _toggle("Transaction Updates", transactionUpdates, (value) {
          _setTransactionUpdates(value);
        }),

        // --------------------------------------------------------
        // PROMOTIONAL OFFERS
        // --------------------------------------------------------
        _toggle("Promotional Offers", promotionalOffers, (value) {
          setState(() {
            promotionalOffers = value;
          });

          _savePreference("promotional_offers", value);
        }),

        // --------------------------------------------------------
        // SECURITY ALERTS
        // --------------------------------------------------------
        _toggle("Security Alerts", securityAlerts, (value) {
          setState(() {
            securityAlerts = value;
          });

          _savePreference("security_alerts", value);
        }),
      ],
    );
  }

  // ============================================================
  // TOGGLE WIDGET
  // ============================================================

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
