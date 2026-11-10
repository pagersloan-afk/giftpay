import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/transaction-history/transaction_history_screen.dart';
import 'package:utilityhub/features/wallet/services/wallet_service.dart';
import 'fund_wallet_screen.dart';
import 'withdraw_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late final WalletService wallet = WalletService();

  Future<void> _navigateAndRefresh(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, auth) {
        if (!auth.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        return Scaffold(
          appBar: AppBar(title: const Text('My Wallet')),
          body: AppResponsiveLayout(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 36),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                StreamBuilder<double>(
                  stream: wallet.walletBalanceStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return _balanceCard('Unable to load balance', error: true);
                    if (!snapshot.hasData) return _balanceCard('Loading your balance…', loading: true);
                    final amount = NumberFormat('#,##0.00', 'en_NG').format(snapshot.data ?? 0);
                    return _balanceCard('₦$amount');
                  },
                ),
                const SizedBox(height: 20),
                LayoutBuilder(builder: (context, constraints) {
                  final compact = constraints.maxWidth < 430;
                  final fund = _actionButton('Fund Wallet', Icons.add_rounded, true, () => _navigateAndRefresh(const FundWalletScreen()));
                  final withdraw = _actionButton('Withdraw', Icons.north_east_rounded, false, () => _navigateAndRefresh(const WithdrawScreen()));
                  return compact ? Column(children: [fund, const SizedBox(height: 12), withdraw]) : Row(children: [Expanded(child: fund), const SizedBox(width: 12), Expanded(child: withdraw)]);
                }),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.045), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(.09))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Row(children: [Icon(Icons.history_rounded, color: Color(0xFF7DD3FC)), SizedBox(width: 10), Text('Wallet activity', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))]),
                    const SizedBox(height: 7),
                    const Text('Review deposits, payments and withdrawals from your wallet.', style: TextStyle(color: Colors.white60, height: 1.45)),
                    const SizedBox(height: 14),
                    SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _navigateAndRefresh(const TransactionHistoryScreen()), icon: const Icon(Icons.receipt_long_rounded), label: const Text('View transaction history'))),
                  ]),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _balanceCard(String value, {bool loading = false, bool error = false}) => Container(
    padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF15385B), Color(0xFF0D1A2B), Color(0xFF101827)]),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(.28)),
      boxShadow: [BoxShadow(color: const Color(0xFF1478C8).withOpacity(.14), blurRadius: 28, offset: const Offset(0, 12))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF7DD3FC)), SizedBox(width: 9), Text('GIFTPAY WALLET', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700))]),
      const SizedBox(height: 26),
      const Text('Available balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
      const SizedBox(height: 8),
      if (loading) const SizedBox(height: 38, child: Align(alignment: Alignment.centerLeft, child: CircularProgressIndicator(color: Color(0xFF7DD3FC))))
      else Text(value, style: TextStyle(color: error ? Colors.orangeAccent : Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -.6)),
      const SizedBox(height: 18),
      Row(children: [Icon(Icons.lock_outline_rounded, size: 14, color: Colors.white.withOpacity(.55)), const SizedBox(width: 6), Text('Secure wallet • Real-time balance', style: TextStyle(color: Colors.white.withOpacity(.58), fontSize: 11))]),
    ]),
  );

  Widget _actionButton(String label, IconData icon, bool primary, VoidCallback onPressed) => SizedBox(
    height: 54,
    child: primary
      ? ElevatedButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label))
      : OutlinedButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label)),
  );
}
