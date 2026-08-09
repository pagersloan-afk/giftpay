import 'package:flutter/material.dart';

class TicketPassengerDetails extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const TicketPassengerDetails({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final passenger = ticket["passenger"];
    final pnr = ticket["pnr"] ?? "PNR12345";

    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Passenger",
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${passenger["firstName"]} ${passenger["lastName"]}",
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "PNR: $pnr",
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
