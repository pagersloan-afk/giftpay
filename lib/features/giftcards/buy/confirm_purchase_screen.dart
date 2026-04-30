import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/giftcards/buy/success_screen.dart';

class ConfirmGiftCardPurchaseScreen extends StatefulWidget {
  final String brandName;
  final String amount;

  const ConfirmGiftCardPurchaseScreen({
    super.key,
    required this.brandName,
    required this.amount,
  });

  @override
  State<ConfirmGiftCardPurchaseScreen> createState() =>
      _ConfirmGiftCardPurchaseScreenState();
}

class _ConfirmGiftCardPurchaseScreenState
    extends State<ConfirmGiftCardPurchaseScreen> {
  bool loading = false;

  Future<void> payForGiftCard() async {
    final amountInKobo = (int.parse(widget.amount) * 100).toString();

    setState(() => loading = true);

    try {
      await FlutterPaystackPlus.openPaystackPopup(
        customerEmail: "gift@example.com", // TODO: replace with real user email
        amount: amountInKobo,
        reference: DateTime.now().millisecondsSinceEpoch.toString(),

        // Web
        publicKey: kIsWeb ? "pk_test_xxx" : null,

        // Mobile
        secretKey: !kIsWeb ? "sk_test_xxx" : null,
        context: !kIsWeb ? context : null,

        onClosed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Payment cancelled")));
        },

        onSuccess: () async {
          // TODO: Call your backend or API to generate the real gift card code
          const generatedCode = "XXXX-XXXX-XXXX";

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GiftCardSuccessScreen(
                brandName: widget.brandName,
                amount: widget.amount,
                code: generatedCode,
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Payment error: $e")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Purchase")),
      body: AppResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
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
                    Text(
                      widget.brandName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Gift Card Value: \$${widget.amount}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "You will be charged in NGN based on your payment provider's USD rate.",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : payForGiftCard,
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Proceed to Payment"),
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
