import 'package:flutter/material.dart';

class CheckoutFareBreakdown extends StatelessWidget {
  final Map<String, dynamic> booking;

  const CheckoutFareBreakdown({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final price = double.parse(booking["offer"]["price"]["total"]);
    final tax = (price * 0.075).round();
    final serviceFee = 2500;
    final total = price + tax + serviceFee;

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
            "Fare Breakdown",
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),

          _row("Base Fare", "₦${price.round()}"),
          const SizedBox(height: 8),

          _row("Tax (7.5%)", "₦$tax"),
          const SizedBox(height: 8),

          _row("Service Fee", "₦$serviceFee"),
          const SizedBox(height: 14),

          _row("Total", "₦$total", highlight: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: highlight ? 16 : 14,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? const Color(0xFF4FC3F7) : Colors.white,
            fontSize: highlight ? 20 : 14,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
