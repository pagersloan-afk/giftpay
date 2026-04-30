import 'package:flutter/material.dart';

class BettingCustomerSection extends StatelessWidget {
  final String? provider;
  final bool verifying;
  final String? customerName;
  final Function(String) onCustomerChanged;
  final VoidCallback onVerify;

  const BettingCustomerSection({
    super.key,
    required this.provider,
    required this.verifying,
    required this.customerName,
    required this.onCustomerChanged,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Customer ID", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),

            TextField(
              keyboardType: TextInputType.number,
              onChanged: onCustomerChanged,
              decoration: const InputDecoration(
                hintText: "Enter Customer ID",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider == null ? null : onVerify,
                child: verifying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Verify Customer"),
              ),
            ),

            if (customerName != null) ...[
              const SizedBox(height: 12),
              Text(
                "Customer: $customerName",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
