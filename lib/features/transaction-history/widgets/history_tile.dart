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

  @override
  Widget build(BuildContext context) {
    final title = transaction["title"]?.toString() ?? "Transaction";

    final type = transaction["type"]?.toString() ?? "transaction";

    final amount = _formatAmount(transaction["amount"]);

    final iconData = HistoryIconMapper.detect(title, type);

    final icon = iconData["icon"];
    final color = iconData["color"];

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      leading: CircleAvatar(backgroundColor: color, child: icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(formattedDate, style: const TextStyle(fontSize: 12)),
      trailing: Text(
        amount,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      onTap: () => _openReceipt(context),
    );
  }

  Future<void> _openReceipt(BuildContext context) async {
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
