import 'package:flutter/material.dart';

class BettingSummarySection extends StatelessWidget {
  final String? provider;
  final String? customerId;
  final String? customerName;
  final int? amount;
  final int fee;
  final int cashback;
  final int totalPayable;

  const BettingSummarySection({
    super.key,
    required this.provider,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.fee,
    required this.cashback,
    required this.totalPayable,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Summary",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            _row("Provider", provider),
            _row("Customer ID", customerId),
            _row("Customer Name", customerName),
            _row("Amount", amount != null ? "₦$amount" : null),
            _row("Fee", "₦$fee"),
            _row("Cashback", "₦$cashback"),
            const Divider(),
            _row("Total Payable", "₦$totalPayable", bold: true),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String? value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value ?? "-",
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
