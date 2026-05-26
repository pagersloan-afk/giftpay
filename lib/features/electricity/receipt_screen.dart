import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:utilityhub/core/widgets/giftpay_background.dart';

class ReceiptScreen extends StatelessWidget {
  final String token;
  final String amount;
  final String customerName;
  final String meterNumber;
  final int timestamp; // ⭐ NEW
  final Future<Uint8List> Function() buildPdf;

  const ReceiptScreen({
    super.key,
    required this.token,
    required this.amount,
    required this.customerName,
    required this.meterNumber,
    required this.timestamp, // ⭐ NEW
    required this.buildPdf,
  });

  // Format amount → ₦1,200.00
  String _formatAmount(dynamic raw) {
    try {
      final value = raw is num ? raw : num.tryParse(raw.toString()) ?? 0;
      return "₦${value.toStringAsFixed(2)}";
    } catch (_) {
      return "₦$raw";
    }
  }

  // ⭐ Format token → 1234-5678-9012-3456-789
  String formatToken(String raw) {
    if (raw.isEmpty) return "";
    raw = raw.replaceAll(RegExp(r'[^0-9]'), ''); // remove TOKEN: and non-digits
    return raw
        .replaceAllMapped(RegExp(r".{4}"), (m) => "${m.group(0)}-")
        .replaceAll(RegExp(r'-$'), ''); // remove trailing dash
  }

  // ⭐ Format timestamp → 14/5/2026 03:59
  String formatDate(int ts) {
    if (ts == 0) return "Unknown";
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "${dt.day}/${dt.month}/${dt.year}  $h:$m";
  }

  @override
  Widget build(BuildContext context) {
    final formattedAmount = _formatAmount(amount);
    final formattedToken = formatToken(token);
    final formattedDate = formatDate(timestamp);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GiftPayBackground(
        child: Center(
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),

            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICON
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flash_on,
                      size: 70,
                      color: Colors.blue.shade300,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Electricity Receipt",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Your electricity purchase was completed successfully.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // DETAILS CARD
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Column(
                      children: [
                        _detailRow("Customer", customerName),
                        const SizedBox(height: 12),
                        _detailRow("Meter Number", meterNumber),
                        const SizedBox(height: 12),
                        _detailRow("Amount", formattedAmount),
                        const SizedBox(height: 12),

                        // ⭐ NEW — DATE
                        _detailRow("Date", formattedDate),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Token",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ⭐ FORMATTED TOKEN DISPLAY
                  SelectableText(
                    formattedToken,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ⭐ QR CODE USES FORMATTED TOKEN
                  BarcodeWidget(
                    barcode: Barcode.qrCode(),
                    data:
                        "Token:$formattedToken|Meter:$meterNumber|Amount:$formattedAmount|Date:$formattedDate",
                    width: 150,
                    height: 150,
                    color: Colors.white,
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final pdfBytes = await buildPdf();
                        await Printing.sharePdf(
                          bytes: pdfBytes,
                          filename: "electricity_receipt.pdf",
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Download / Share PDF"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.20),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT LABEL
        SizedBox(
          width: 120, // fixed width for labels
          child: Text(
            title,
            style: const TextStyle(fontSize: 15, color: Colors.white70),
          ),
        ),

        const SizedBox(width: 10),

        // RIGHT VALUE (flexible, wraps, no overflow)
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            softWrap: true,
            overflow: TextOverflow.visible,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
