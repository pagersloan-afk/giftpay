import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'sections/greeting_section.dart';
import 'sections/wallet_section.dart';
import 'sections/services_section.dart';
import 'sections/recommended_section.dart';
import 'sections/recent_transactions_section.dart';
import 'sections/loan_banner_section.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  double totalIn = 0;
  double totalOut = 0;
  double prevTotalIn = 0;
  double prevTotalOut = 0;

  String filterRange = "week"; // week or month

  final currency = NumberFormat.currency(
    locale: "en_NG",
    symbol: "₦",
    decimalDigits: 2,
  );

  void computeTotals(List<dynamic> transactions) {
    double inTotal = 0;
    double outTotal = 0;
    double prevInTotal = 0;
    double prevOutTotal = 0;

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));

    DateTime currentStart;
    DateTime prevStart;
    DateTime prevEnd;

    if (filterRange == "week") {
      currentStart = weekAgo;
      prevStart = now.subtract(const Duration(days: 14));
      prevEnd = weekAgo;
    } else {
      currentStart = monthAgo;
      prevStart = now.subtract(const Duration(days: 60));
      prevEnd = monthAgo;
    }

    for (var tx in transactions) {
      final amount = double.tryParse(tx['amount'].toString()) ?? 0.0;
      final type = tx['type']?.toString().toLowerCase() ?? "";
      final ts = int.tryParse(tx["timestamp"].toString()) ?? 0;
      final date = DateTime.fromMillisecondsSinceEpoch(ts);

      final isCurrent = date.isAfter(currentStart) && date.isBefore(now);
      final isPrev = date.isAfter(prevStart) && date.isBefore(prevEnd);

      if (isCurrent) {
        if (type == 'credit') {
          inTotal += amount;
        } else {
          outTotal += amount;
        }
      } else if (isPrev) {
        if (type == 'credit') {
          prevInTotal += amount;
        } else {
          prevOutTotal += amount;
        }
      }
    }

    totalIn = inTotal;
    totalOut = outTotal;
    prevTotalIn = prevInTotal;
    prevTotalOut = prevOutTotal;
  }

  double _percentChange(double current, double previous) {
    if (previous == 0) return current == 0 ? 0 : 100;
    return ((current - previous) / previous) * 100;
  }

  IconData _trendIcon(double current, double previous) {
    if (current > previous) return Icons.arrow_upward;
    if (current < previous) return Icons.arrow_downward;
    return Icons.horizontal_rule;
  }

  Color _trendColor(double current, double previous) {
    if (current > previous) return Colors.greenAccent;
    if (current < previous) return Colors.redAccent;
    return Colors.grey;
  }

  Widget moneySummaryCard() {
    final inChange = _percentChange(totalIn, prevTotalIn);
    final outChange = _percentChange(totalOut, prevTotalOut);

    final inIcon = _trendIcon(totalIn, prevTotalIn);
    final outIcon = _trendIcon(totalOut, prevTotalOut);

    final inColor = _trendColor(totalIn, prevTotalIn);
    final outColor = _trendColor(totalOut, prevTotalOut);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ⭐ TITLE OUTSIDE THE CARD (Moniepoint style)
        const Text(
          "Spending Trends",
          style: TextStyle(
            fontSize: 11.50,
            fontWeight: FontWeight.w500,
            color: Color(0xFFE5E7EB),
          ),
        ),

        const SizedBox(height: 16),

        // ⭐ PARENT CARD
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⭐ WEEK / MONTH TOGGLE
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => filterRange = "week"),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: filterRange == "week"
                            ? Colors.white.withOpacity(0.25)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: filterRange == "week" ? 0 : 1,
                        ),
                      ),
                      child: Text(
                        "Week",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: filterRange == "week"
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: () => setState(() => filterRange = "month"),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: filterRange == "month"
                            ? Colors.white.withOpacity(0.25)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: filterRange == "month" ? 0 : 1,
                        ),
                      ),
                      child: Text(
                        "Month",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: filterRange == "month"
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ⭐ TWO INNER CARDS (Money In + Money Out)
              Row(
                children: [
                  // MONEY IN CARD
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.14),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Money In",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              currency.format(totalIn),
                              key: ValueKey(totalIn),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(inIcon, size: 16, color: inColor),
                              const SizedBox(width: 4),
                              Text(
                                "${inChange.toStringAsFixed(1)}%",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: inColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // MONEY OUT CARD
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.14),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Money Out",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              currency.format(totalOut),
                              key: ValueKey(totalOut),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(outIcon, size: 16, color: outColor),
                              const SizedBox(width: 4),
                              Text(
                                "${outChange.toStringAsFixed(1)}%",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: outColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('wallets')
          .doc(userId)
          .snapshots(),
      builder: (context, walletSnap) {
        if (!walletSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final wallet = walletSnap.data!.data() as Map<String, dynamic>;
        final walletTx = wallet['transactions'] ?? [];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('transactions')
              .snapshots(),
          builder: (context, serviceSnap) {
            if (!serviceSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final serviceTx = serviceSnap.data!.docs
                .map((d) => d.data() as Map<String, dynamic>)
                .toList();

            final merged = [...walletTx, ...serviceTx];

            merged.sort((a, b) {
              final t1 = int.tryParse(a["timestamp"].toString()) ?? 0;
              final t2 = int.tryParse(b["timestamp"].toString()) ?? 0;
              return t2.compareTo(t1);
            });

            computeTotals(merged);

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GreetingSection(),
                    const SizedBox(height: 5),

                    const WalletSection(),
                    const SizedBox(height: 20),

                    const ServicesSection(),
                    const SizedBox(height: 30),

                    const RecommendedSection(),
                    const SizedBox(height: 20),

                    const RecentTransactionsSection(),
                    const SizedBox(height: 30),

                    moneySummaryCard(),
                    const SizedBox(height: 30),

                    const LoanBannerSection(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
