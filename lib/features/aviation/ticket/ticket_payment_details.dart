import 'package:flutter/material.dart';

class TicketPaymentDetails extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const TicketPaymentDetails({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final total = ticket["total"];
    final paymentMethod = ticket["paymentMethod"];

    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            paymentMethod == "wallet"
                ? "GiftPay Wallet"
                : "Debit / Credit Card",
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          Text(
            "₦$total",
            style: const TextStyle(
              color: Color(0xFF4FC3F7),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
