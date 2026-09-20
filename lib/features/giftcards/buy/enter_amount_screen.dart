import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'confirm_purchase_screen.dart';
import 'package:utilityhub/features/giftcards/models/giftcard_brand.dart';

class EnterGiftCardAmountScreen extends StatefulWidget {
  final GiftCardBrand product;

  const EnterGiftCardAmountScreen({super.key, required this.product});

  @override
  State<EnterGiftCardAmountScreen> createState() =>
      _EnterGiftCardAmountScreenState();
}

class _EnterGiftCardAmountScreenState extends State<EnterGiftCardAmountScreen> {
  late final TextEditingController amountCtrl;

  @override
  void initState() {
    super.initState();
    amountCtrl = TextEditingController();
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    super.dispose();
  }

  List<String> get presetAmounts {
    final min = widget.product.minPrice;
    final max = widget.product.maxPrice;

    // Fixed-price product.
    if (min == max && min > 0) {
      return [min.toStringAsFixed(2)];
    }

    final candidates = <double>[1, 2, 5, 10, 25, 50, 100, 200];

    return candidates
        .where((amount) => amount >= min && amount <= max)
        .map((amount) => amount.toStringAsFixed(2))
        .toList();
  }

  void selectAmount(String value) {
    amountCtrl.text = value;
    setState(() {});
  }

  void continueToConfirm() {
    final value = double.tryParse(amountCtrl.text.trim());

    if (value == null || value <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a valid amount.")));
      return;
    }

    if (value < widget.product.minPrice || value > widget.product.maxPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Amount must be between "
            "${widget.product.minPrice.toStringAsFixed(2)} "
            "and "
            "${widget.product.maxPrice.toStringAsFixed(2)}.",
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmGiftCardPurchaseScreen(
          product: widget.product,
          amount: value,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = widget.product.currencyCode;

    return Scaffold(
      backgroundColor: const Color(0xFF05070A),

      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: const Color(0xFF0F1115),
        foregroundColor: Colors.white,
      ),

      body: AppResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: const Color(0xFF0F1115),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------------------------------
                // PRODUCT NAME
                // --------------------------------------------------
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                // --------------------------------------------------
                // SKU
                // --------------------------------------------------
                Text(
                  "SKU: ${widget.product.sku}",
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),

                const SizedBox(height: 8),

                // --------------------------------------------------
                // AVAILABLE RANGE
                // --------------------------------------------------
                Text(
                  "Available range: "
                  "${widget.product.minPrice.toStringAsFixed(2)}"
                  " - "
                  "${widget.product.maxPrice.toStringAsFixed(2)}"
                  " $currency",
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),

                const SizedBox(height: 24),

                // --------------------------------------------------
                // SELECT AMOUNT
                // --------------------------------------------------
                const Text(
                  "Select Amount",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                if (presetAmounts.isNotEmpty)
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
                                ? const Color(0xFF1E88E5)
                                : const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Text(
                            "$currency $value",
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 24),

                // --------------------------------------------------
                // MANUAL AMOUNT
                // --------------------------------------------------
                TextField(
                  controller: amountCtrl,

                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(
                    labelText: "Enter Amount ($currency)",

                    labelStyle: const TextStyle(color: Colors.white70),

                    border: const OutlineInputBorder(),

                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),

                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1E88E5)),
                    ),
                  ),

                  onChanged: (_) {
                    setState(() {});
                  },
                ),

                const SizedBox(height: 24),

                // --------------------------------------------------
                // CONTINUE BUTTON
                // --------------------------------------------------
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: continueToConfirm,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),

                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),

                    child: const Text("Continue"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
