import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/giftcards/buy/enter_amount_screen.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class BuyGiftCardScreen extends StatefulWidget {
  const BuyGiftCardScreen({super.key});

  @override
  State<BuyGiftCardScreen> createState() => _BuyGiftCardScreenState();
}

class _BuyGiftCardScreenState extends State<BuyGiftCardScreen> {
  String? selectedBrand;
  String? selectedCardType;
  final amountCtrl = TextEditingController();

  final brands = {
    "Amazon": ["USA", "UK", "Global"],
    "Apple": ["USA", "UK", "Canada"],
    "Steam": ["Global", "USA"],
    "Google Play": ["USA", "Global"],
    "PlayStation": ["USA", "UK"],
    "Xbox": ["USA", "Global"],
    "Netflix": ["Global"],
    "Spotify": ["Global"],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderr(title: "Buy Gift Card"),

      body: AppResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Brand", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedBrand,
                decoration: const InputDecoration(labelText: "Brand"),
                dropdownColor: const Color(0xFF1F2937),
                items: brands.keys.map((b) {
                  return DropdownMenuItem(value: b, child: Text(b));
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    selectedBrand = v;
                    selectedCardType = null;
                  });
                },
              ),

              const SizedBox(height: 24),

              if (selectedBrand != null) ...[
                const Text("Select Card Type", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: selectedCardType,
                  decoration: const InputDecoration(labelText: "Card Type"),
                  dropdownColor: const Color(0xFF1F2937),
                  items: brands[selectedBrand]!.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (v) {
                    setState(() => selectedCardType = v);
                  },
                ),

                const SizedBox(height: 24),
              ],

              const Text("Enter Amount (USD)", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),

              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedBrand == null ||
                        selectedCardType == null ||
                        amountCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Complete all fields")),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EnterGiftCardAmountScreen(
                          brandName: selectedBrand!,
                          cardType: selectedCardType!, // ⭐ FIXED
                        ),
                      ),
                    );
                  },
                  child: const Text("Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
