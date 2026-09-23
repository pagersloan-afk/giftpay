import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../utils/history_icon_mapper.dart';

// Screens
import 'package:utilityhub/features/electricity/receipt_screen.dart';
import 'package:utilityhub/features/airtime/airtime_receipt_screen.dart';
import 'package:utilityhub/features/data/data_receipt_screen.dart';
import 'package:utilityhub/features/cable/cable_receipt_screen.dart';
import 'package:utilityhub/features/wallet/wallet_receipt_screen.dart';
import 'package:utilityhub/features/betting/betting_receipt_screen.dart';
import 'package:utilityhub/features/wallet/giftcard_receipt_screen.dart';

class HistoryTile extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final String formattedDate;

  const HistoryTile({
    super.key,
    required this.transaction,
    required this.formattedDate,
  });

  // ============================================================
  // CURRENCY FORMATTING
  // ============================================================

  String _formatAmount(dynamic value) {
    if (value == null) {
      return "₦0.00";
    }

    final number = value is num
        ? value
        : num.tryParse(value.toString().replaceAll(",", ""));

    if (number == null) {
      return "₦${value.toString()}";
    }

    return "₦${NumberFormat("#,##0.00").format(number)}";
  }

  // ============================================================
  // PRESTMIT SELL DETECTION
  // ============================================================

  bool _isPrestmitSell() {
    if (transaction["prestmitSell"] == true) {
      return true;
    }

    final type = transaction["type"]?.toString().toLowerCase() ?? "";

    final title = transaction["title"]?.toString().toLowerCase() ?? "";

    return type == "giftcard_sell" || title.contains("gift card sale");
  }

  bool _isRejectedPrestmitSell() {
    if (!_isPrestmitSell()) {
      return false;
    }

    final status = transaction["status"]?.toString().toLowerCase() ?? "";

    return status == "rejected" || transaction["isRejectedSell"] == true;
  }

  bool _isCompletedPrestmitSell() {
    if (!_isPrestmitSell()) {
      return false;
    }

    final status = transaction["status"]?.toString().toLowerCase() ?? "";

    return status == "completed" || transaction["isCompletedSell"] == true;
  }

  // ============================================================
  // DISPLAY COLOR
  // ============================================================

  Color _prestmitSellColor() {
    if (_isRejectedPrestmitSell()) {
      return Colors.red;
    }

    if (_isCompletedPrestmitSell()) {
      return Colors.green;
    }

    return Colors.orange;
  }

  // ============================================================
  // DISPLAY ICON
  // ============================================================

  IconData _prestmitSellIcon() {
    if (_isRejectedPrestmitSell()) {
      return Icons.cancel_outlined;
    }

    if (_isCompletedPrestmitSell()) {
      return Icons.check_circle_outline;
    }

    return Icons.card_giftcard;
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final title = transaction["title"]?.toString() ?? "Transaction";

    final type = transaction["type"]?.toString() ?? "transaction";

    final amount = _formatAmount(transaction["amount"]);

    // ----------------------------------------------------------
    // Prestmit SELL
    // ----------------------------------------------------------

    final bool isPrestmitSell = _isPrestmitSell();

    final dynamic iconData = isPrestmitSell
        ? {
            "icon": Icon(_prestmitSellIcon(), color: Colors.white, size: 20),
            "color": _prestmitSellColor(),
          }
        : HistoryIconMapper.detect(title, type);

    final icon = iconData["icon"];
    final color = iconData["color"];

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      leading: CircleAvatar(backgroundColor: color, child: icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formattedDate, style: const TextStyle(fontSize: 12)),

          // ------------------------------------------------------
          // Prestmit SELL status
          // ------------------------------------------------------
          if (isPrestmitSell)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                _sellStatusLabel(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _prestmitSellColor(),
                ),
              ),
            ),
        ],
      ),
      trailing: Text(
        amount,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      onTap: () => _openReceipt(context),
    );
  }

  // ============================================================
  // SELL STATUS LABEL
  // ============================================================

  String _sellStatusLabel() {
    final status = transaction["status"]?.toString().toLowerCase() ?? "";

    switch (status) {
      case "completed":
        return "COMPLETED";

      case "rejected":
        return "REJECTED";

      case "pending":
        return "PENDING";

      default:
        return status.isEmpty ? "SELL TRANSACTION" : status.toUpperCase();
    }
  }

  // ============================================================
  // PRESTMIT SELL DETAILS
  // ============================================================

  Future<void> _showPrestmitSellDetails(BuildContext context) async {
    final brand = transaction["brand"]?.toString() ?? "";

    final country = transaction["country"]?.toString() ?? "";

    final cardType = transaction["cardType"]?.toString() ?? "";

    final providerReference =
        transaction["providerReference"]?.toString() ?? "";

    final cardAmount = transaction["cardAmount"] ?? transaction["amount"] ?? 0;

    final rate = transaction["rate"] ?? 0;

    final valueInNaira =
        transaction["valueInNaira"] ?? transaction["amount"] ?? 0;

    final payoutMethod = transaction["payoutMethod"]?.toString() ?? "";

    final rejectionReason = transaction["rejectionReason"]?.toString() ?? "";

    final status = transaction["status"]?.toString().toUpperCase() ?? "UNKNOWN";

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                status == "REJECTED"
                    ? Icons.cancel_outlined
                    : status == "COMPLETED"
                    ? Icons.check_circle_outline
                    : Icons.card_giftcard,
                color: status == "REJECTED"
                    ? Colors.red
                    : status == "COMPLETED"
                    ? Colors.green
                    : Colors.orange,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  status == "REJECTED"
                      ? "Gift Card Sale Rejected"
                      : status == "COMPLETED"
                      ? "Gift Card Sale"
                      : "Gift Card Sale",
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (brand.isNotEmpty) _detailRow("Brand", brand),

                if (country.isNotEmpty) _detailRow("Country", country),

                if (cardType.isNotEmpty) _detailRow("Card Type", cardType),

                _detailRow("Card Value", _formatAmount(cardAmount)),

                _detailRow("Rate", rate.toString()),

                _detailRow("Expected Payout", _formatAmount(valueInNaira)),

                if (payoutMethod.isNotEmpty)
                  _detailRow("Payout Method", payoutMethod),

                if (providerReference.isNotEmpty)
                  _detailRow("Reference", providerReference),

                const SizedBox(height: 12),

                Text(
                  "Status",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 4),

                Text(
                  status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: status == "REJECTED"
                        ? Colors.red
                        : status == "COMPLETED"
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),

                // ------------------------------------------------
                // Rejection reason
                // ------------------------------------------------
                if (status == "REJECTED" && rejectionReason.isNotEmpty) ...[
                  const SizedBox(height: 16),

                  Text(
                    "Rejection Reason",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 5),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      rejectionReason,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(String label, dynamic value) {
    final text = value?.toString() ?? "";

    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OPEN RECEIPT
  // ============================================================

  Future<void> _openReceipt(BuildContext context) async {
    // ==========================================================
    // PRESTMIT SELL
    // ==========================================================

    if (_isPrestmitSell()) {
      // Rejected SELLs don't have a wallet transaction.
      // Show their trade details instead of attempting to open
      // a wallet receipt.
      if (_isRejectedPrestmitSell()) {
        await _showPrestmitSellDetails(context);
        return;
      }

      // Pending SELLs also don't necessarily have a wallet
      // transaction yet.
      final status = transaction["status"]?.toString().toLowerCase() ?? "";

      if (status != "completed") {
        await _showPrestmitSellDetails(context);
        return;
      }

      // Completed SELL should normally have the actual wallet
      // transaction, so continue below and find it.
    }

    final id = transaction["id"];

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final userId = user.uid;

    final titleLower = (transaction["title"] ?? "").toString().toLowerCase();

    // ============================================================
    // ELECTRICITY
    // ============================================================

    if (titleLower.startsWith("electricity")) {
      final snap = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("transactions")
          .doc(id)
          .get();

      final fullTx = snap.data() ?? {};

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptScreen(
            token: fullTx["token"] ?? "",
            amount: fullTx["amount"]?.toString() ?? "0",
            customerName: fullTx["customerName"] ?? "Customer",
            meterNumber: fullTx["meterNumber"] ?? "Unknown",
            timestamp: fullTx["timestamp"] ?? 0,
            buildPdf: () async => Uint8List(0),
          ),
        ),
      );

      return;
    }

    // ============================================================
    // LOAD WALLET TRANSACTION
    // ============================================================

    final walletDoc = await FirebaseFirestore.instance
        .collection("wallets")
        .doc(userId)
        .get();

    final walletData = walletDoc.data() ?? {};

    final txList = walletData["transactions"] as List<dynamic>? ?? [];

    Map<String, dynamic> realTx = {};

    for (final item in txList) {
      if (item is Map) {
        final candidate = Map<String, dynamic>.from(item);

        if (candidate["id"]?.toString() == id?.toString()) {
          realTx = candidate;
          break;
        }
      }
    }

    // ============================================================
    // GIFT CARD
    // ============================================================

    final realTitle = (realTx["title"] ?? transaction["title"] ?? "")
        .toString()
        .toLowerCase();

    final realType = (realTx["type"] ?? transaction["type"] ?? "")
        .toString()
        .toLowerCase();

    final isGiftCard =
        realType == "giftcard" ||
        realType == "gift_card" ||
        realTitle.startsWith("gift card") ||
        realTitle.contains("gift card purchase") ||
        realTitle.contains("giftcard");

    if (isGiftCard) {
      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GiftCardReceiptScreen(
            transaction: realTx.isNotEmpty ? realTx : transaction,
          ),
        ),
      );

      return;
    }

    // ============================================================
    // AIRTIME
    // ============================================================

    if (realTitle.startsWith("airtime")) {
      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AirtimeReceiptScreen(txn: realTx)),
      );

      return;
    }

    // ============================================================
    // DATA
    // ============================================================

    if (realTitle.startsWith("data")) {
      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DataReceiptScreen(txn: realTx)),
      );

      return;
    }

    // ============================================================
    // CABLE
    // ============================================================

    if (realTitle.startsWith("cable")) {
      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CableReceiptScreen(txn: realTx)),
      );

      return;
    }

    // ============================================================
    // BETTING
    // ============================================================

    if (realTitle.startsWith("betting") ||
        realTitle.contains("betting") ||
        realType == "betting") {
      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BettingReceiptScreen(txn: realTx)),
      );

      return;
    }

    // ============================================================
    // DEFAULT WALLET RECEIPT
    // ============================================================

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletReceiptScreen(
          title: realTx["title"] ?? "Wallet Transaction",
          amount: realTx["amount"]?.toString() ?? "0",
          date: formattedDate,
          type: realTx["type"] ?? "wallet",
        ),
      ),
    );
  }
}
