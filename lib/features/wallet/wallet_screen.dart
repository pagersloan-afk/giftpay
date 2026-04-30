import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/transaction-history/transaction_history_screen.dart';
import 'package:utilityhub/features/wallet/services/wallet_service.dart';
import 'fund_wallet_screen.dart';
import 'withdraw_screen.dart';
import 'virtual_account_card.dart'; // ⭐ Add this import

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late WalletService wallet;

  @override
  void initState() {
    super.initState();
    wallet = WalletService();
  }

  Future<void> _navigateAndRefresh(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        print("AUTH USER = ${snapshot.data!.uid}");

        return Scaffold(
          appBar: AppBar(title: const Text("My Wallet")),
          body: AppResponsiveLayout(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ⭐ REAL-TIME BALANCE CARD
                  StreamBuilder<double>(
                    stream: wallet.walletBalanceStream(),
                    builder: (_, snapshot) {
                      if (snapshot.hasError) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "Error loading balance",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }

                      final balance = snapshot.data ?? 0;

                      final formattedBalance = NumberFormat(
                        "#,##0",
                      ).format(balance);

                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Wallet Balance",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              "₦$formattedBalance",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ⭐ NEW: VIRTUAL ACCOUNT CARD
                  const VirtualAccountCard(),

                  const SizedBox(height: 24),

                  // ⭐ FUND + WITHDRAW BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _navigateAndRefresh(const FundWalletScreen()),
                          child: const Text("Fund Wallet"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _navigateAndRefresh(const WithdrawScreen()),
                          child: const Text("Withdraw"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ⭐ TRANSACTION HISTORY BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () =>
                          _navigateAndRefresh(const TransactionHistoryScreen()),
                      child: const Text("Transaction History"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
