import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';

class AirtimeReceiptScreen extends StatelessWidget {
  final Map txn;

  const AirtimeReceiptScreen({super.key, required this.txn});

  // Extract phone from title: "Airtime Purchase (09046480092)"
  String _extractPhone(String title) {
    try {
      final start = title.indexOf("(");
      final end = title.indexOf(")");
      if (start != -1 && end != -1 && end > start) {
        return title.substring(start + 1, end);
      }
      return "N/A";
    } catch (_) {
      return "N/A";
    }
  }

  // Format timestamp → "13 May 2026 • 09:42 AM"
  String _formatDate(dynamic raw) {
    try {
      final ts = raw is int ? raw : int.tryParse(raw.toString());
      if (ts == null) return "N/A";

      final date = DateTime.fromMillisecondsSinceEpoch(ts);

      final months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];

      final hour = date.hour == 0
          ? 12
          : (date.hour > 12 ? date.hour - 12 : date.hour);

      final ampm = date.hour >= 12 ? "PM" : "AM";

      return "${date.day} ${months[date.month - 1]} ${date.year} • "
          "$hour:${date.minute.toString().padLeft(2, '0')} $ampm";
    } catch (_) {
      return raw.toString();
    }
  }

  // Format amount → ₦50.00
  String _formatAmount(dynamic raw) {
    try {
      final value = raw is num ? raw : num.tryParse(raw.toString()) ?? 0;
      return "₦${value.toStringAsFixed(2)}";
    } catch (_) {
      return "₦$raw";
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = txn["title"] ?? "";
    final phone = _extractPhone(title);
    final amount = _formatAmount(txn["amount"]);
    final message =
        txn["message"] ?? "Airtime purchase completed successfully.";
    final date = _formatDate(txn["timestamp"] ?? txn["date"]);
    final id = txn["id"] ?? "N/A";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GiftPayBackground(
        child: Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ICON
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone_android,
                    size: 70,
                    color: Colors.blue.shade300,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Airtime Receipt",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 25),

                // DETAILS CARD
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      _detailRow("Phone Number", phone),
                      const SizedBox(height: 12),
                      _detailRow("Amount", amount),
                      const SizedBox(height: 12),
                      _detailRow("Date", date),
                      const SizedBox(height: 12),
                      _detailRow("Transaction ID", id),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, color: Colors.white70),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
