import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:utilityhub/config/api.dart';

import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/electricity/purchase_screen.dart';

class ElectricityHistoryScreen extends StatefulWidget {
  const ElectricityHistoryScreen({super.key});

  @override
  State<ElectricityHistoryScreen> createState() =>
      _ElectricityHistoryScreenState();
}

class _ElectricityHistoryScreenState extends State<ElectricityHistoryScreen> {
  bool loading = true;
  bool loadingMore = false;
  bool hasMore = true;

  List<dynamic> transactions = [];
  String? lastDocId;

  @override
  void initState() {
    super.initState();
    _loadHistory(initial: true);
  }

  Future<void> _loadHistory({bool initial = false}) async {
    if (initial) {
      setState(() {
        loading = true;
        hasMore = true;
        lastDocId = null;
      });
    } else {
      if (loadingMore || !hasMore) return;
      setState(() => loadingMore = true);
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() {
        loading = false;
        loadingMore = false;
      });
      return;
    }

    final url = Uri.parse(
      ApiConfig.api(
        "/transaction-history?userId=$userId${lastDocId != null ? "&cursor=$lastDocId" : ""}",
      ),
    );

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        final List<dynamic> newItems = data["data"];

        setState(() {
          if (initial) {
            transactions = newItems;
          } else {
            transactions.addAll(newItems);
          }

          if (newItems.isEmpty) {
            hasMore = false;
          } else {
            lastDocId = newItems.last["id"];
          }

          loading = false;
          loadingMore = false;
        });
      } else {
        setState(() {
          loading = false;
          loadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        loadingMore = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadHistory(initial: true);
  }

  // ---------- PDF GENERATION ----------
  Future<Uint8List> _buildReceiptPdf(Map<String, dynamic> t) async {
    final pdf = pw.Document();
    final logo = await imageFromAssetBundle('assets/images/giftpay_logo.png');

    final token = t["token"] ?? "N/A";
    final meter = t["meterNumber"] ?? "N/A";
    final discoCode = t["discoCode"] ?? "N/A";
    final amount = t["amount"]?.toString() ?? "0";
    final status = (t["status"] ?? "success").toString().toUpperCase();
    final customerName = t["customerName"] ?? "Customer";
    final id = t["id"]?.toString() ?? "-";

    final date = t["timestamp"]?["seconds"] != null
        ? DateTime.fromMillisecondsSinceEpoch(t["timestamp"]["seconds"] * 1000)
        : DateTime.now();

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
              _pdfDetailRow("Disco Code", discoCode),
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

  Future<void> _downloadOrSharePdf(Map<String, dynamic> t) async {
    final bytes = await _buildReceiptPdf(t);

    if (kIsWeb) {
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } else {
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'electricity_receipt.pdf',
      );
    }
  }

  // ---------- DETAILS MODAL ----------
  void _showDetails(Map<String, dynamic> t) {
    final token = t["token"] ?? "N/A";
    final meter = t["meterNumber"] ?? "N/A";
    final discoCode = t["discoCode"] ?? "N/A";
    final amount = t["amount"]?.toString() ?? "0";
    final status = t["status"] ?? "success";
    final meterType = t["meterType"] ?? "01";
    final customerName = t["customerName"] ?? "Customer";

    final date = t["timestamp"]?["seconds"] != null
        ? DateTime.fromMillisecondsSinceEpoch(t["timestamp"]["seconds"] * 1000)
        : DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Electricity Transaction",
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _statusBadge(status.toString()),
                  const SizedBox(height: 16),
                  _detailRow("Amount", "₦$amount"),
                  _detailRow("Meter Number", meter),
                  _detailRow("Disco Code", discoCode),
                  _detailRow("Token", token),
                  _detailRow("Date", date.toString().substring(0, 16)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: token));
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Token copied")),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text("Copy Token"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _downloadOrSharePdf(t),
                          icon: Icon(
                            kIsWeb ? Icons.download : Icons.picture_as_pdf,
                          ),
                          label: Text(
                            kIsWeb
                                ? "Download PDF Receipt"
                                : "Share PDF Receipt",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PurchaseElectricityScreen(
                                  meterNumber: meter,
                                  customerName: customerName,
                                  discoCode: discoCode,
                                  meterType: meterType,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.flash_on),
                          label: const Text("Buy Again"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case "pending":
        color = Colors.orange;
        break;
      case "failed":
        color = Colors.red;
        break;
      default:
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Electricity History")),
      body: AppResponsiveLayout(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: transactions.length + (hasMore ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      if (i == transactions.length) {
                        _loadHistory(initial: false);
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final t = transactions[i] as Map<String, dynamic>;

                      final amount = t["amount"]?.toString() ?? "0";
                      final token = t["token"] ?? "N/A";
                      final status = t["status"] ?? "success";

                      final date = t["timestamp"]?["seconds"] != null
                          ? DateTime.fromMillisecondsSinceEpoch(
                              t["timestamp"]["seconds"] * 1000,
                            )
                          : DateTime.now();

                      return ListTile(
                        onTap: () => _showDetails(t),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: const Icon(
                            Icons.flash_on,
                            color: Colors.white,
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Electricity Purchase",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            _statusBadge(status.toString()),
                          ],
                        ),
                        subtitle: Text(
                          "Token: $token\n${date.toString().substring(0, 16)}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "₦$amount",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              tooltip: "Copy token",
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: token.toString()),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Token copied")),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
