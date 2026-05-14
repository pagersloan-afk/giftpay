import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:typed_data';

import 'package:utilityhub/core/widgets/giftpay_background.dart';
import 'package:utilityhub/features/electricity/receipt_screen.dart';

class ElectricitySuccessScreen extends StatefulWidget {
  final String token;
  final String amount;
  final String customerName;
  final String meterNumber;
  final String units;
  final int timestamp;

  const ElectricitySuccessScreen({
    super.key,
    required this.token,
    required this.amount,
    required this.customerName,
    required this.meterNumber,
    required this.units,
    required this.timestamp,
  });

  @override
  State<ElectricitySuccessScreen> createState() =>
      _ElectricitySuccessScreenState();
}

class _ElectricitySuccessScreenState extends State<ElectricitySuccessScreen> {
  final AudioPlayer _player = AudioPlayer();
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _confetti.play();
    _playBeep();
  }

  Future<void> _playBeep() async {
    try {
      await _player.play(AssetSource("sounds/success_beep.mp3"));
    } catch (_) {}
  }

  @override
  void dispose() {
    _confetti.dispose();
    _player.dispose();
    super.dispose();
  }

  // ---------------- PDF BUILDER ----------------

  Future<Uint8List> _buildReceiptPdf() async {
    final pdf = pw.Document();

    final logo = await imageFromAssetBundle('assets/images/giftpay_logo.png');

    final token = widget.token;
    final meter = widget.meterNumber;
    final amount = widget.amount;
    final customerName = widget.customerName;
    final date = DateTime.now();

    final qrData =
        "Token:$token|Meter:$meter|Amount:$amount|Date:${date.toIso8601String()}";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Image(logo, width: 40, height: 40),
                      pw.SizedBox(width: 8),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "GiftPay",
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800,
                            ),
                          ),
                          pw.Text(
                            "Digital Utility Services",
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      "ELECTRICITY RECEIPT",
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 8),

              pw.Text(
                "Transaction Details",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),

              _pdfDetail("Customer", customerName),
              _pdfDetail("Meter Number", meter),
              _pdfDetail("Amount", "₦$amount"),
              _pdfDetail("Date", date.toString().substring(0, 19)),

              pw.SizedBox(height: 16),

              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Token",
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      token,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Scan for details",
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: qrData,
                        width: 80,
                        height: 80,
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "Powered by GiftPay",
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "www.giftpay.app",
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.blue800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfDetail(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GiftPayBackground(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // SUCCESS ICON
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: 90,
                        color: Colors.green.shade400,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Payment Successful!",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Your electricity token has been generated.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.white70),
                    ),

                    const SizedBox(height: 30),

                    // TOKEN CARD
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Token",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            widget.token,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          if (widget.units.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              "Units: ${widget.units} kWh",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),

                          ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: widget.token),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Token copied")),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text("Copy Token"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // QR CODE
                    BarcodeWidget(
                      barcode: Barcode.qrCode(),
                      data:
                          "Token:${widget.token}|Meter:${widget.meterNumber}|Amount:${widget.amount}",
                      width: 120,
                      height: 120,
                      color: Colors.white,
                    ),

                    const SizedBox(height: 24),

                    // CUSTOMER DETAILS CARD
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: Column(
                        children: [
                          _detail("Customer", widget.customerName),
                          const SizedBox(height: 12),
                          _detail("Meter Number", widget.meterNumber),
                          const SizedBox(height: 12),
                          _detail("Amount", "₦${widget.amount}"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // PDF BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final pdfBytes = await _buildReceiptPdf();
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

                    const SizedBox(height: 12),

                    // VIEW RECEIPT
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReceiptScreen(
                                token: widget.token,
                                amount: widget.amount,
                                customerName: widget.customerName,
                                meterNumber: widget.meterNumber,
                                timestamp: widget.timestamp,
                                buildPdf: _buildReceiptPdf,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "View Receipt",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // DONE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/home', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Done",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, color: Colors.white70),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
