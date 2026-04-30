import 'package:flutter/material.dart';

class SupportLegalSection extends StatelessWidget {
  const SupportLegalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _item("Help Center"),
        _divider(),
        _item("Contact Support"),
        _divider(),
        _item("Terms of Service"),
        _divider(),
        _item("Privacy Policy"),
      ],
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
