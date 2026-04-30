import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:barcode_widget/barcode_widget.dart';

import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/electricity/receipt_screen.dart';

class ElectricitySuccessScreen extends StatefulWidget {
  final String token;
  final String amount;
  final String customerName;
  final String meterNumber;
  final String units;

  const ElectricitySuccessScreen({
    super.key,
    required this.token,
    required this.amount,
    required this.customerName,
    required this.meterNumber,
    required this.units,
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
    _playBeep();
    _confetti.play();

    Future.delayed(const Duration(milliseconds: 300), () {
      _showSuccessModal();
    });
  }

  Future<void> _playBeep() async {
    await _player.play(AssetSource("sounds/success_beep.mp3"));
  }

  @override
  void dispose() {
    _confetti.dispose();
    _player.dispose();
    super.dispose();
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 55, // ⭐ smaller for rectangle shape
                  color: Colors.green.shade600,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Payment Successful!",
                  style: TextStyle(
                    fontSize: 20, // ⭐ slightly smaller
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Your electricity token is ready.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- PDF RECEIPT (BRANDED) ----------

  Future<Uint8List> _buildReceiptPdf() async {
    final pdf = pw.Document();

    final logo = await imageFromAssetBundle('assets/images/giftpay_logo.png');

    final token = widget.token;
    final meter = widget.meterNumber;
    final amount = widget.amount;
    final customerName = widget.customerName;
    final status = "SUCCESS";
    final id = "N/A"; // If you have a real transaction ID, pass it in later.

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

              _pdfDetailRow("Customer", customerName),
              _pdfDetailRow("Meter Number", meter),
              _pdfDetailRow("Amount", "₦$amount"),
              _pdfDetailRow("Status", status),
              _pdfDetailRow("Transaction ID", id),
              _pdfDetailRow("Date", date.toString().substring(0, 19)),

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
                crossAxisAlignment: pw.CrossAxisAlignment.start,
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

  pw.Widget _pdfDetailRow(String label, String value) {
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

  Future<void> _downloadOrSharePdf() async {
    final bytes = await _buildReceiptPdf();

    if (kIsWeb) {
      // Web: open print/download dialog
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } else {
      // Mobile: share PDF
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'electricity_receipt.pdf',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: AppResponsiveLayout(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        "assets/images/success.png",
                        width: 120,
                        height: 120,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Payment Successful!",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Your electricity token has been generated.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Token",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            widget.token,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // ⭐ UNITS DISPLAY
                          if (widget.units.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              "Units: ${widget.units} kWh",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
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
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // On-screen QR (nice touch)
                    BarcodeWidget(
                      barcode: Barcode.qrCode(),
                      data:
                          "Token:${widget.token}|Meter:${widget.meterNumber}|Amount:${widget.amount}|Date:${DateTime.now().toIso8601String()}",
                      width: 120,
                      height: 120,
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          _detailRow("Customer", widget.customerName),
                          const SizedBox(height: 12),
                          _detailRow("Meter Number", widget.meterNumber),
                          const SizedBox(height: 12),
                          _detailRow("Amount", "₦${widget.amount}"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _downloadOrSharePdf,
                        icon: Icon(
                          kIsWeb ? Icons.download : Icons.picture_as_pdf,
                        ),
                        label: Text(
                          kIsWeb ? "Download PDF Receipt" : "Share PDF Receipt",
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

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
                                buildPdf:
                                    _buildReceiptPdf, // ⭐ reuse your existing PDF builder
                              ),
                            ),
                          );
                        },
                        child: const Text("View Receipt"),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/home', (route) => false);
                        },

                        child: const Text("Done"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
          style: const TextStyle(fontSize: 15, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
