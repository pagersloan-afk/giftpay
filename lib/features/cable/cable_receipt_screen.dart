import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/giftpay_api.dart';
import 'package:utilityhub/core/giftpay_toast.dart';

class CableReceiptScreen extends StatefulWidget {
  final Map<String, dynamic> txn;

  const CableReceiptScreen({super.key, required this.txn});

  @override
  State<CableReceiptScreen> createState() => _CableReceiptScreenState();
}

class _CableReceiptScreenState extends State<CableReceiptScreen> {
  bool loading = false;

  Future<void> _requery() async {
    setState(() => loading = true);

    try {
      final res = await GiftPayAPI.post("/api/cable/requery", {
        "userId": FirebaseAuth.instance.currentUser!.uid,
        "requestId": widget.txn["id"],
      });

      if (res["status"] == true) {
        GiftPayToast.success(context, "Transaction completed");
        setState(() => widget.txn["status"] = "success");
      } else if (res["message"].toString().contains("Refunded")) {
        GiftPayToast.error(context, "Transaction failed. Refunded.");
        setState(() => widget.txn["status"] = "failed");
      } else {
        GiftPayToast.error(context, "Still pending");
      }
    } catch (e) {
      GiftPayToast.error(context, "Requery failed");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final txn = widget.txn;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const AppHeaderr(title: "Cable Receipt"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row("Status", txn["status"]),
                _row("Provider", txn["cable"]),
                _row("Smartcard", txn["smartcard"]),
                _row("Customer", txn["customerName"] ?? "-"),
                _row("Package", txn["packageCode"]),
                _row("Amount", "₦${txn["amount"]}"),
                _row("Fee", "₦${txn["fee"]}"),
                _row("Cashback", "₦${txn["cashback"]}"),
                _row("Total Debited", "₦${txn["totalDebited"]}"),
                _row("Reference", txn["id"]),
                _row(
                  "Timestamp",
                  DateTime.fromMillisecondsSinceEpoch(
                    txn["timestamp"],
                  ).toString(),
                ),

                const SizedBox(height: 24),

                if (txn["status"] == "pending")
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : _requery,
                      style: Theme.of(context).elevatedButtonTheme.style,
                      child: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Requery"),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
