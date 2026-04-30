import 'package:flutter/material.dart';
import 'sections/greeting_section.dart';
import 'sections/wallet_section.dart';
import 'sections/services_section.dart';
import 'sections/recommended_section.dart';
import 'sections/recent_transactions_section.dart';
import 'sections/loan_banner_section.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          GreetingSection(),
          SizedBox(height: 20),

          WalletSection(),
          SizedBox(height: 20),

          ServicesSection(),
          SizedBox(height: 30),

          RecommendedSection(),
          SizedBox(height: 30),

          RecentTransactionsSection(),
          SizedBox(height: 30),

          LoanBannerSection(),
        ],
      ),
    );
  }
}
