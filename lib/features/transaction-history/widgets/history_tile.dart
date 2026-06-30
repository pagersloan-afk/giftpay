import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  Widget build(BuildContext context) {
    final title = transaction["title"] ?? "Transaction";
    final type = transaction["type"] ?? "transaction";
    final amount = transaction["amount"]?.toString() ?? "0";

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
        "₦$amount",
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      onTap: () => _openReceipt(context),
    );
  }

  Future<void> _openReceipt(BuildContext context) async {
    final id = transaction["id"];
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final titleLower = (transaction["title"] ?? "").toLowerCase();

    // ⭐ ELECTRICITY
    if (titleLower.startsWith("electricity")) {
      final snap = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("transactions")
          .doc(id)
          .get();

      final fullTx = snap.data() ?? {};

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

    // ⭐ WALLET TRANSACTIONS
    final walletDoc = await FirebaseFirestore.instance
        .collection("wallets")
        .doc(userId)
        .get();

    final walletData = walletDoc.data() ?? {};
    final txList = walletData["transactions"] as List<dynamic>? ?? [];

    final realTx = txList.firstWhere((t) => t["id"] == id, orElse: () => {});

    final lower = (realTx["title"] ?? "").toLowerCase();

    // ⭐ GIFT CARD RECEIPT
    if (realTx["type"] == "giftcard") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GiftCardReceiptScreen(transaction: realTx),
        ),
      );
      return;
    }

    // ⭐ AIRTIME
    if (lower.startsWith("airtime")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AirtimeReceiptScreen(txn: realTx)),
      );
      return;
    }

    // ⭐ DATA
    if (lower.startsWith("data")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DataReceiptScreen(txn: realTx)),
      );
      return;
    }

    // ⭐ CABLE
    if (lower.startsWith("cable")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CableReceiptScreen(txn: realTx)),
      );
      return;
    }

    // ⭐ BETTING
    if (lower.startsWith("betting")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BettingReceiptScreen(txn: realTx)),
      );
      return;
    }

    // ⭐ WALLET DEFAULT RECEIPT
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
