import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/giftcards/buy/success_screen.dart';
import 'package:utilityhub/features/giftcards/services/giftcard_service.dart';

class ConfirmGiftCardPurchaseScreen extends StatefulWidget {
  final String brandName;
  final String cardType;
  final String amount; // USD amount

  const ConfirmGiftCardPurchaseScreen({
    super.key,
    required this.brandName,
    required this.cardType,
    required this.amount,
  });

  @override
  State<ConfirmGiftCardPurchaseScreen> createState() =>
      _ConfirmGiftCardPurchaseScreenState();
}

class _ConfirmGiftCardPurchaseScreenState
    extends State<ConfirmGiftCardPurchaseScreen> {
  bool loading = false;
  bool loadingQuote = true;

  String? nairaToCharge;
  String? fxRate;

  @override
  void initState() {
    super.initState();
    loadQuote();
  }

  Future<void> loadQuote() async {
    try {
      final quote = await GiftCardService().getQuote(
        brand: widget.brandName,
        cardType: widget.cardType,
        usdAmount: widget.amount,
      );

      setState(() {
        nairaToCharge = quote["nairaToCharge"].toString();
        fxRate = quote["fxRate"].toString();
        loadingQuote = false;
      });
    } catch (e) {
      setState(() => loadingQuote = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load price: $e")));
    }
  }

  Future<void> buyGiftCard() async {
    setState(() => loading = true);

    try {
      final code = await GiftCardService().buyGiftCard(
        brand: widget.brandName,
        cardType: widget.cardType,
        usdAmount: widget.amount,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GiftCardSuccessScreen(
            brandName: widget.brandName,
            amount: widget.amount,
            code: code,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Purchase failed: $e")));
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
                  color: const Color(0xFF0F1115),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.brandName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Gift Card Value: \$${widget.amount}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 12),

                    loadingQuote
                        ? const Text(
                            "Fetching NGN price...",
                            style: TextStyle(color: Colors.white54),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "FX Rate: ₦$fxRate per \$1",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "You will be charged: ₦$nairaToCharge",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading || loadingQuote ? null : buyGiftCard,
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Buy Gift Card"),
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
