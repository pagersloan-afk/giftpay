import 'package:flutter/material.dart';

class CableSummarySection extends StatelessWidget {
  final String? provider;
  final String? smartcard;
  final String? customerName;
  final String? packageCode;
  final int? packageAmount;

  final int fee;
  final int cashback;
  final int totalPayable;

  const CableSummarySection({
    super.key,
    required this.provider,
    required this.smartcard,
    required this.customerName,
    required this.packageCode,
    required this.packageAmount,
    required this.fee,
    required this.cashback,
    required this.totalPayable,
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
              "Summary",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),

            const SizedBox(height: 12),

            _row("Provider", provider),
            _row("Smartcard", smartcard),
            _row("Customer", customerName),
            _row("Package", packageCode),
            _row("Amount", packageAmount != null ? "₦$packageAmount" : "-"),

            const Divider(height: 24),

            _row("Fee", "₦$fee"),
            _row("Cashback", "₦$cashback"),

            const Divider(height: 24),

            Row(
              children: [
                const Text(
                  "Total Payable:",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  "₦$totalPayable",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value ?? "-", style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
