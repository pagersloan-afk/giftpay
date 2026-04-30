import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/transaction-history/services/history_service.dart';
import 'package:utilityhub/features/transaction-history/utils/history_date_formatter.dart';
import 'package:utilityhub/features/transaction-history/widgets/history_tile.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  bool loading = true;
  List<dynamic> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final result = await HistoryService.fetchHistory(userId);

    setState(() {
      transactions = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderr(title: "Transaction History"),
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
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
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
