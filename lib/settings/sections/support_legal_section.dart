import 'package:flutter/material.dart';

class SupportLegalSection extends StatelessWidget {
  const SupportLegalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _item(context, "Help Center", "/help-center"),
        _divider(),
        _item(context, "Contact Support", "/contact-support"),
        _divider(),
        _item(context, "Terms of Service", "/terms"),
        _divider(),
        _item(context, "Privacy Policy", "/privacy"),
        _divider(),
        _item(context, "Refund Policy", "/refund-policy"),
        _divider(),
        _item(context, "Cookie Policy", "/cookie-policy"),
        _divider(),
        _item(context, "User Agreement", "/user-agreement"),
        _divider(),
        _item(context, "KYC / AML Compliance", "/kyc-aml"),
      ],
    );
  }

  Widget _item(BuildContext context, String label, String route) {
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
      onTap: () => Navigator.pushNamed(context, route),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: const Color(0xFF0AC8FF).withOpacity(0.18));
  }
}
