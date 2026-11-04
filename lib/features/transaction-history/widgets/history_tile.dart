import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';

import '../utils/history_icon_mapper.dart';

// Screens
import 'package:utilityhub/features/electricity/receipt_screen.dart';
import 'package:utilityhub/features/airtime/airtime_receipt_screen.dart';
import 'package:utilityhub/features/data/data_receipt_screen.dart';
import 'package:utilityhub/features/cable/cable_receipt_screen.dart';
import 'package:utilityhub/features/wallet/wallet_receipt_screen.dart';
import 'package:utilityhub/features/transaction-history/screens/paystack_wallet_receipt_screen.dart';
import 'package:utilityhub/features/betting/betting_receipt_screen.dart';
import 'package:utilityhub/features/wallet/giftcard_receipt_screen.dart';

class HistoryTile extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final String formattedDate;

  const HistoryTile({
    super.key,
    required this.transaction,
    required this.formattedDate,
  });

  // ============================================================
  // CURRENCY FORMATTING
  // ============================================================

  String _formatAmount(dynamic value) {
    if (value == null) {
      return "₦0.00";
    }

    final number = value is num
        ? value
        : num.tryParse(value.toString().replaceAll(",", ""));

    if (number == null) {
      return "₦${value.toString()}";
    }

    return "₦${NumberFormat("#,##0.00").format(number)}";
  }

  // ============================================================
  // PRESTMIT SELL DETECTION
  // ============================================================

  bool _isPrestmitSell() {
    if (transaction["prestmitSell"] == true) {
      return true;
    }

    final type = transaction["type"]?.toString().toLowerCase() ?? "";
    final title = transaction["title"]?.toString().toLowerCase() ?? "";

    return type == "giftcard_sell" || title.contains("gift card sale");
  }

  bool _isRejectedPrestmitSell() {
    if (!_isPrestmitSell()) {
      return false;
    }

    final status = transaction["status"]?.toString().toLowerCase() ?? "";

    return status == "rejected" || transaction["isRejectedSell"] == true;
  }

  bool _isCompletedPrestmitSell() {
    if (!_isPrestmitSell()) {
      return false;
    }

    final status = transaction["status"]?.toString().toLowerCase() ?? "";

    return status == "completed" || transaction["isCompletedSell"] == true;
  }

  // ============================================================
  // BULK TRANSFER DETECTION
  // ============================================================

  bool _isBulkTransfer() {
    return transaction["type"]?.toString().toLowerCase() == "bulk_transfer";
  }

  // ============================================================
  // FOOD ORDER DETECTION
  // ============================================================

  bool _isFoodOrder() {
    final category = (transaction["category"] ?? "")
        .toString()
        .toLowerCase()
        .trim();

    final type = (transaction["type"] ?? "").toString().toLowerCase().trim();

    final title = (transaction["title"] ?? "").toString().toLowerCase().trim();

    return category == "food_order" ||
        category == "food_order_refund" ||
        category == "food_refund" ||
        type == "food_order" ||
        type == "food_order_refund" ||
        type == "food_refund" ||
        title.startsWith("giftpay food order");
  }

  bool _isPaystackDvaCredit([Map<String, dynamic>? source]) {
    final tx = source ?? transaction;
    return (tx["provider"] ?? "").toString().toLowerCase() == "paystack" &&
        (tx["channel"] ?? "").toString().toLowerCase() == "dedicated_nuban" &&
        (tx["type"] ?? "").toString().toLowerCase() == "credit";
  }

  String _displayTitle() {
    if (_isPaystackDvaCredit()) {
      final sender = (transaction["senderName"] ?? "").toString().trim();
      return sender.isNotEmpty ? "from – $sender" : "Wallet Funding";
    }
    return transaction["title"]?.toString() ?? "Transaction";
  }

  // ============================================================
  // DISPLAY COLOR
  // ============================================================

  Color _prestmitSellColor() {
    if (_isRejectedPrestmitSell()) {
      return Colors.red;
    }

    if (_isCompletedPrestmitSell()) {
      return Colors.green;
    }

    return Colors.orange;
  }

  Color _bulkTransferColor() {
    final status = transaction["status"]?.toString().toLowerCase() ?? "";

    if (status == "completed" || status == "success") {
      return Colors.green;
    }

    if (status == "failed" || status == "rejected") {
      return Colors.red;
    }

    return Colors.indigo;
  }

  // ============================================================
  // DISPLAY ICON
  // ============================================================

  IconData _prestmitSellIcon() {
    if (_isRejectedPrestmitSell()) {
      return Icons.cancel_outlined;
    }

    if (_isCompletedPrestmitSell()) {
      return Icons.check_circle_outline;
    }

    return Icons.card_giftcard;
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final title = _displayTitle();
    final type = transaction["type"]?.toString() ?? "transaction";
    final amount = _formatAmount(transaction["amount"]);

    final bool isPrestmitSell = _isPrestmitSell();
    final bool isBulkTransfer = _isBulkTransfer();
    final bool isFoodOrder = _isFoodOrder();

    const foodGold = Color(0xFFFFC66D);

    final dynamic iconData = isFoodOrder
        ? {
            "icon": const Icon(
              Icons.restaurant_rounded,
              color: foodGold,
              size: 20,
            ),
            "color": foodGold,
          }
        : isPrestmitSell
        ? {
            "icon": Icon(_prestmitSellIcon(), color: Colors.white, size: 20),
            "color": _prestmitSellColor(),
          }
        : isBulkTransfer
        ? {
            "icon": const Icon(
              Icons.account_balance,
              color: Colors.white,
              size: 20,
            ),
            "color": _bulkTransferColor(),
          }
        : HistoryIconMapper.detect(title, type);

    final icon = iconData["icon"] as Widget;
    final color = iconData["color"] as Color;

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),

      // FOOD ORDER ICON:
      // Same fork-and-spoon icon and warm-gold styling
      // used in the Recent Transactions dashboard widget.
      leading: CircleAvatar(
        backgroundColor: isFoodOrder ? foodGold.withOpacity(0.15) : color,
        child: icon,
      ),

      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formattedDate, style: const TextStyle(fontSize: 12)),

          if (isPrestmitSell)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                _sellStatusLabel(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _prestmitSellColor(),
                ),
              ),
            ),

          if (isBulkTransfer)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                _bulkTransferStatusLabel(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _bulkTransferColor(),
                ),
              ),
            ),
        ],
      ),

      trailing: Text(
        amount,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),

      onTap: () {
        if (isBulkTransfer) {
          _showBulkTransferDetails(context);
        } else {
          _openReceipt(context);
        }
      },
    );
  }

  // ============================================================
  // SELL STATUS LABEL
  // ============================================================

  String _sellStatusLabel() {
    final status = transaction["status"]?.toString().toLowerCase() ?? "";

    switch (status) {
      case "completed":
        return "COMPLETED";
      case "rejected":
        return "REJECTED";
      case "pending":
        return "PENDING";
      default:
        return status.isEmpty ? "SELL TRANSACTION" : status.toUpperCase();
    }
  }

  // ============================================================
  // BULK TRANSFER STATUS LABEL
  // ============================================================

  String _bulkTransferStatusLabel() {
    final status = transaction["status"]?.toString().toLowerCase() ?? "";

    switch (status) {
      case "completed":
      case "success":
        return "COMPLETED";
      case "failed":
      case "rejected":
        return "FAILED";
      case "pending":
      case "submitting":
      case "processing":
      case "in_progress":
        return "PROCESSING";
      case "partially_completed":
      case "partial":
        return "PARTIALLY COMPLETED";
      default:
        return status.isEmpty ? "BULK TRANSFER" : status.toUpperCase();
    }
  }

  // ============================================================
  // PRESTMIT SELL DETAILS
  // ============================================================

  Future<void> _showPrestmitSellDetails(BuildContext context) async {
    final brand = transaction["brand"]?.toString() ?? "";
    final country = transaction["country"]?.toString() ?? "";
    final cardType = transaction["cardType"]?.toString() ?? "";
    final providerReference =
        transaction["providerReference"]?.toString() ?? "";
    final cardAmount = transaction["cardAmount"] ?? transaction["amount"] ?? 0;
    final rate = transaction["rate"] ?? 0;
    final valueInNaira =
        transaction["valueInNaira"] ?? transaction["amount"] ?? 0;
    final payoutMethod = transaction["payoutMethod"]?.toString() ?? "";
    final rejectionReason = transaction["rejectionReason"]?.toString() ?? "";
    final status = transaction["status"]?.toString().toUpperCase() ?? "UNKNOWN";

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                status == "REJECTED"
                    ? Icons.cancel_outlined
                    : status == "COMPLETED"
                    ? Icons.check_circle_outline
                    : Icons.card_giftcard,
                color: status == "REJECTED"
                    ? Colors.red
                    : status == "COMPLETED"
                    ? Colors.green
                    : Colors.orange,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  status == "REJECTED"
                      ? "Gift Card Sale Rejected"
                      : "Gift Card Sale",
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (brand.isNotEmpty) _detailRow("Brand", brand),
                if (country.isNotEmpty) _detailRow("Country", country),
                if (cardType.isNotEmpty) _detailRow("Card Type", cardType),
                _detailRow("Card Value", _formatAmount(cardAmount)),
                _detailRow("Rate", rate.toString()),
                _detailRow("Expected Payout", _formatAmount(valueInNaira)),
                if (payoutMethod.isNotEmpty)
                  _detailRow("Payout Method", payoutMethod),
                if (providerReference.isNotEmpty)
                  _detailRow("Reference", providerReference),
                const SizedBox(height: 12),
                Text(
                  "Status",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: status == "REJECTED"
                        ? Colors.red
                        : status == "COMPLETED"
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                if (status == "REJECTED" && rejectionReason.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    "Rejection Reason",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      rejectionReason,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BULK TRANSFER DETAILS
  // ============================================================

  Future<void> _showBulkTransferDetails(BuildContext context) async {
    final reference = transaction["batchReference"]?.toString() ?? "";

    final status = transaction["status"]?.toString() ?? "unknown";

    final rawItems = transaction["items"];

    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
        : <Map<String, dynamic>>[];

    final itemCount = transaction["itemCount"] ?? items.length;

    final totalAmount =
        transaction["totalAmount"] ?? transaction["amount"] ?? 0;

    final totalFees = transaction["totalFees"] ?? 0;

    final totalDebited =
        transaction["totalDebited"] ?? transaction["amount"] ?? 0;

    final refunded = transaction["refunded"] == true;

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Bulk Transfer Details"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow("Status", status.toUpperCase()),
                  if (reference.isNotEmpty)
                    _detailRow("Batch Reference", reference),
                  _detailRow("Recipients", itemCount.toString()),
                  _detailRow("Transfer Amount", _formatAmount(totalAmount)),
                  _detailRow("Fees", _formatAmount(totalFees)),
                  _detailRow("Total Debited", _formatAmount(totalDebited)),
                  if (refunded)
                    _detailRow(
                      "Refund Amount",
                      _formatAmount(transaction["refundAmount"]),
                    ),
                  if ((transaction["refundReason"] ?? "").toString().isNotEmpty)
                    _detailRow("Refund Reason", transaction["refundReason"]),
                  const SizedBox(height: 16),
                  const Text(
                    "Recipients",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  if (items.isEmpty)
                    const Text("No recipient details available.")
                  else
                    ...items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;

                      final name =
                          item["accountName"]?.toString() ??
                          item["name"]?.toString() ??
                          "Recipient";

                      final account =
                          item["accountNumber"]?.toString() ??
                          item["accountNo"]?.toString() ??
                          "";

                      final bank =
                          item["bankName"]?.toString() ??
                          item["bank"]?.toString() ??
                          "";

                      final amount = item["amount"] ?? 0;

                      final itemStatus =
                          item["status"]?.toString() ?? "unknown";

                      final normalizedStatus = itemStatus.toLowerCase();

                      final statusColor =
                          normalizedStatus == "success" ||
                              normalizedStatus == "completed"
                          ? Colors.green
                          : normalizedStatus == "failed" ||
                                normalizedStatus == "rejected"
                          ? Colors.red
                          : Colors.orange;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${index + 1}. $name",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (account.isNotEmpty) Text("Account: $account"),
                              if (bank.isNotEmpty) Text("Bank: $bank"),
                              Text("Amount: ${_formatAmount(amount)}"),
                              const SizedBox(height: 3),
                              Text(
                                "Status: ${itemStatus.toUpperCase()}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                              if ((item["failureReason"] ?? "")
                                  .toString()
                                  .isNotEmpty)
                                Text(
                                  "Reason: ${item["failureReason"]}",
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(String label, dynamic value) {
    final text = value?.toString() ?? "";

    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOOD ORDER RECEIPT
  // ============================================================

  Future<void> _showFoodOrderReceipt(BuildContext context) async {
    final orderId =
        (transaction["orderId"] ??
                transaction["reference"] ??
                transaction["id"]?.toString().replaceFirst(
                  RegExp(r"_debit$"),
                  "",
                ) ??
                "")
            .toString()
            .trim();

    final status =
        (transaction["orderStatus"] ?? transaction["status"] ?? "pending")
            .toString()
            .toLowerCase();

    final paymentStatus = (transaction["paymentStatus"] ?? "reserved")
        .toString()
        .toLowerCase();

    String? deliveryCode;
    String? codeError;

    // Retrieve the delivery code while the order is active.
    // The backend enforces ownership, payment, and order status.
    if (orderId.isNotEmpty && paymentStatus == "reserved") {
      try {
        final user = FirebaseAuth.instance.currentUser;
        final token = await user?.getIdToken();

        if (token != null && token.isNotEmpty) {
          final response = await http.get(
            Uri.parse(ApiConfig.api("/api/food/orders/$orderId/delivery-code")),
            headers: {
              "Authorization": "Bearer $token",
              "Accept": "application/json",
            },
          );

          final body = jsonDecode(response.body);

          if (response.statusCode >= 200 &&
              response.statusCode < 300 &&
              body is Map &&
              body["status"] == true) {
            deliveryCode = body["deliveryCode"]?.toString();
          } else if (body is Map) {
            codeError = body["message"]?.toString();
          }
        }
      } catch (_) {
        codeError = "Could not load the delivery code. Please try again.";
      }
    }

    if (!context.mounted) return;

    final history = transaction["statusHistory"] is List
        ? List<dynamic>.from(transaction["statusHistory"] as List)
        : <dynamic>[];

    final amount = _formatAmount(transaction["amount"]);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101827),
        title: const Text(
          "Food order receipt",
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Order: $orderId",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Order status: ${status.replaceAll("_", " ").toUpperCase()}",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                "Payment: ${paymentStatus.toUpperCase()}",
                style: const TextStyle(color: Colors.white70),
              ),
              if (deliveryCode != null) ...[
                const SizedBox(height: 16),
                const Text(
                  "Your delivery confirmation code",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  deliveryCode,
                  style: const TextStyle(
                    color: Color(0xFF4FC3F7),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Share this code only when your order arrives.",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ] else if (codeError != null) ...[
                const SizedBox(height: 12),
                Text(
                  codeError!,
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 12,
                  ),
                ),
              ],
              if (history.isNotEmpty) ...[
                const SizedBox(height: 18),
                const Text(
                  "Order progress",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ...history.map((entry) {
                  final item = entry is Map ? entry : <dynamic, dynamic>{};

                  final label = (item["status"] ?? "updated")
                      .toString()
                      .replaceAll("_", " ");

                  final at = item["at"]?.toString() ?? "";

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Color(0xFF4FC3F7),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${label.toUpperCase()}${at.isNotEmpty ? "\n$at" : ""}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OPEN RECEIPT
  // ============================================================

  Future<void> _openReceipt(BuildContext context) async {
    if (transaction["category"]?.toString() == "food_order" ||
        transaction["type"]?.toString() == "food_order") {
      await _showFoodOrderReceipt(context);
      return;
    }

    // ==========================================================
    // PRESTMIT SELL
    // ==========================================================

    if (_isPrestmitSell()) {
      if (_isRejectedPrestmitSell()) {
        await _showPrestmitSellDetails(context);
        return;
      }

      final status = transaction["status"]?.toString().toLowerCase() ?? "";

      if (status != "completed") {
        await _showPrestmitSellDetails(context);
        return;
      }
    }

    final id = transaction["id"];
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final userId = user.uid;

    final titleLower = (transaction["title"] ?? "").toString().toLowerCase();

    // ==========================================================
    // ELECTRICITY
    // ==========================================================

    if (titleLower.startsWith("electricity")) {
      final snap = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("transactions")
          .doc(id)
          .get();

      final fullTx = snap.data() ?? {};

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptScreen(
            token: fullTx["token"] ?? "",
            amount: fullTx["amount"]?.toString() ?? "0",
            customerName: fullTx["customerName"] ?? "Customer",
            meterNumber: fullTx["meterNumber"] ?? "Unknown",
            timestamp: fullTx["timestamp"] ?? 0,
            buildPdf: () async => Uint8List(0),
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // LOAD WALLET TRANSACTION
    // ==========================================================

    final walletDoc = await FirebaseFirestore.instance
        .collection("wallets")
        .doc(userId)
        .get();

    final walletData = walletDoc.data() ?? {};
    final txList = walletData["transactions"] as List<dynamic>? ?? [];

    Map<String, dynamic> realTx = {};

    for (final item in txList) {
      if (item is Map) {
        final candidate = Map<String, dynamic>.from(item);

        if (candidate["id"]?.toString() == id?.toString()) {
          realTx = candidate;
          break;
        }
      }
    }

    // ==========================================================
    // PAYSTACK DEDICATED-ACCOUNT WALLET CREDIT
    // ==========================================================

    final paystackTx = realTx.isNotEmpty ? realTx : transaction;
    if (_isPaystackDvaCredit(paystackTx)) {
      final reference = (paystackTx["reference"] ?? paystackTx["id"] ?? "")
          .toString()
          .trim();
      var details = Map<String, dynamic>.from(paystackTx);

      // The backend verifies that this reference belongs to the signed-in user.
      if (reference.isNotEmpty) {
        try {
          final idToken = await user.getIdToken();
          final uri = Uri.parse(
            ApiConfig.api(
              "/api/virtual-account/transactions/${Uri.encodeComponent(reference)}",
            ),
          );
          final response = await http.get(
            uri,
            headers: {
              "Accept": "application/json",
              if (idToken != null) "Authorization": "Bearer $idToken",
            },
          );
          if (response.statusCode >= 200 && response.statusCode < 300) {
            final decoded = jsonDecode(response.body);
            if (decoded is Map && decoded["status"] == true && decoded["data"] is Map) {
              details = {
                ...details,
                ...Map<String, dynamic>.from(decoded["data"] as Map),
              };
            }
          }
        } catch (error) {
          debugPrint("Paystack receipt detail lookup failed: $error");
        }
      }

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaystackWalletReceiptScreen(transaction: details),
        ),
      );
      return;
    }

    // ==========================================================
    // GIFT CARD
    // ==========================================================

    final realTitle = (realTx["title"] ?? transaction["title"] ?? "")
        .toString()
        .toLowerCase();

    final realType = (realTx["type"] ?? transaction["type"] ?? "")
        .toString()
        .toLowerCase();

    final isGiftCard =
        realType == "giftcard" ||
        realType == "gift_card" ||
        realTitle.startsWith("gift card") ||
        realTitle.contains("gift card purchase") ||
        realTitle.contains("giftcard");

    if (isGiftCard) {
      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GiftCardReceiptScreen(
            transaction: realTx.isNotEmpty ? realTx : transaction,
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // AIRTIME
    // ==========================================================

    if (realTitle.startsWith("airtime")) {
      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AirtimeReceiptScreen(txn: realTx)),
      );

      return;
    }

    // ==========================================================
    // DATA
    // ==========================================================

    if (realTitle.startsWith("data")) {
      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DataReceiptScreen(txn: realTx)),
      );

      return;
    }

    // ==========================================================
    // CABLE
    // ==========================================================

    if (realTitle.startsWith("cable")) {
      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CableReceiptScreen(txn: realTx)),
      );

      return;
    }

    // ==========================================================
    // BETTING
    // ==========================================================

    if (realTitle.startsWith("betting") ||
        realTitle.contains("betting") ||
        realType == "betting") {
      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BettingReceiptScreen(txn: realTx)),
      );

      return;
    }

    // ==========================================================
    // DEFAULT WALLET RECEIPT
    // ==========================================================

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletReceiptScreen(
          title: realTx["title"] ?? "Wallet Transaction",
          amount: realTx["amount"]?.toString() ?? "0",
          date: formattedDate,
          type: realTx["type"] ?? "wallet",
        ),
      ),
    );
  }
}
