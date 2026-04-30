import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'card_container.dart';

class TransferFromCard extends StatelessWidget {
  final double? balance;

  const TransferFromCard({super.key, required this.balance});

  String _formatAmount(num amount) {
    final formatter = NumberFormat("#,##0.00");
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⭐ SAME LABEL STYLE AS TransferToCard
          Text(
            "Transfer From",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.95),
            ),
          ),

          const SizedBox(height: 12), // ⭐ SAME SPACING
          // ⭐ SAME TITLE STYLE AS TransferToCard
          Text(
            "GiftPay Wallet",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.95),
            ),
          ),

          const SizedBox(height: 6), // ⭐ SAME spacing pattern
          // ⭐ SAME META TEXT STYLE AS TransferToCard
          Text(
            balance == null
                ? "Balance: Loading..."
                : "Balance: ₦${_formatAmount(balance!)}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}
