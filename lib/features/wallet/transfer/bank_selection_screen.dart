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
  final TextEditingController searchCtrl = TextEditingController();
  final ScrollController scrollCtrl = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Normalize banks safely
    final banks = widget.banks.map((b) {
      final name = (b["name"] ?? "").toString();
      final code = (b["code"] ?? "").toString();
      return {"name": name, "code": code};
    }).toList();

    // Filter safely
    final filtered = banks.where((b) {
      final name = (b["name"] ?? "").toLowerCase();
      final code = (b["code"] ?? "").toLowerCase();
      final q = query.toLowerCase();
      return name.contains(q) || code.contains(q);
    }).toList();

    // Group alphabetically
    final Map<String, List<Map<String, String>>> grouped = {};
    for (var bank in filtered) {
      final name = (bank["name"] ?? "");
      final firstLetter = name.isNotEmpty
          ? name[0].toUpperCase()
          : "#"; // fallback group

      grouped.putIfAbsent(firstLetter, () => []);
      grouped[firstLetter]!.add(bank);
    }

    final sortedKeys = grouped.keys.toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text("Select Bank"),
        backgroundColor: const Color(0xFF0A4D9C),
        elevation: 0,
      ),

      body: Stack(
        children: [
          Column(
            children: [
              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),

                    // ⭐ Subtle border
                    border: Border.all(color: Colors.grey.shade300, width: 1),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchCtrl,

                    // ⭐ Visible typing
                    style: const TextStyle(color: Colors.black87),

                    decoration: InputDecoration(
                      hintText: "Search bank...",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),

                      // ⭐ Clear (X) button
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () {
                                searchCtrl.clear();
                                setState(() => query = "");
                              },
                            )
                          : null,

                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),

                    onChanged: (v) => setState(() => query = v),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // BANK LIST WITH GROUPING
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: sortedKeys.length,
                  itemBuilder: (_, index) {
                    final letter = sortedKeys[index];
                    final banksInGroup = grouped[letter]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ⭐ Alphabet header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),

                        // Bank tiles
                        ...banksInGroup.map((bank) {
                          return BankTile(
                            code: bank["code"]!,
                            name: bank["name"]!,
                            onTap: () => Navigator.pop(context, bank),
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),

          // ⭐ FAST SCROLL INDEX (iOS style) — FIXED WITH SCROLL VIEW
          Positioned(
            right: 4,
            top: 120,
            bottom: 20,
            child: SingleChildScrollView(
              child: Column(
                children: sortedKeys.map((letter) {
                  return GestureDetector(
                    onTap: () {
                      // Scroll to the section
                      final index = sortedKeys.indexOf(letter);
                      double offset = 0;

                      for (int i = 0; i < index; i++) {
                        offset += (grouped[sortedKeys[i]]!.length * 72) + 40;
                      }

                      scrollCtrl.animateTo(
                        offset,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        letter,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
