import 'package:flutter/material.dart';

class CheckoutPayButton extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String paymentMethod;

  const CheckoutPayButton({
    super.key,
    required this.booking,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final offer = booking["offer"];
    final price = double.parse(offer["price"]["total"]);
    final tax = (price * 0.075).round();
    final serviceFee = 2500;
    final total = price + tax + serviceFee;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4FC3F7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 6,
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            "/aviation/ticket",
            arguments: {
              "booking": booking,
              "total": total,
              "paymentMethod": paymentMethod,
            },
          );
        },
        child: const Text(
          "Pay & Generate Ticket",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
