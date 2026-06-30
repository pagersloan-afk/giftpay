import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'confirm_purchase_screen.dart';

class EnterGiftCardAmountScreen extends StatefulWidget {
  final String brandName;
  final String cardType;

  const EnterGiftCardAmountScreen({
    super.key,
    required this.brandName,
    required this.cardType,
  });

  @override
  State<EnterGiftCardAmountScreen> createState() =>
      _EnterGiftCardAmountScreenState();
}

class _EnterGiftCardAmountScreenState extends State<EnterGiftCardAmountScreen> {
  final amountCtrl = TextEditingController();

  final presetAmounts = ["10", "25", "50", "100", "200"];

  void selectAmount(String value) {
    amountCtrl.text = value;
    setState(() {});
  }

  void continueToConfirm() {
    if (amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter or select an amount")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmGiftCardPurchaseScreen(
          brandName: widget.brandName,
          cardType: widget.cardType,
          amount: amountCtrl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070A),
      appBar: AppBar(
        title: Text(widget.brandName),
        backgroundColor: const Color(0xFF0F1115),
      ),

      body: AppResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DARK CARD CONTAINER
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1115), // ⭐ DARK BACKGROUND
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Amount",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // ⭐ FIXED
                      ),
                    ),

                    const SizedBox(height: 20),

                    // PRESET AMOUNTS
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: presetAmounts.map((value) {
                        final isSelected = amountCtrl.text == value;

                        return GestureDetector(
                          onTap: () => selectAmount(value),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1E88E5) // GiftPay blue
                                  : const Color(0xFF1F2937), // dark grey
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "\$$value",
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70, // ⭐ FIXED
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // MANUAL AMOUNT INPUT
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white), // ⭐ FIXED
                      decoration: const InputDecoration(
                        labelText: "Enter Amount (USD)",
                        labelStyle: TextStyle(color: Colors.white70), // ⭐ FIXED
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1E88E5)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // CONTINUE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: continueToConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Continue"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
