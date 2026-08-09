import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utilityhub/features/wallet/services/wallet_service.dart';

class HeaderWallet extends StatelessWidget {
  final bool showWallet;

  const HeaderWallet({super.key, required this.showWallet});

  @override
  Widget build(BuildContext context) {
    if (!showWallet) return const SizedBox.shrink();

    final wallet = WalletService();

    return StreamBuilder<double>(
      stream: wallet.balanceStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _walletShimmer();

        final balance = snapshot.data ?? 0.0;
        final formatted = NumberFormat("#,##0").format(balance);

        return GestureDetector(
          onTap: () =>
              Navigator.of(context, rootNavigator: true).pushNamed("/wallet"),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "₦$formatted",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _walletShimmer() {
    return Container(
      width: 70,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      ),
    );
  }
}
