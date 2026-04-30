import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/history_icon_mapper.dart';

// Screens
import 'package:utilityhub/features/electricity/receipt_screen.dart';
import 'package:utilityhub/features/airtime/airtime_screen.dart';
import 'package:utilityhub/features/data/data_screen.dart';
import 'package:utilityhub/features/cable/cable_receipt_screen.dart';
import 'package:utilityhub/features/wallet/wallet_receipt_screen.dart';
import 'package:utilityhub/features/betting/betting_receipt_screen.dart';

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

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .doc(id)
        .get();

    final realTx = doc.data() ?? {};
    final titleLower = (transaction["title"] ?? "").toLowerCase();

    // ⭐ ELECTRICITY
    if (titleLower.startsWith("electricity")) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptScreen(
            token: realTx["token"] ?? "",
            amount: realTx["amount"]?.toString() ?? "0",
            customerName: realTx["customerName"] ?? "Customer",
            meterNumber: realTx["meterNumber"] ?? "Unknown",
            buildPdf: () async => Uint8List(0),
          ),
        ),
      );
      return;
    }

    // ⭐ AIRTIME
    if (titleLower.startsWith("airtime")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AirtimeScreen()),
      );
      return;
    }

    // ⭐ DATA
    if (titleLower.startsWith("data")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DataScreen()),
      );
      return;
    }

    // ⭐ CABLE TV
    if (titleLower.startsWith("cable")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CableReceiptScreen(txn: realTx)),
      );
      return;
    }

    // ⭐ BETTING (NEW)
    if (titleLower.startsWith("betting")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BettingReceiptScreen(txn: realTx)),
      );
      return;
    }

    // ⭐ WALLET / DEFAULT
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletReceiptScreen(
          title: transaction["title"],
          amount: transaction["amount"].toString(),
          date: formattedDate,
          type: transaction["type"],
        ),
      ),
    );
  }
}
