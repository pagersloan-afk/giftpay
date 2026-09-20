import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/giftcards/models/giftcard_brand.dart';
import 'package:utilityhub/features/giftcards/services/giftcard_service.dart';

class GiftCardSuccessScreen extends StatefulWidget {
  final GiftCardBrand product;
  final double amount;
  final String reference;
  final Map<String, dynamic> purchaseResult;
  final Map<String, dynamic>? codes;

  const GiftCardSuccessScreen({
    super.key,
    required this.product,
    required this.amount,
    required this.reference,
    required this.purchaseResult,
    required this.codes,
  });

  @override
  State<GiftCardSuccessScreen> createState() => _GiftCardSuccessScreenState();
}

class _GiftCardSuccessScreenState extends State<GiftCardSuccessScreen> {
  final GiftCardService _service = GiftCardService();

  Timer? _requeryTimer;

  late Map<String, dynamic> _purchaseResult;
  Map<String, dynamic>? _codes;

  bool _checkingStatus = false;
  bool _stoppedPolling = false;
  int _requeryAttempts = 0;

  static const int _maxRequeryAttempts = 100;

  @override
  void initState() {
    super.initState();

    _purchaseResult = Map<String, dynamic>.from(widget.purchaseResult);
    _codes = widget.codes;

    final initialStatus =
        _purchaseResult["status"]?.toString().toUpperCase() ?? "PENDING";

    // If the purchase was already completed and codes were supplied,
    // there is nothing else to query.
    if (initialStatus == "COMPLETED" && _hasCodes) {
      _stoppedPolling = true;
    } else {
      _startRequery();
    }
  }

  bool get _hasCodes {
    final cardNumber = _value("cardNumber");
    final pinCode = _value("pinCode");
    final claimUrl = _value("claimUrl");

    return cardNumber.isNotEmpty || pinCode.isNotEmpty || claimUrl.isNotEmpty;
  }

  String _value(String key) {
    final value = _codes?[key];

    if (value == null) {
      return "";
    }

    return value.toString();
  }

  Future<void> _startRequery() async {
    if (!mounted || _stoppedPolling) return;

    await _requeryPrestmit();

    if (!mounted || _stoppedPolling) return;

    _requeryTimer?.cancel();

    _requeryTimer = Timer(const Duration(seconds: 3), _startRequery);
  }

  Future<void> _requeryPrestmit() async {
    if (!mounted || _stoppedPolling) return;

    if (_requeryAttempts >= _maxRequeryAttempts) {
      _stoppedPolling = true;
      return;
    }

    if (_checkingStatus) return;

    _checkingStatus = true;
    _requeryAttempts++;

    try {
      final data = await _service.requeryPrestmitPurchase(
        reference: widget.reference,
      );

      if (!mounted) return;

      final status = data["status"]?.toString().toUpperCase() ?? "PENDING";

      final cards = data["cards"] is List
          ? List<dynamic>.from(data["cards"] as List)
          : <dynamic>[];

      if (status == "COMPLETED") {
        Map<String, dynamic>? fetchedCodes;

        // The backend may already have the cards. If it does, use them.
        if (cards.isNotEmpty) {
          fetchedCodes = {"cards": cards};

          // If the backend returns a single card object inside cards,
          // also expose the common fields directly for the existing UI.
          final firstCard = cards.first;

          if (firstCard is Map) {
            final card = Map<String, dynamic>.from(firstCard);

            fetchedCodes.addAll(card);
          }
        }

        // Fetch the actual gift-card codes from Prestmit as well.
        // This keeps the existing code-fetching flow intact.
        try {
          final providerCodes = await _service.fetchGiftCardCodes(
            reference: widget.reference,
          );

          if (providerCodes.isNotEmpty) {
            fetchedCodes = {...(fetchedCodes ?? {}), ...providerCodes};
          }
        } catch (_) {
          // The transaction is completed even if the code endpoint
          // is temporarily unavailable. Keep whatever the requery
          // response already provided.
        }

        if (!mounted) return;

        setState(() {
          _purchaseResult = {
            ..._purchaseResult,
            ...data,
            "status": "COMPLETED",
          };

          if (fetchedCodes != null && fetchedCodes.isNotEmpty) {
            _codes = fetchedCodes;
          }
        });

        _stoppedPolling = true;
        _requeryTimer?.cancel();
        return;
      }

      if (status == "REJECTED" ||
          status == "FAILED" ||
          status == "REFUNDED" ||
          status == "CANCELLED") {
        setState(() {
          _purchaseResult = {..._purchaseResult, ...data, "status": status};
        });

        _stoppedPolling = true;
        _requeryTimer?.cancel();
        return;
      }

      // Still pending/processing.
      setState(() {
        _purchaseResult = {..._purchaseResult, ...data, "status": status};
      });
    } catch (_) {
      // A temporary requery error should not make the purchase fail.
      // The next polling attempt will retry.
    } finally {
      _checkingStatus = false;
    }
  }

