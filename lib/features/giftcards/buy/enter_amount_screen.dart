import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'confirm_purchase_screen.dart';

class EnterGiftCardAmountScreen extends StatefulWidget {
  final String brandName;

  const EnterGiftCardAmountScreen({super.key, required this.brandName});

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
          amount: amountCtrl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.brandName)),
      body: AppResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Amount",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Preset amounts
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
                                  ? Colors.blue
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "\$$value",
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Manual amount input
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Enter Amount (USD)",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: continueToConfirm,
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
