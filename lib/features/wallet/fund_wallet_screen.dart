import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ⭐ Web-safe HTML API

import 'package:utilityhub/core/widgets/app_responsive_layout.dart';

// ⭐ Moniepoint Virtual Account
import 'package:utilityhub/features/wallet/services/virtual_account_service.dart';
import 'package:utilityhub/features/wallet/models/virtual_account.dart';

class FundWalletScreen extends StatefulWidget {
  const FundWalletScreen({super.key});

  @override
  State<FundWalletScreen> createState() => _FundWalletScreenState();
}

class _FundWalletScreenState extends State<FundWalletScreen> {
  // ⭐ Virtual Account
  VirtualAccount? virtualAccount;
  bool vaLoading = true;

  @override
  void initState() {
    super.initState();
    loadVirtualAccount();
  }

  Future<void> loadVirtualAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => vaLoading = false);
      return;
    }

    try {
      final va = await VirtualAccountService().getVirtualAccount(user.uid);
      if (!mounted) return;
      setState(() {
        virtualAccount = va;
        vaLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => vaLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fund Wallet")),
      body: AppResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF142B46), Color(0xFF0B1524), Color(0xFF101827)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(.28)),
                  boxShadow: [BoxShadow(color: const Color(0xFF1478C8).withOpacity(.13), blurRadius: 28, offset: const Offset(0, 12))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white.withOpacity(.09), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.account_balance_rounded, color: Color(0xFF7DD3FC))),
                      const SizedBox(width: 14),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Add money to GiftPay', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)), SizedBox(height: 4), Text('Fund your wallet with a bank transfer', style: TextStyle(color: Colors.white70, fontSize: 13))])),
                    ]),
                    const SizedBox(height: 24),
                    if (vaLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(22), child: CircularProgressIndicator(color: Color(0xFF7DD3FC))))
                    else if (virtualAccount != null) ...[
                      const Text('YOUR DEDICATED GIFTpay ACCOUNT', style: TextStyle(color: Color(0xFF93C5FD), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),
                      _accountRow('Bank', virtualAccount!.bankName),
                      const SizedBox(height: 12),
                      _accountRow('Account name', virtualAccount!.accountName),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(.24), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(.10))),
                        child: Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('ACCOUNT NUMBER', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.1)), const SizedBox(height: 6), SelectableText(virtualAccount!.accountNumber, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: 1.2))])),
                          IconButton(tooltip: 'Copy account number', onPressed: () => Clipboard.setData(ClipboardData(text: virtualAccount!.accountNumber)).then((_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account number copied'))); }), icon: const Icon(Icons.copy_rounded, color: Color(0xFF7DD3FC))),
                        ]),
                      ),
                    ] else ...[
                      const Text('Your dedicated bank account is not available yet.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      const Text('Please contact GiftPay support if you believe your account should already be active.', style: TextStyle(color: Colors.white70, height: 1.5)),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(onPressed: loadVirtualAccount, icon: const Icon(Icons.refresh), label: const Text('Try again')),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white.withOpacity(.045), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(.09))),
                child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.shield_outlined, color: Color(0xFF7DD3FC)),
                  SizedBox(width: 12),
                  Expanded(child: Text('Transfer from any bank using the account details above. Your wallet is credited automatically after the transfer is received and confirmed. You do not need to enter an amount or start a card payment here.', style: TextStyle(color: Colors.white70, height: 1.55, fontSize: 13))),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _accountRow(String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: 112, child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13))),
      Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
    ],
  );

}
