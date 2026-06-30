import 'package:flutter/material.dart';

class GiftCardReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const GiftCardReceiptScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final brand = transaction["brand"] ?? "Gift Card";
    final cardType = transaction["cardType"] ?? "";
    final code = transaction["code"] ?? "";
    final amount = transaction["amount"]?.toString() ?? "0";
    final date = transaction["date"] ?? transaction["timestamp"]?.toString();

    return Scaffold(
      appBar: AppBar(title: const Text("Gift Card Receipt")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.card_giftcard, size: 80, color: Colors.amber),
            const SizedBox(height: 16),

            Text(
              "$brand Gift Card",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            _row("Brand", brand),
            _row("Type", cardType),
            _row("Amount", "₦$amount"),
            _row("Date", date.toString().substring(0, 16)),
            _row("Code", code),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
