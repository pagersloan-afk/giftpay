import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:utilityhub/features/wallet/services/wallet_service.dart';

class HeaderWallet extends StatelessWidget {
  final bool showWallet;
  final bool compact;

  const HeaderWallet({super.key, this.showWallet = true, this.compact = false});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    if (!showWallet) {
      return const SizedBox.shrink();
    }

    final wallet = WalletService();

    return StreamBuilder<double>(
      stream: wallet.balanceStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _walletShimmer();
        }

        final balance = snapshot.data ?? 0.0;

        final formatted = NumberFormat('#,##0').format(balance);

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/wallet');
            },
            child: Container(
              height: compact ? 42 : 46,
              padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 13),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.085),
                    blue.withOpacity(0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(compact ? 13 : 14),
                border: Border.all(color: Colors.white.withOpacity(0.105)),
                boxShadow: [
                  BoxShadow(
                    color: blue.withOpacity(0.09),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: compact ? 28 : 30,
                    height: compact ? 28 : 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: blue.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: lightBlue,
                    ),
                  ),

                  if (!compact) ...[
                    const SizedBox(width: 9),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AVAILABLE BALANCE',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₦$formatted',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(width: 7),

                    Text(
                      '₦$formatted',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _walletShimmer() {
    return Container(
      width: compact ? 72 : 150,
      height: compact ? 42 : 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Center(
        child: SizedBox(
          width: 17,
          height: 17,
          child: CircularProgressIndicator(strokeWidth: 2, color: lightBlue),
        ),
      ),
    );
  }
}
