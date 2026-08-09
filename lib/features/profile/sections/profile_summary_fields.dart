import 'package:flutter/material.dart';

class ProfileSummaryFields extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProfileSummaryFields({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _item("Full Name", data["name"]),
        _item("Phone Number", data["phone"]),
        _item("Address", data["address"]),
        _item(
          data["nin"] != null ? "NIN" : "BVN",
          data["nin"] ?? data["bvn"] ?? "Not Provided",
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
            value ?? "—",
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
