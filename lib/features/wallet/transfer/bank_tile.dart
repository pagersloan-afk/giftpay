import 'package:flutter/material.dart';
import 'bank_logo.dart';

class BankTile extends StatelessWidget {
  final String code;
  final String name;
  final VoidCallback onTap;

  // ⭐ NEW: optional custom title widget (for highlighted search)
  final Widget? titleWidget;

  const BankTile({
    super.key,
    required this.code,
    required this.name,
    required this.onTap,
    this.titleWidget, // ⭐ added
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: BankLogo(code: code),

        // ⭐ If titleWidget is provided → use it
        // ⭐ Else → fallback to normal Text(name)
        title:
            titleWidget ??
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),

        subtitle: Text(
          code,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),

        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
