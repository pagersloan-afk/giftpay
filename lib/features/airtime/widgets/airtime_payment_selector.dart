// lib/features/airtime/widgets/airtime_payment_selector.dart
import 'package:flutter/material.dart';

class AirtimePaymentSelector extends StatelessWidget {
  final bool useWallet;
  final Color themeColor;
  final ValueChanged<bool> onChanged;

  const AirtimePaymentSelector({
    super.key,
    required this.useWallet,
    required this.themeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<bool>(
            value: true,
            groupValue: useWallet,
            activeColor: themeColor,
            onChanged: (v) => onChanged(v!),
            title: const Text("Wallet"),
          ),
        ),
        Expanded(
          child: RadioListTile<bool>(
            value: false,
            groupValue: useWallet,
            activeColor: themeColor,
            onChanged: (v) => onChanged(v!),
            title: const Text("Card"),
          ),
        ),
      ],
    );
  }
}
