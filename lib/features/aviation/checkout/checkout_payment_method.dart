import 'package:flutter/material.dart';

class CheckoutPaymentMethod extends StatelessWidget {
  final String paymentMethod;
  final ValueChanged<String?> onChanged;

  const CheckoutPaymentMethod({
    super.key,
    required this.paymentMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Method",
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: RadioListTile<String>(
              value: "wallet",
              groupValue: paymentMethod,
              onChanged: onChanged,
              activeColor: const Color(0xFF4FC3F7),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: const Text(
                "GiftPay Wallet",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: RadioListTile<String>(
              value: "card",
              groupValue: paymentMethod,
              onChanged: onChanged,
              activeColor: const Color(0xFF4FC3F7),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: const Text(
                "Debit / Credit Card",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
