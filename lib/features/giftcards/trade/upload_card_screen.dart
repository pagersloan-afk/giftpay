import 'package:flutter/material.dart';
import 'success_screen.dart';

class UploadCardScreen extends StatefulWidget {
  final String cardType;
  final String amount;
  final String payout;

  const UploadCardScreen({
    super.key,
    required this.cardType,
    required this.amount,
    required this.payout,
  });

  @override
  State<UploadCardScreen> createState() => _UploadCardScreenState();
}

class _UploadCardScreenState extends State<UploadCardScreen> {
  // Placeholder for images
  bool uploaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Card Images")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text("Tap to upload images")),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TradeSuccessScreen(
                        cardType: widget.cardType,
                        amount: widget.amount,
                        payout: widget.payout,
                      ),
                    ),
                  );
                },
                child: const Text("Submit Trade"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
