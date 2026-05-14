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

  final currency = NumberFormat.currency(
    locale: "en_NG",
    symbol: "₦",
    decimalDigits: 2,
  );

  void computeTotals(List<dynamic> transactions) {
    double inTotal = 0;
    double outTotal = 0;

    for (var tx in transactions) {
      final amount = double.tryParse(tx['amount'].toString()) ?? 0.0;

      if (tx['type'] == 'credit') {
        inTotal += amount;
      } else if (tx['type'] == 'debit') {
        outTotal += amount;
      }
    }

    totalIn = inTotal;
    totalOut = outTotal;
  }

  Widget moneySummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Total Money In
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total Money In",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                currency.format(totalIn),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          // Total Money Out
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Total Money Out",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                currency.format(totalOut),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
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
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final wallet = snapshot.data!.data() as Map<String, dynamic>;
        final transactions = wallet['transactions'] ?? [];

        computeTotals(transactions);

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GreetingSection(),
                    const SizedBox(height: 20),

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
            ),
          ),
        );
      },
    );
  }
}
