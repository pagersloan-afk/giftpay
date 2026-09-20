import 'package:flutter/material.dart';

import '../models/giftcard_trade.dart';

class TradeSuccessScreen extends StatelessWidget {
  final GiftCardTrade trade;

  const TradeSuccessScreen({super.key, required this.trade});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF75A1FF),
                  size: 82,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Trade Submitted',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your gift card has been submitted for verification.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, height: 1.5),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF273D68)),
                  ),
                  child: Column(
                    children: [
                      _row('Gift Card', trade.brand),
                      _row('Amount', '\$${trade.amount}'),
                      _row('Rate', '₦${trade.rate}'),
                      _row('Estimated payout', '₦${trade.valueInNaira}'),
                      _row('Status', _statusLabel(trade.status)),
                      _row('Reference', trade.providerReference),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'The final payout is determined after Prestmit completes its verification. Your GiftPay wallet will be credited only after the trade is completed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6BB8),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';

      case 'rejected':
        return 'Rejected';

      default:
        return 'Pending Review';
    }
  }
}
