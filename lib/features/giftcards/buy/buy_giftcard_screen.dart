import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/giftcards/models/giftcard_brand.dart';
import 'package:utilityhub/features/giftcards/buy/confirm_purchase_screen.dart';
import 'package:utilityhub/features/giftcards/services/giftcard_service.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class BuyGiftCardScreen extends StatefulWidget {
  const BuyGiftCardScreen({super.key});

  @override
  State<BuyGiftCardScreen> createState() => _BuyGiftCardScreenState();
}

class _BuyGiftCardScreenState extends State<BuyGiftCardScreen> {
  final service = GiftCardService();

  GiftCardBrand? selectedBrand;
  String? selectedCardType;
  final amountCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderr(title: "Buy Gift Card"),

      body: AppResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Brand", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),

              FutureBuilder<List<GiftCardBrand>>(
                future: service.getBrands(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final brands = snapshot.data!;

                  return DropdownButtonFormField<GiftCardBrand>(
                    initialValue: selectedBrand,

                    // ⭐ FIX: remove border override
                    decoration: const InputDecoration(labelText: "Brand"),

                    // ⭐ FIX: force dark dropdown menu
                    dropdownColor: const Color(0xFF1F2937),

                    items: brands.map((b) {
                      return DropdownMenuItem(value: b, child: Text(b.name));
                    }).toList(),

                    onChanged: (v) {
                      setState(() {
                        selectedBrand = v;
                        selectedCardType = null;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              if (selectedBrand != null) ...[
                const Text("Select Card Type", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  initialValue: selectedCardType,

                  // ⭐ FIX: remove border override
                  decoration: const InputDecoration(labelText: "Card Type"),

                  // ⭐ FIX: force dark dropdown menu
                  dropdownColor: const Color(0xFF1F2937),

                  items: selectedBrand!.cardTypes.map((t) {
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

                // ⭐ FIX: remove border override
                decoration: const InputDecoration(labelText: "Amount"),
              ),

              const Spacer(),

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
                        builder: (_) => ConfirmGiftCardPurchaseScreen(
                          brandName:
                              "${selectedBrand!.name} (${selectedCardType!})",
                          amount: amountCtrl.text.trim(),
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
