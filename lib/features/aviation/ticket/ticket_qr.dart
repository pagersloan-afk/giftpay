import 'dart:typed_data';
import 'package:flutter/material.dart';

class TicketQr extends StatelessWidget {
  final List<int>? qr;

  const TicketQr({super.key, required this.qr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: qr == null
                ? const Icon(Icons.qr_code_2, size: 120, color: Colors.white)
                : Image.memory(
                    Uint8List.fromList(qr!), // ⭐ FIXED
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            "Scan at airport gate",
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
