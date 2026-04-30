import 'package:flutter/material.dart';
import 'upload_card_screen.dart';

class EnterTradeDetailsScreen extends StatefulWidget {
  final String cardType;

  const EnterTradeDetailsScreen({super.key, required this.cardType});

  @override
  State<EnterTradeDetailsScreen> createState() =>
      _EnterTradeDetailsScreenState();
}

class _EnterTradeDetailsScreenState extends State<EnterTradeDetailsScreen> {
  final amountCtrl = TextEditingController();

  // Example fixed rate for now
  final int rate = 1500;

  @override
  Widget build(BuildContext context) {
    final payout = (int.tryParse(amountCtrl.text) ?? 0) * rate;

    return Scaffold(
      appBar: AppBar(title: Text(widget.cardType)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Card Amount (USD)",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 20),

            // Payout display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "You will receive: ₦$payout",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (amountCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Enter amount")),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UploadCardScreen(
                        cardType: widget.cardType,
                        amount: amountCtrl.text.trim(),
                        payout: payout.toString(),
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
    );
  }
}
