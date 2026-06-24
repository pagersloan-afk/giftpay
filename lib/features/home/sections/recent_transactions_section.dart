import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:utilityhub/config/api.dart';

class RecentTransactionsSection extends StatefulWidget {
  const RecentTransactionsSection({super.key});

  @override
  State<RecentTransactionsSection> createState() =>
      _RecentTransactionsSectionState();
}

class _RecentTransactionsSectionState extends State<RecentTransactionsSection> {
  bool loading = true;
  List<dynamic> recentTx = [];

  final naira = NumberFormat.currency(
    locale: "en_NG",
    symbol: "₦",
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    loadTx();
  }

  Future<void> loadTx() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final url = Uri.parse(
        ApiConfig.api("/transaction-history?userId=$userId"),
      );

      final res = await http.get(url);
      final data = jsonDecode(res.body);

      if (data["status"] == true) {
        if (!mounted) return;
        setState(() {
          recentTx = (data["data"] as List).take(4).toList();
          loading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Text("Loading...", style: TextStyle(color: Colors.white70));
    }

    if (recentTx.isEmpty) {
      return const Text(
        "No recent transactions",
        style: TextStyle(color: Colors.white70),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Transactions",
          style: TextStyle(
            fontSize: 11.50,
            fontWeight: FontWeight.w500,
            color: Color(0xFFE5E7EB),
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4FC3F7).withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: recentTx.map((t) {
              final type = t["type"];
              final title = t["title"];
              final amount = t["amount"];
              final date = t["date"] ?? t["timestamp"];

              IconData icon;
              Color color;

              if (type == "credit") {
                icon = Icons.arrow_downward;
                color = Colors.greenAccent;
              } else if (type == "electricity") {
                icon = Icons.flash_on;
                color = Colors.orangeAccent;
              } else {
                icon = Icons.arrow_upward;
                color = Colors.redAccent;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.15),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.toString(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      naira.format(amount),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