  @override
  void dispose() {
    _requeryTimer?.cancel();
    super.dispose();
  }

  Future<void> _copy(BuildContext context, String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$label copied")));
  }

  @override
  Widget build(BuildContext context) {
    final cardNumber = _value("cardNumber");
    final pinCode = _value("pinCode");
    final claimUrl = _value("claimUrl");
    final expireDate = _value("expireDate");

    final status =
        _purchaseResult["status"]?.toString().toUpperCase() ?? "PENDING";

    final completed =
        status == "COMPLETED" &&
        (cardNumber.isNotEmpty || pinCode.isNotEmpty || claimUrl.isNotEmpty);

    final failed =
        status == "REJECTED" ||
        status == "FAILED" ||
        status == "REFUNDED" ||
        status == "CANCELLED";

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Icon(
                completed
                    ? Icons.check_circle
                    : failed
                    ? Icons.error
                    : Icons.hourglass_top,
                color: completed
                    ? const Color(0xFF4FC3F7)
                    : failed
                    ? Colors.redAccent
                    : Colors.orangeAccent,
                size: 80,
              ),

              const SizedBox(height: 16),

              Text(
                completed
                    ? "Gift Card Delivered"
                    : failed
                    ? "Gift Card Purchase Failed"
                    : "Gift Card Purchase Processing",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                widget.product.name,
                style: const TextStyle(color: Colors.white70, fontSize: 17),
              ),

              const SizedBox(height: 8),

              Text(
                "Reference: ${widget.reference}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),

              const SizedBox(height: 24),

              if (completed)
                _buildCodesCard(
                  context,
                  cardNumber: cardNumber,
                  pinCode: pinCode,
                  claimUrl: claimUrl,
                  expireDate: expireDate,
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: failed
                          ? Colors.redAccent.withOpacity(.5)
                          : Colors.orangeAccent.withOpacity(.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (!failed)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Color(0xFF4FC3F7),
                            ),
                          ),
                        ),
                      Text(
                        failed
                            ? "The gift-card transaction was not completed."
                            : "Your payment was received and the "
                                  "gift-card transaction is still being "
                                  "processed.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                      if (!failed) ...[
                        const SizedBox(height: 12),
                        const Text(
                          "We are checking the transaction status "
                          "automatically. Please keep this screen open.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    _detailRow(
                      "Gift Card Value",
                      "${widget.amount.toStringAsFixed(2)} "
                          "${widget.product.currencyCode}",
                    ),
                    const SizedBox(height: 12),
                    _detailRow("SKU", widget.product.sku),
                    const SizedBox(height: 12),
                    _detailRow("Status", status),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/home', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3F7),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Done"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodesCard(
    BuildContext context, {
    required String cardNumber,
    required String pinCode,
    required String claimUrl,
    required String expireDate,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4FC3F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gift Card Details",
            style: TextStyle(
              color: Color(0xFF4FC3F7),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          if (cardNumber.isNotEmpty)
            _codeField(context, title: "Card Number", value: cardNumber),

          if (pinCode.isNotEmpty) ...[
            const SizedBox(height: 16),
            _codeField(context, title: "PIN", value: pinCode),
          ],

          if (claimUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            _codeField(context, title: "Claim URL", value: claimUrl),
          ],

          if (expireDate.isNotEmpty) ...[
            const SizedBox(height: 16),
            _codeField(
              context,
              title: "Expiration",
              value: expireDate,
              copyable: false,
            ),
          ],
        ],
      ),
    );
  }

  Widget _codeField(
    BuildContext context, {
    required String title,
    required String value,
    bool copyable = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              if (copyable)
                IconButton(
                  onPressed: () => _copy(context, value, title),
                  icon: const Icon(Icons.copy, color: Color(0xFF4FC3F7)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
