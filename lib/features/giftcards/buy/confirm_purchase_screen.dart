import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/giftcards/buy/success_screen.dart';
import 'package:utilityhub/features/giftcards/models/giftcard_brand.dart';
import 'package:utilityhub/features/giftcards/services/giftcard_service.dart';

class ConfirmGiftCardPurchaseScreen extends StatefulWidget {
  final GiftCardBrand product;
  final double amount;

  const ConfirmGiftCardPurchaseScreen({
    super.key,
    required this.product,
    required this.amount,
  });

  @override
  State<ConfirmGiftCardPurchaseScreen> createState() =>
      _ConfirmGiftCardPurchaseScreenState();
}

class _ConfirmGiftCardPurchaseScreenState
    extends State<ConfirmGiftCardPurchaseScreen> {
  final GiftCardService _service = GiftCardService();

  bool loading = false;
  bool loadingQuote = true;

  Map<String, dynamic>? quote;
  String? error;

  @override
  void initState() {
    super.initState();
    loadQuote();
  }

  Future<void> loadQuote() async {
    try {
      final result = await _service.getQuote(
        sku: widget.product.sku,
        price: widget.amount,
        quantity: 1,
      );

      if (!mounted) return;

      setState(() {
        quote = result;
        loadingQuote = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingQuote = false;
        error = e.toString();
      });
    }
  }

  Map<String, dynamic> _normalizePurchaseResult(Map<String, dynamic> result) {
    dynamic current = result;

    if (current is Map<String, dynamic> &&
        current["data"] is Map<String, dynamic>) {
      current = current["data"];
    }

    if (current is Map) {
      return Map<String, dynamic>.from(current);
    }

    return result;
  }

  String? _extractReference(Map<String, dynamic> result) {
    dynamic reference = result["reference"];

    if (reference != null && reference.toString().trim().isNotEmpty) {
      return reference.toString().trim();
    }

    final data = result["data"];

    if (data is Map) {
      reference = data["reference"];

      if (reference != null && reference.toString().trim().isNotEmpty) {
        return reference.toString().trim();
      }
    }

    return null;
  }

  Future<void> buyGiftCard() async {
    if (quote == null || loading) return;

    setState(() {
      loading = true;
    });

    try {
      final uniqueIdentifier = "GIFT-${DateTime.now().millisecondsSinceEpoch}";

      final rawResult = await _service.buyGiftCard(
        sku: widget.product.sku,
        price: widget.amount,
        quantity: 1,
        paymentMethod: "NAIRA",
        uniqueIdentifier: uniqueIdentifier,
      );

      if (!mounted) return;

      final result = _normalizePurchaseResult(rawResult);

      final reference = _extractReference(result);

      if (reference == null || reference.isEmpty) {
        throw Exception(
          "Prestmit created a response, but no transaction reference "
          "was found. Please check the transaction history before trying "
          "the purchase again.",
        );
      }

      final status = result["status"]?.toString().toUpperCase() ?? "PENDING";

      Map<String, dynamic>? codes;

      // If Prestmit completed immediately, fetch the codes now.
      // If it is still PENDING, GiftCardSuccessScreen will re-query
      // the backend until the transaction completes.
      if (status == "COMPLETED") {
        try {
          codes = await _service.fetchGiftCardCodes(reference: reference);
        } catch (_) {
          codes = null;
        }
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GiftCardSuccessScreen(
            product: widget.product,
            amount: widget.amount,
            reference: reference,
            purchaseResult: result,
            codes: codes,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Purchase failed: $e")));
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  String _formatNumber(dynamic value) {
    if (value == null) return "-";

    final number = value is num ? value : num.tryParse(value.toString());

    if (number == null) {
      return value.toString();
    }

    return NumberFormat("#,##0.00").format(number);
  }

  double _customerTotal() {
    if (quote == null) {
      throw Exception("Payment quote is not available.");
    }

    return _service.customerDebitAmount(quote!);
  }

  @override
  Widget build(BuildContext context) {
    final currency = widget.product.currencyCode;

    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Purchase")),
      body: AppResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1115),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "SKU: ${widget.product.sku}",
                  style: const TextStyle(color: Colors.white38),
                ),

                const SizedBox(height: 16),

                Text(
                  "Gift Card Value: "
                  "${widget.amount.toStringAsFixed(2)} $currency",
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),

                const SizedBox(height: 24),

                if (loadingQuote)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (error != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Unable to calculate payment",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        error!,
                        style: const TextStyle(color: Colors.white60),
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            loadingQuote = true;
                            error = null;
                          });

                          loadQuote();
                        },
                        child: const Text("Try Again"),
                      ),
                    ],
                  )
                else if (quote != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gift Card Value: "
                        "${widget.amount.toStringAsFixed(2)} $currency",
                        style: const TextStyle(color: Colors.white70),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Total: ₦${_formatNumber(_customerTotal())}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Payment Method: NAIRA",
                        style: TextStyle(color: Colors.white54),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : buyGiftCard,
                          child: loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Buy Gift Card"),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
