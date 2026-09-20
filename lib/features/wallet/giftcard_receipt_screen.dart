import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:utilityhub/core/widgets/giftpay_background.dart';
import 'package:utilityhub/features/giftcards/services/giftcard_service.dart';

class GiftCardReceiptScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const GiftCardReceiptScreen({super.key, required this.transaction});

  @override
  State<GiftCardReceiptScreen> createState() => _GiftCardReceiptScreenState();
}

class _GiftCardReceiptScreenState extends State<GiftCardReceiptScreen> {
  final GiftCardService _service = GiftCardService();

  bool _loading = true;
  String? _error;

  Map<String, dynamic> _purchase = {};
  Map<String, dynamic> _card = {};

  @override
  void initState() {
    super.initState();
    _loadReceipt();
  }

  // ============================================================
  // BASIC VALUE HELPERS
  // ============================================================

  String _stringValue(dynamic value) {
    if (value == null) return "";
    return value.toString().trim();
  }

  String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final result = _stringValue(value);

      if (result.isNotEmpty) {
        return result;
      }
    }

    return "";
  }

  // ============================================================
  // REFERENCE EXTRACTION
  // ============================================================

  String _extractReference() {
    final tx = widget.transaction;

    final candidates = [
      tx["reference"],
      tx["prestmitReference"],
      tx["transactionReference"],
      tx["providerReference"],
      tx["providerTransactionReference"],
      tx["prestmit_reference"],
      tx["transactionId"],
      tx["transaction_id"],
      tx["providerTransactionId"],
      tx["provider_transaction_id"],
    ];

    for (final candidate in candidates) {
      final value = _stringValue(candidate);

      if (value.isEmpty) continue;

      if (value.startsWith("prestmit:")) {
        return value.substring("prestmit:".length).trim();
      }

      return value;
    }

    final id = _stringValue(tx["id"]);

    if (id.startsWith("prestmit:")) {
      return id.substring("prestmit:".length).trim();
    }

    return "";
  }

  // ============================================================
  // LOAD COMPLETE RECEIPT
  // ============================================================

  Future<void> _loadReceipt() async {
    final reference = _extractReference();

    if (reference.isEmpty) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = "The gift-card transaction reference could not be found.";
      });

      return;
    }

    try {
      final data = await _service.requeryPrestmitPurchase(reference: reference);

      if (!mounted) return;

      final status = _stringValue(data["status"]).toUpperCase();

      final cards = data["cards"];

      Map<String, dynamic> card = {};

      if (cards is List && cards.isNotEmpty) {
        final first = cards.first;

        if (first is Map) {
          card = Map<String, dynamic>.from(first);
        }
      }

      setState(() {
        _purchase = {...data, "reference": reference, "status": status};

        _card = card;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  // ============================================================
  // LOCAL TRANSACTION DETAILS
  // ============================================================

  String get _title {
    return _firstNonEmpty([
      widget.transaction["title"],
      widget.transaction["description"],
      "Gift Card Purchase",
    ]);
  }

  String get _amount {
    final value = widget.transaction["amount"];

    if (value == null) {
      return "₦0.00";
    }

    try {
      final number = value is num
          ? value
          : num.parse(value.toString().replaceAll(",", ""));

      return "₦${NumberFormat("#,##0.00").format(number)}";
    } catch (_) {
      return "₦${value.toString()}";
    }
  }

  String get _date {
    final raw =
        widget.transaction["timestamp"] ??
        widget.transaction["date"] ??
        widget.transaction["createdAt"];

    if (raw == null) {
      return "Unknown";
    }

    DateTime? dateTime;

    if (raw is DateTime) {
      dateTime = raw;
    } else if (raw is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(raw);
    } else {
      final parsed = DateTime.tryParse(raw.toString());

      if (parsed != null) {
        dateTime = parsed;
      }
    }

    if (dateTime == null) {
      return raw.toString();
    }

    final day = dateTime.day.toString().padLeft(2, "0");
    final month = dateTime.month.toString().padLeft(2, "0");
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, "0");
    final minute = dateTime.minute.toString().padLeft(2, "0");

    return "$day/$month/$year  $hour:$minute";
  }

  String get _reference {
    final reference = _stringValue(_purchase["reference"]);

    if (reference.isNotEmpty) {
      return reference;
    }

    return _extractReference();
  }

  String get _status {
    final status = _stringValue(_purchase["status"]).toUpperCase();

    if (status.isNotEmpty) {
      return status;
    }

    return "PENDING";
  }

  String get _cardNumber {
    return _firstNonEmpty([_card["cardNumber"], _card["card_number"]]);
  }

  String get _pinCode {
    return _firstNonEmpty([_card["pinCode"], _card["pin"], _card["pin_code"]]);
  }

  String get _claimUrl {
    return _firstNonEmpty([_card["claimUrl"], _card["claim_url"]]);
  }

  String get _expireDate {
    return _firstNonEmpty([
      _card["expireDate"],
      _card["expiryDate"],
      _card["expirationDate"],
      _card["expire_date"],
    ]);
  }

  // ============================================================
  // COPY
  // ============================================================

  Future<void> _copy(BuildContext context, String value, String label) async {
    if (value.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: value));

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$label copied")));
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final completed = _status == "COMPLETED" && _card.isNotEmpty;

    final failed =
        _status == "FAILED" ||
        _status == "REJECTED" ||
        _status == "REFUNDED" ||
        _status == "CANCELLED";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GiftPayBackground(
        child: SafeArea(
          child: Center(
            child: Container(
              width: 520,
              constraints: const BoxConstraints(maxWidth: 520),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.18),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.30),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: _loading
                  ? _buildLoading()
                  : SingleChildScrollView(
                      child: _buildReceipt(
                        completed: completed,
                        failed: failed,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 45,
            height: 45,
            child: CircularProgressIndicator(color: Color(0xFF4FC3F7)),
          ),
          SizedBox(height: 24),
          Text(
            "Loading Gift Card Receipt...",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Fetching the latest transaction details.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECEIPT
  // ============================================================

  Widget _buildReceipt({required bool completed, required bool failed}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: completed
                ? Colors.green.withOpacity(0.15)
                : failed
                ? Colors.red.withOpacity(0.15)
                : Colors.orange.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            completed
                ? Icons.card_giftcard
                : failed
                ? Icons.error_outline
                : Icons.hourglass_top,
            size: 65,
            color: completed
                ? const Color(0xFF4FC3F7)
                : failed
                ? Colors.redAccent
                : Colors.orangeAccent,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          completed
              ? "Gift Card Receipt"
              : failed
              ? "Gift Card Purchase Failed"
              : "Gift Card Purchase",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          _title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),

        const SizedBox(height: 25),

        _buildDetailsCard(),

        const SizedBox(height: 20),

        if (completed && _card.isNotEmpty)
          _buildGiftCardDetails()
        else
          _buildStatusCard(failed: failed),

        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.20),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Close", style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TRANSACTION DETAILS CARD
  // ============================================================

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          _detailRow("Amount", _amount),
          const SizedBox(height: 12),
          _detailRow("Date", _date),
          const SizedBox(height: 12),
          _detailRow("Type", "Debit"),
          const SizedBox(height: 12),
          _detailRow("Status", _status),
          const SizedBox(height: 12),
          _detailRow("Reference", _reference),
        ],
      ),
    );
  }

  // ============================================================
  // GIFT CARD DETAILS
  // ============================================================

  Widget _buildGiftCardDetails() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gift Card Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 18),

          if (_cardNumber.isNotEmpty) _copyField("Card Number", _cardNumber),

          if (_pinCode.isNotEmpty) _copyField("PIN / Code", _pinCode),

          if (_claimUrl.isNotEmpty) _copyField("Claim URL", _claimUrl),

          if (_expireDate.isNotEmpty) _copyField("Expiry Date", _expireDate),
        ],
      ),
    );
  }

  // ============================================================
  // PENDING / FAILED
  // ============================================================

  Widget _buildStatusCard({required bool failed}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(
            failed ? Icons.error_outline : Icons.hourglass_top,
            size: 45,
            color: failed ? Colors.redAccent : Colors.orangeAccent,
          ),

          const SizedBox(height: 12),

          Text(
            failed
                ? "This gift-card purchase was not completed."
                : "This gift-card purchase is still being processed.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // COPY FIELD
  // ============================================================

  Widget _copyField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),

          const SizedBox(height: 6),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SelectableText(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Builder(
                  builder: (context) {
                    return IconButton(
                      onPressed: () {
                        _copy(context, value, title);
                      },
                      icon: const Icon(
                        Icons.copy,
                        color: Color(0xFF4FC3F7),
                        size: 20,
                      ),
                      tooltip: "Copy",
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            value.isEmpty ? "—" : value,
            textAlign: TextAlign.right,
            softWrap: true,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
