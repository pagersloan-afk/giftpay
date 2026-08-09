import 'package:flutter/material.dart';

class CheckoutFlightSummary extends StatelessWidget {
  final Map<String, dynamic> booking;

  const CheckoutFlightSummary({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final offer = booking["offer"];
    final segment = offer["itineraries"][0]["segments"][0];

    final airline = offer["validatingAirlineCodes"][0];
    final from = segment["departure"]["iataCode"];
    final to = segment["arrival"]["iataCode"];
    final depart = segment["departure"]["at"].substring(11, 16);
    final arrive = segment["arrival"]["at"].substring(11, 16);
    final duration = segment["duration"];

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
            airline,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "$from → $to",
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "$depart - $arrive  •  $duration",
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
