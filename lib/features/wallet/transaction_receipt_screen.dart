import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class TransactionReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionReceiptScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final type = transaction["type"] ?? "transaction";
    final amount = transaction["amount"]?.toString() ?? "0";
    final date =
        transaction["date"] ??
        transaction["timestamp"]?.toString() ??
        "Unknown";
    final token = transaction["token"];
    final meter = transaction["meterNumber"];

    return Scaffold(
      appBar: AppBar(title: const Text("Transaction Receipt")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(Icons.receipt_long, size: 80, color: Colors.blue),
              const SizedBox(height: 16),

              Text(
                type.toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _row("Amount", "₦$amount"),
              _row("Date", date.toString().substring(0, 16)),
              _row("Type", type),

              if (meter != null) _row("Meter Number", meter),
              if (token != null) _row("Token", token),

              const SizedBox(height: 20),

              if (token != null)
                BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: "Token:$token|Amount:$amount|Meter:$meter",
                  width: 150,
                  height: 150,
                ),

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
