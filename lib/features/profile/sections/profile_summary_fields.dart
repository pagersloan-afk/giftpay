import 'package:flutter/material.dart';

class ProfileSummaryFields extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProfileSummaryFields({super.key, required this.data});

  String _displayName() {
    final savedName = data['name'];
    if (savedName is String && savedName.trim().isNotEmpty) {
      return savedName.trim();
    }

    final firstName = data['firstName'] is String
        ? (data['firstName'] as String).trim()
        : '';
    final lastName = data['lastName'] is String
        ? (data['lastName'] as String).trim()
        : '';
    final registeredName = [firstName, lastName]
        .where((part) => part.isNotEmpty)
        .join(' ');

    return registeredName.isNotEmpty ? registeredName : 'Not Provided';
  }

  String _stringValue(dynamic value, {String fallback = '—'}) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final nin = _stringValue(data['nin'], fallback: '');
    final bvn = _stringValue(data['bvn'], fallback: '');
    final hasNin = nin.isNotEmpty;
    final hasBvn = bvn.isNotEmpty;

    return Column(
      children: [
        _item('Full Name', _displayName()),
        _item('Phone Number', _stringValue(data['phone'], fallback: 'Not Provided')),
        _item('Address', _stringValue(data['address'])),
        _item(
          hasNin ? 'NIN' : 'BVN',
          hasNin ? nin : hasBvn ? bvn : 'Not Provided',
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _item(String label, String? value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? '—',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(color: Colors.white24),
        ],
      ),
    );
  }
}
