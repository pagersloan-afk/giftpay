import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/transaction-history/utils/history_date_formatter.dart';
import 'package:utilityhub/features/transaction-history/widgets/history_tile.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final bool fromBottomNav; // ⭐ NEW FLAG

  const TransactionHistoryScreen({super.key, this.fromBottomNav = false});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  bool loading = true;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  int _safeTimestamp(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is String && int.tryParse(value) != null) {
      return int.parse(value);
    }

    try {
      final dt = DateTime.tryParse(value.toString());
      if (dt != null) return dt.millisecondsSinceEpoch;
    } catch (_) {}

    return 0;
  }

  Future<void> _loadHistory() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final walletDoc = await FirebaseFirestore.instance
        .collection("wallets")
        .doc(userId)
        .get();

    final walletTx = (walletDoc.data()?["transactions"] ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    final elecSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .get();

    final elecTx = elecSnap.docs.map((d) => d.data()).toList();

    final merged = <Map<String, dynamic>>[
      ...walletTx.map((e) => Map<String, dynamic>.from(e)),
      ...elecTx.map((e) => Map<String, dynamic>.from(e)),
    ];

    merged.sort((a, b) {
      final t1 = _safeTimestamp(a["timestamp"] ?? a["date"]);
      final t2 = _safeTimestamp(b["timestamp"] ?? b["date"]);
      return t2.compareTo(t1);
    });

    setState(() {
      transactions = merged;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ⭐ If opened from bottom nav → simple AppBar
      // ⭐ If opened via push → GiftPay AppHeaderr
      appBar: widget.fromBottomNav
          ? AppBar(
              backgroundColor: const Color(0xFF0F1115),
              elevation: 0,
              centerTitle: true,
              title: const Text(
                "Transaction History",
                style: TextStyle(
                  fontSize: 17, // ⭐ same as GiftPay AppHeaderr
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          : const AppHeaderr(title: "Transaction History"),

      body: AppResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : transactions.isEmpty
              ? const Center(
                  child: Text(
                    "No transactions yet",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final t = transactions[i];
                    return HistoryTile(
                      transaction: t,
                      formattedDate: HistoryDateFormatter.safeDate(
                        t["timestamp"] ?? t["date"],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
