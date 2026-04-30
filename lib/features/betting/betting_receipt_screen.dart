import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';

class BettingReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> txn;

  const BettingReceiptScreen({super.key, required this.txn});

  @override
  Widget build(BuildContext context) {
    final String id = txn["id"] ?? "";
    final String bettingCompany = txn["bettingCompany"] ?? "Unknown";
    final String customerId = txn["customerId"] ?? "Unknown";
    final String? customerName = txn["customerName"];
    final int amount = txn["amount"] ?? 0;
    final int fee = txn["fee"] ?? 0;
    final int cashback = txn["cashback"] ?? 0;
    final int totalDebited = txn["totalDebited"] ?? (amount + fee);
    final int timestamp =
        txn["timestamp"] ?? DateTime.now().millisecondsSinceEpoch;
    final String status = txn["status"] ?? "success";

    return Scaffold(
      appBar: AppBar(title: const Text("Betting Receipt")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  "Betting Wallet Funding Receipt",
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                _detail("Betting Company", bettingCompany),
                _detail("Customer ID", customerId),
                _detail("Customer Name", customerName ?? "-"),
                _detail("Amount", "₦$amount"),
                _detail("Fee", "₦$fee"),
                _detail("Cashback", "₦$cashback"),
                _detail("Total Debited", "₦$totalDebited"),
                _detail("Status", status.toUpperCase()),
                _detail(
                  "Date",
                  DateTime.fromMillisecondsSinceEpoch(timestamp).toString(),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Transaction Reference",
                  style: TextStyle(fontSize: 16),
                ),
                SelectableText(
                  id,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 20),

                BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data:
                      "Betting:$bettingCompany|Customer:$customerId|Amount:$amount|Ref:$id",
                  width: 150,
                  height: 150,
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final pdfBytes = await _buildPdf();
                      await Printing.sharePdf(
                        bytes: pdfBytes,
                        filename: "betting_receipt.pdf",
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

  Future<Uint8List> _buildPdf() async {
    final pdf = await Printing.convertHtml(
      format: PdfPageFormat.a4,
      html:
          """
      <h2>Betting Wallet Funding Receipt</h2>
      <p><b>Betting Company:</b> ${txn["bettingCompany"]}</p>
      <p><b>Customer ID:</b> ${txn["customerId"]}</p>
      <p><b>Customer Name:</b> ${txn["customerName"] ?? "-"}</p>
      <p><b>Amount:</b> ₦${txn["amount"]}</p>
      <p><b>Fee:</b> ₦${txn["fee"]}</p>
      <p><b>Cashback:</b> ₦${txn["cashback"]}</p>
      <p><b>Total Debited:</b> ₦${txn["totalDebited"]}</p>
      <p><b>Status:</b> ${txn["status"]}</p>
      <p><b>Reference:</b> ${txn["id"]}</p>
      <p><b>Date:</b> ${DateTime.fromMillisecondsSinceEpoch(txn["timestamp"])}</p>
      """,
    );

    return pdf;
  }
}
