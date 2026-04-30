import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class GiftCardRateCalculatorScreen extends StatefulWidget {
  const GiftCardRateCalculatorScreen({super.key});

  @override
  State<GiftCardRateCalculatorScreen> createState() =>
      _GiftCardRateCalculatorScreenState();
}

class _GiftCardRateCalculatorScreenState
    extends State<GiftCardRateCalculatorScreen> {
  final amountCtrl = TextEditingController();

  String selectedBrand = "Amazon";
  String selectedCountry = "USA";
  String selectedType = "Physical";

  String payout = "0";

  // Mock rates (replace with backend later)
  final Map<String, int> mockRates = {
    "Amazon-USA": 750,
    "Amazon-UK": 700,
    "Amazon-Global": 680,
    "Apple-USA": 800,
    "Apple-UK": 780,
    "Steam-Global": 650,
  };

  int getRate() {
    final key = "$selectedBrand-$selectedCountry";
    return mockRates[key] ?? 600;
  }

  void calculate() {
    if (amountCtrl.text.isEmpty) {
      setState(() => payout = "0");
      return;
    }

    final amount = int.tryParse(amountCtrl.text.trim()) ?? 0;
    final rate = getRate();

    setState(() {
      payout = (amount * rate).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderr(title: "Rate Calculator"),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // BRAND
            DropdownButtonFormField(
              initialValue: selectedBrand,

              // ⭐ FIX: remove border override
              decoration: const InputDecoration(labelText: "Brand"),

              // ⭐ FIX: force dark dropdown menu
              dropdownColor: const Color(0xFF1F2937),

              items: const [
                DropdownMenuItem(value: "Amazon", child: Text("Amazon")),
                DropdownMenuItem(value: "Apple", child: Text("Apple")),
                DropdownMenuItem(value: "Steam", child: Text("Steam")),
              ],
              onChanged: (v) {
                setState(() => selectedBrand = v!);
                calculate();
              },
            ),

            const SizedBox(height: 16),

            // COUNTRY
            DropdownButtonFormField(
              initialValue: selectedCountry,

              // ⭐ FIX
              decoration: const InputDecoration(labelText: "Country"),
              dropdownColor: const Color(0xFF1F2937),

              items: const [
                DropdownMenuItem(value: "USA", child: Text("USA")),
                DropdownMenuItem(value: "UK", child: Text("UK")),
                DropdownMenuItem(value: "Global", child: Text("Global")),
              ],
              onChanged: (v) {
                setState(() => selectedCountry = v!);
                calculate();
              },
            ),

            const SizedBox(height: 16),

            // TYPE
            DropdownButtonFormField(
              initialValue: selectedType,

              // ⭐ FIX
              decoration: const InputDecoration(labelText: "Card Type"),
              dropdownColor: const Color(0xFF1F2937),

              items: const [
                DropdownMenuItem(
                  value: "Physical",
                  child: Text("Physical Card"),
                ),
                DropdownMenuItem(value: "E-code", child: Text("E-code")),
              ],
              onChanged: (v) {
                setState(() => selectedType = v!);
                calculate();
              },
            ),

            const SizedBox(height: 16),

            // AMOUNT
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => calculate(),

              // ⭐ FIX
              decoration: const InputDecoration(labelText: "Card Amount (\$)"),
            ),

            const SizedBox(height: 32),

            // RESULT BOX
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  const Text(
                    "You Will Receive",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₦$payout",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Rate: ₦${getRate()} per \$1",
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
