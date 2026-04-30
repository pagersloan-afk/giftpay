import 'package:flutter/material.dart';

class CableSmartcardSection extends StatelessWidget {
  final String? provider;
  final bool verifying;
  final String? customerName;
  final Function(String) onSmartcardChanged;
  final Function(String) onPhoneChanged;
  final VoidCallback onVerify;

  const CableSmartcardSection({
    super.key,
    required this.provider,
    required this.verifying,
    required this.customerName,
    required this.onSmartcardChanged,
    required this.onPhoneChanged,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Smartcard / IUC",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter smartcard number",
              ),
              onChanged: onSmartcardChanged,
            ),

            const SizedBox(height: 12),

            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Phone number",
              ),
              onChanged: onPhoneChanged,
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: verifying ? null : onVerify,
                child: verifying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Verify"),
              ),
            ),

            if (customerName != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(
                    customerName!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
