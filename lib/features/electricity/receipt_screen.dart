import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';

class ReceiptScreen extends StatelessWidget {
  final String token;
  final String amount;
  final String customerName;
  final String meterNumber;
  final Future<Uint8List> Function() buildPdf;

  const ReceiptScreen({
    super.key,
    required this.token,
    required this.amount,
    required this.customerName,
    required this.meterNumber,
    required this.buildPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Receipt")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  "Electricity Receipt",
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                _detail("Customer", customerName),
                _detail("Meter Number", meterNumber),
                _detail("Amount", "₦$amount"),

                const SizedBox(height: 20),

                const Text("Token", style: TextStyle(fontSize: 16)),
                SelectableText(
                  token,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: "Token:$token|Meter:$meterNumber|Amount:$amount",
                  width: 150,
                  height: 150,
                ),

                const SizedBox(height: 40),

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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
