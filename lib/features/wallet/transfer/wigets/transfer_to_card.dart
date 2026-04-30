import 'package:flutter/material.dart';
import 'card_container.dart';

class TransferToCard extends StatelessWidget {
  final String? selectedBankName;
  final String? resolvedName;
  final bool resolving;

  final VoidCallback onSelectBank;
  final ValueChanged<String> onAccountChanged;

  final TextEditingController accountController;

  const TransferToCard({
    super.key,
    required this.selectedBankName,
    required this.resolvedName,
    required this.resolving,
    required this.onSelectBank,
    required this.onAccountChanged,
    required this.accountController,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Transfer To",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.95),
            ),
          ),

          const SizedBox(height: 12),

          GestureDetector(
            onTap: onSelectBank,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      selectedBankName ?? "Select Bank",
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedBankName == null
                            ? Colors.white.withOpacity(0.45)
                            : Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: accountController,
            keyboardType: TextInputType.number,
            maxLength: 10,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Account Number",
              labelStyle: TextStyle(color: Colors.white70),
              counterText: "",
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: const Color(0xFF4FC3F7),
                  width: 1.4,
                ),
              ),
            ),
            onChanged: onAccountChanged,
          ),

          const SizedBox(height: 10),

          if (resolving)
            const Text("Resolving...", style: TextStyle(color: Colors.orange))
          else if (resolvedName != null)
            Text(
              resolvedName!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
        ],
      ),
    );
  }
}
