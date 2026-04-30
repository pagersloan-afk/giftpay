import 'package:flutter/material.dart';
import 'package:utilityhub/features/wallet/transfer/bank_tile.dart';

class BankSelectionScreen extends StatefulWidget {
  final List<dynamic> banks;

  const BankSelectionScreen({super.key, required this.banks});

  @override
  State<BankSelectionScreen> createState() => _BankSelectionScreenState();
}

class _BankSelectionScreenState extends State<BankSelectionScreen> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final filtered =
        widget.banks
            .where(
              (b) => b["name"].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList()
          ..sort((a, b) => a["name"].compareTo(b["name"]));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text("Select Bank"),
        backgroundColor: const Color(0xFF0A4D9C), // GiftPay Blue
        elevation: 0,
      ),

      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search bank...",
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (v) => setState(() => query = v),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // BANK LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final bank = filtered[i];

                return BankTile(
                  code: bank["code"],
                  name: bank["name"],
                  onTap: () => Navigator.pop(context, bank),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
