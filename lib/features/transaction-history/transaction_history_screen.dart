import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/transaction-history/utils/history_date_formatter.dart';
import 'package:utilityhub/features/transaction-history/widgets/history_tile.dart';
import 'package:utilityhub/features/giftcards/services/giftcard_trade_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final bool fromBottomNav;

  const TransactionHistoryScreen({super.key, this.fromBottomNav = false});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  bool loading = true;

  List<Map<String, dynamic>> transactions = [];

  final GiftCardTradeService _giftCardTradeService = GiftCardTradeService();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // ============================================================
  // SAFE TIMESTAMP
  // ============================================================

  int _safeTimestamp(dynamic value) {
    if (value == null) return 0;

    if (value is Timestamp) {
      return value.millisecondsSinceEpoch;
    }

    if (value is DateTime) {
      return value.millisecondsSinceEpoch;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    if (value is String) {
      final parsedInt = int.tryParse(value);

      if (parsedInt != null) {
        return parsedInt;
      }

      final parsedDate = DateTime.tryParse(value);

      if (parsedDate != null) {
        return parsedDate.millisecondsSinceEpoch;
      }
    }

    try {
      final dt = DateTime.tryParse(value.toString());

      if (dt != null) {
        return dt.millisecondsSinceEpoch;
      }
    } catch (_) {}

    return 0;
  }

  // ============================================================
  // PRESTMIT SELL → MAIN HISTORY FORMAT
  // ============================================================

  Map<String, dynamic> _prestmitSellToHistory(dynamic trade) {
    String stringValue(dynamic value) {
      return value?.toString() ?? "";
    }

    dynamic read(dynamic object, String key) {
      try {
        if (object is Map) {
          return object[key];
        }

        switch (key) {
          case "id":
            return object.id;
          case "providerReference":
            return object.providerReference;
          case "brand":
            return object.brand;
          case "country":
            return object.country;
          case "cardType":
            return object.cardType;
          case "amount":
            return object.amount;
          case "rate":
            return object.rate;
          case "valueInNaira":
            return object.valueInNaira;
          case "status":
            return object.status;
          case "providerStatus":
            return object.providerStatus;
          case "payoutMethod":
            return object.payoutMethod;
          case "rejectionReason":
            return object.rejectionReason;
          case "comments":
            return object.comments;
          case "createdAt":
            return object.createdAt;
          case "updatedAt":
            return object.updatedAt;
        }
      } catch (_) {}

      return null;
    }

    final providerReference = stringValue(read(trade, "providerReference"));

    final id = providerReference.isNotEmpty
        ? "prestmit_sell_$providerReference"
        : stringValue(read(trade, "id"));

    final brand = stringValue(read(trade, "brand"));
    final country = stringValue(read(trade, "country"));
    final cardType = stringValue(read(trade, "cardType"));

    final amount = read(trade, "amount");
    final rate = read(trade, "rate");
    final valueInNaira = read(trade, "valueInNaira");

    final status = stringValue(read(trade, "status")).toLowerCase();
    final providerStatus = stringValue(
      read(trade, "providerStatus"),
    ).toLowerCase();

    final rejectionReason = stringValue(read(trade, "rejectionReason"));
    final payoutMethod = stringValue(read(trade, "payoutMethod"));

    final createdAt = read(trade, "createdAt");
    final updatedAt = read(trade, "updatedAt");

    final title = status == "rejected"
        ? "Gift Card Sale Rejected"
        : status == "completed"
        ? "Gift Card Sale Completed"
        : "Gift Card Sale";

    final displayAmount = valueInNaira ?? amount ?? 0;

    return {
      "id": id,
      "title": title,
      "type": "giftcard_sell",
      "category": "giftcard",
      "amount": displayAmount,
      "timestamp": createdAt ?? updatedAt ?? 0,
      "date": createdAt ?? updatedAt ?? 0,
      "prestmitSell": true,
      "providerReference": providerReference,
      "brand": brand,
      "country": country,
      "cardType": cardType,
      "cardAmount": amount,
      "rate": rate,
      "valueInNaira": valueInNaira,
      "status": status,
      "providerStatus": providerStatus,
      "payoutMethod": payoutMethod,
      "rejectionReason": rejectionReason,
      "comments": read(trade, "comments"),
      "isRejectedSell": status == "rejected",
      "isCompletedSell": status == "completed",
    };
  }

  // ============================================================
  // BULK TRANSFER → MAIN HISTORY FORMAT
  // ============================================================

  Map<String, dynamic> _bulkTransferToHistory(
    String documentId,
    Map<String, dynamic> batch,
  ) {
    final rawCreatedAt =
        batch["createdAt"] ??
        batch["created_at"] ??
        batch["timestamp"] ??
        batch["date"];

    final items = batch["items"] is List
        ? List<dynamic>.from(batch["items"] as List)
        : <dynamic>[];

    final itemCount =
        batch["itemCount"] ?? batch["totalRecipients"] ?? items.length;

    final totalAmount =
        batch["totalAmount"] ?? batch["total_amount"] ?? batch["amount"] ?? 0;

    final totalFees = batch["totalFees"] ?? batch["total_fees"] ?? 0;

    final totalDebited =
        batch["totalDebited"] ?? batch["total_debited"] ?? totalAmount;

    return {
      "id": documentId,
      "type": "bulk_transfer",
      "title": batch["batchName"]?.toString().trim().isNotEmpty == true
          ? batch["batchName"].toString()
          : "Bulk Transfer",
      "amount": totalDebited,
      "timestamp": _safeTimestamp(rawCreatedAt),
      "date": rawCreatedAt,
      "batchReference": batch["batchReference"]?.toString() ?? documentId,
      "status": batch["status"]?.toString() ?? "unknown",
      "currency": batch["currency"]?.toString() ?? "NGN",
      "itemCount": itemCount,
      "totalAmount": totalAmount,
      "totalFees": totalFees,
      "totalDebited": totalDebited,
      "items": items,
      "refunded": batch["refunded"] == true,
      "refundAmount": batch["refundAmount"] ?? 0,
      "refundReason": batch["refundReason"]?.toString() ?? "",
    };
  }

  // ============================================================
  // LOAD HISTORY
  // ============================================================

  Future<void> _loadHistory() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      if (!mounted) return;

      setState(() {
        loading = false;
        transactions = [];
      });

      return;
    }

    try {
      // ==========================================================
      // 1. WALLET TRANSACTIONS
      // ==========================================================

      final walletDoc = await FirebaseFirestore.instance
          .collection("wallets")
          .doc(userId)
          .get();

      final walletTx = (walletDoc.data()?["transactions"] ?? [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      // ==========================================================
      // 2. UTILITY TRANSACTIONS
      // ==========================================================

      final elecSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("transactions")
          .get();

      final elecTx = elecSnap.docs
          .map((d) => Map<String, dynamic>.from(d.data()))
          .toList();

      // ==========================================================
      // 3. BULK TRANSFER HISTORY
      // ==========================================================

      final bulkSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("bulk_transfers")
          .get();

      final bulkTx = bulkSnap.docs
          .map((doc) {
            return _bulkTransferToHistory(doc.id, doc.data());
          })
          .where((tx) {
            return _safeTimestamp(tx["timestamp"]) > 0;
          })
          .toList();

      // ==========================================================
      // 4. PRESTMIT SELL TRANSACTIONS
      // ==========================================================

      List<Map<String, dynamic>> prestmitSellTx = [];

      try {
        final sellTrades = await _giftCardTradeService.getHistory();

        prestmitSellTx = sellTrades
            .map<Map<String, dynamic>>((trade) => _prestmitSellToHistory(trade))
            .toList();
      } catch (e) {
        debugPrint("[TRANSACTION HISTORY] Prestmit SELL history failed: $e");
      }

      // ==========================================================
      // 5. MERGE
      // ==========================================================

      final merged = <Map<String, dynamic>>[
        ...walletTx,
        ...elecTx,
        ...bulkTx,
        ...prestmitSellTx,
      ];

      // ==========================================================
      // 6. REMOVE DUPLICATE COMPLETED SELL
      // ==========================================================

      final walletPrestmitReferences = <String>{};

      for (final tx in walletTx) {
        final type = tx["type"]?.toString().toLowerCase() ?? "";
        final title = tx["title"]?.toString().toLowerCase() ?? "";

        final looksLikeGiftCardSell =
            type == "giftcard_sell" ||
            (type == "giftcard" && title.contains("sale")) ||
            title.contains("gift card sale");

        if (!looksLikeGiftCardSell) {
          continue;
        }

        final reference =
            tx["providerReference"]?.toString() ??
            tx["prestmitReference"]?.toString() ??
            tx["reference"]?.toString() ??
            "";

        if (reference.isNotEmpty) {
          walletPrestmitReferences.add(reference);
        }
      }

      final deduplicated = <Map<String, dynamic>>[];

      for (final tx in merged) {
        if (tx["prestmitSell"] == true) {
          final status = tx["status"]?.toString().toLowerCase() ?? "";
          final reference = tx["providerReference"]?.toString() ?? "";

          if (status == "completed" &&
              reference.isNotEmpty &&
              walletPrestmitReferences.contains(reference)) {
            continue;
          }
        }

        deduplicated.add(tx);
      }

      // ==========================================================
      // 7. SORT NEWEST FIRST
      // ==========================================================

      deduplicated.sort((a, b) {
        final t1 = _safeTimestamp(a["timestamp"] ?? a["date"]);
        final t2 = _safeTimestamp(b["timestamp"] ?? b["date"]);

        return t2.compareTo(t1);
      });

      if (!mounted) return;

      setState(() {
        transactions = deduplicated;
        loading = false;
      });
    } catch (e) {
      debugPrint("[TRANSACTION HISTORY] Failed to load history: $e");

      if (!mounted) return;

      setState(() {
        transactions = [];
        loading = false;
      });
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshHistory() async {
    setState(() {
      loading = true;
    });

    await _loadHistory();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.fromBottomNav
          ? AppBar(
              backgroundColor: const Color(0xFF0F1115),
              elevation: 0,
              centerTitle: true,
              title: const Text(
                "Transaction History",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          : const AppHeaderr(title: "Transaction History"),
      body: AppResponsiveLayout(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : transactions.isEmpty
            ? RefreshIndicator(
                onRefresh: _refreshHistory,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 250),
                    Center(
                      child: Text(
                        "No transactions yet",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _refreshHistory,
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final transaction = transactions[i];

                    return HistoryTile(
                      transaction: transaction,
                      formattedDate: HistoryDateFormatter.safeDate(
                        transaction["timestamp"] ?? transaction["date"],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
