import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // FIXED
import 'package:utilityhub/features/giftcards/services/giftcard_trade_service.dart';
import 'package:utilityhub/features/giftcards/trade/success_screen.dart';

class SubmitTradePage extends StatefulWidget {
  const SubmitTradePage({super.key});

  @override
  State<SubmitTradePage> createState() => _SubmitTradePageState();
}

class _SubmitTradePageState extends State<SubmitTradePage> {
  bool loading = false;

  String selectedBrand = "Amazon";
  String selectedCountry = "USA";
  String selectedCardType = "Physical";

  final amountCtrl = TextEditingController();

  double rateValue = 650;
  double calculatedValue = 0;

  List<File> selectedImages = [];

  Future<void> pickImages() async {
    final picker = ImagePicker(); // FIXED
    final picked = await picker.pickMultiImage();
    setState(() {
      selectedImages = picked.map((x) => File(x.path)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Trade")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
              onChanged: (_) {
                setState(() {
                  calculatedValue = double.tryParse(amountCtrl.text) == null
                      ? 0
                      : double.parse(amountCtrl.text) * rateValue;
                });
              },
            ),

            const SizedBox(height: 16),

            Text("Rate: ₦$rateValue"),
            Text("You will receive: ₦$calculatedValue"),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: pickImages,
              child: const Text("Upload Images"),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: loading
                  ? null // FIXED: disables button while loading
                  : () async {
                      setState(() => loading = true);

                      await GiftCardTradeService().submitTrade(
                        brand: selectedBrand,
                        country: selectedCountry,
                        cardType: selectedCardType,
                        amount: amountCtrl.text,
                        rate: rateValue.toString(),
                        valueInNaira: calculatedValue.toString(),
                        images: selectedImages,
                      );

                      setState(() => loading = false);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TradeSuccessScreen(
                            cardType: selectedCardType,
                            amount: amountCtrl.text,
                            payout: calculatedValue.toString(),
                          ),
                        ),
                      );
                    },
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit Trade"),
            ),
          ],
        ),
      ),
    );
  }
}
