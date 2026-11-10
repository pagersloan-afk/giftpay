import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';

class PaystackWalletReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const PaystackWalletReceiptScreen({super.key, required this.transaction});

  String _text(dynamic value) {
    final result = value?.toString().trim() ?? "";
    return result.isEmpty || result == "null" ? "" : result;
  }

  String _money(dynamic value) {
    final amount = value is num
        ? value
        : num.tryParse(value?.toString() ?? "") ?? 0;
    return NumberFormat.currency(
      locale: "en_NG",
      symbol: "₦",
      decimalDigits: 2,
    ).format(amount);
  }

  String _date(dynamic value) {
    if (value == null) return "";
    DateTime? parsed;
    if (value is num) {
      parsed = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    } else {
      parsed = DateTime.tryParse(value.toString());
      final numeric = int.tryParse(value.toString());
      if (parsed == null && numeric != null) {
        parsed = DateTime.fromMillisecondsSinceEpoch(numeric);
      }
    }
    return parsed == null
        ? value.toString()
        : DateFormat("MMM d, yyyy • h:mm a").format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final sender = _text(transaction["senderName"]);
    final title = sender.isNotEmpty ? "from – $sender" : "Wallet Funding";
    final amount = _money(transaction["amount"]);
    final date = _date(
      transaction["paidAt"] ?? transaction["date"] ?? transaction["timestamp"],
    );
    final senderAccount =
        _text(transaction["senderAccountNumberLast4"]).isNotEmpty
        ? "•••• ${_text(transaction["senderAccountNumberLast4"])}"
        : _text(transaction["senderAccountNumber"]);
    final receiverAccount =
        _text(transaction["receiverAccountNumberLast4"]).isNotEmpty
        ? "•••• ${_text(transaction["receiverAccountNumberLast4"])}"
        : _text(transaction["receiverAccountNumber"]);
    final fees = transaction["fees"];

    return Scaffold(
      appBar: AppBar(title: const Text("Wallet Funding Details")),
      body: AppResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 12),
              const Text(
                "Successful",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                amount,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              _section("Payment details", [
                _detail("Date", date),
                _detail("Status", "Successful"),
                _detail(
                  "Reference",
                  _text(transaction["reference"] ?? transaction["id"]),
                ),
                _detail("Narration", _text(transaction["narration"])),
                if (fees != null) _detail("Transaction fee", _money(fees)),
              ]),
              const SizedBox(height: 16),
              _section("Sender details", [
                _detail("Sender name", sender),
                _detail("Sender bank", _text(transaction["senderBank"])),
                _detail("Sender account", senderAccount),
              ]),
              const SizedBox(height: 16),
              _section("Receiving account", [
                _detail("Bank", _text(transaction["receiverBank"])),
                _detail("Account number", receiverAccount),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Done"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    final visible = children.where((child) => child is! SizedBox).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...visible,
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
