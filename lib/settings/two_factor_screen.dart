import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class TwoFactorScreen extends StatefulWidget {
  const TwoFactorScreen({super.key});

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  bool smsEnabled = false;
  bool emailEnabled = true; // default recommended
  bool authenticatorEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderr(title: "Two‑Factor Authentication"),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        children: [
          const Text(
            "Enhance your account security by enabling additional verification methods.",
            style: TextStyle(
              color: Color(0xFFE5E7EB),
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 28),

          _sectionTitle("Available Methods"),

          _tile(
            title: "Email Verification",
            subtitle: "A verification code will be sent to your email.",
            value: emailEnabled,
            onChanged: (v) => setState(() => emailEnabled = v),
          ),

          _divider(),

          _tile(
            title: "SMS Verification",
            subtitle: "A code will be sent to your phone number.",
            value: smsEnabled,
            onChanged: (v) => setState(() => smsEnabled = v),
          ),

          _divider(),

          _tile(
            title: "Authenticator App",
            subtitle: "Use Google Authenticator or Authy for 6‑digit codes.",
            value: authenticatorEnabled,
            onChanged: (v) => setState(() => authenticatorEnabled = v),
          ),

          const SizedBox(height: 40),

          _sectionTitle("Recovery Options"),

          _navTile(
            title: "Backup Codes",
            subtitle: "Generate one‑time codes for emergencies.",
            onTap: () {},
          ),

          _divider(),

          _navTile(
            title: "Trusted Devices",
            subtitle: "Manage devices that don’t require 2FA.",
            onTap: () => Navigator.pushNamed(context, "/linked-devices"),
          ),

          const SizedBox(height: 40),

          _sectionTitle("Status"),

          _statusBox(),
        ],
      ),
    );
  }

  // ⭐ SECTION TITLE
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0AC8FF),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ⭐ TOGGLE TILE
  Widget _tile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF0AC8FF),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ⭐ NAVIGATION TILE
  Widget _navTile({
    required String title,
    required String subtitle,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 12.5,
                    ),
                  ),
                ],
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
      color: Colors.white.withOpacity(0.10),
    );
  }

  // ⭐ STATUS BOX
  Widget _statusBox() {
    final enabledCount = [
      emailEnabled,
      smsEnabled,
      authenticatorEnabled,
    ].where((e) => e).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(
            enabledCount > 0 ? Icons.verified_user : Icons.warning_amber,
            color: enabledCount > 0 ? Colors.greenAccent : Colors.orangeAccent,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              enabledCount > 0
                  ? "Your account is protected with $enabledCount active 2FA method(s)."
                  : "Your account is not protected with 2FA.",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
