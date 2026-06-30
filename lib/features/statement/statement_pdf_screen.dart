import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utilityhub/config/api.dart';

class StatementPdfScreen extends StatefulWidget {
  const StatementPdfScreen({super.key});

  @override
  State<StatementPdfScreen> createState() => _StatementPdfScreenState();
}

class _StatementPdfScreenState extends State<StatementPdfScreen> {
  bool loading = true;
  bool error = false;

  List<dynamic> transactions = [];
  List<dynamic> filtered = [];

  late DateTime startDate;
  late DateTime endDate;

  String filterType = "all";
  String filterStatus = "all";
  String filterProvider = "all";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    startDate = args["start"];
    endDate = args["end"];
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      loading = true;
      error = false;
    });

    final user = FirebaseAuth.instance.currentUser;
    final token = await user!.getIdToken();

    final url = ApiConfig.api(
      "/v1/statement?start=${startDate.toIso8601String()}&end=${endDate.toIso8601String()}",
    );

    print("📡 FETCHING STATEMENT:");
    print("➡️ URL: $url");

    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      print("📥 STATUS CODE: ${res.statusCode}");
      print("📥 RAW RESPONSE: ${res.body}");

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        transactions = decoded["transactions"] ?? [];
        filtered = List.from(transactions);
      } else {
        error = true;
      }
    } catch (e) {
      print("❌ EXCEPTION: $e");
      error = true;
    }

    setState(() => loading = false);
  }

  // FILTER ENGINE
  void applyFilters() {
    filtered = transactions.where((tx) {
      final typeOk = filterType == "all" || tx["type"] == filterType;
      final statusOk = filterStatus == "all" || tx["status"] == filterStatus;
      final providerOk =
          filterProvider == "all" ||
          tx["title"].toString().toLowerCase().contains(filterProvider);

      return typeOk && statusOk && providerOk;
    }).toList();

    setState(() {});
  }

  // MONTHLY SUMMARY
  double computeMonthlyTotal() {
    double total = 0;
    for (var tx in filtered) {
      total += double.tryParse(tx["amount"].toString()) ?? 0;
    }
    return total;
  }

  double computeTotalByType(String type) {
    double total = 0;
    for (var tx in filtered) {
      if (tx["type"] == type) {
        total += double.tryParse(tx["amount"].toString()) ?? 0;
      }
    }
    return total;
  }

  Map<String, double> computeCategoryTotals() {
    final Map<String, double> totals = {};
    for (var tx in filtered) {
      final title = tx["title"]?.toString().toLowerCase() ?? "";
      String category = "other";

      if (title.contains("airtime"))
        category = "airtime";
      else if (title.contains("electricity"))
        category = "electricity";
      else if (title.contains("data"))
        category = "data";
      else if (title.contains("cable"))
        category = "cable";
      else if (title.contains("betting"))
        category = "betting";

      totals[category] =
          (totals[category] ?? 0) +
          (double.tryParse(tx["amount"].toString()) ?? 0);
    }
    return totals;
  }

  String computeTopCategory() {
    final totals = computeCategoryTotals();
    if (totals.isEmpty) return "N/A";

    String top = totals.keys.first;
    double max = totals[top]!;
    totals.forEach((k, v) {
      if (v > max) {
        max = v;
        top = k;
      }
    });
    return top;
  }

  Future<void> _generatePdf() async {
    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No transactions to export")),
      );
      return;
    }

    final pdf = pw.Document();

    final logo = pw.MemoryImage(
      (await rootBundle.load("assets/logo/giftpay_1.png")).buffer.asUint8List(),
    );

    final categoryTotals = computeCategoryTotals();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
        ),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Image(logo, width: 80),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    "GiftPay Statement",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    "${DateFormat("dd MMM yyyy").format(startDate)} → ${DateFormat("dd MMM yyyy").format(endDate)}",
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          pw.Text(
            "Monthly Summary",
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),

          pw.Text(
            "Total: ₦${computeMonthlyTotal().toStringAsFixed(2)}",
            style: const pw.TextStyle(fontSize: 14),
          ),
          pw.Text(
            "Total Credit: ₦${computeTotalByType("credit").toStringAsFixed(2)}",
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.Text(
            "Total Debit: ₦${computeTotalByType("debit").toStringAsFixed(2)}",
            style: const pw.TextStyle(fontSize: 12),
          ),

          pw.SizedBox(height: 10),

          pw.Text(
            "Top Category: ${computeTopCategory()}",
            style: const pw.TextStyle(fontSize: 12),
          ),

          pw.SizedBox(height: 20),

          pw.Text(
            "Category Breakdown",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 8),

          pw.Column(
            children: categoryTotals.entries.map((e) {
              final pct = computeMonthlyTotal() == 0
                  ? 0
                  : (e.value / computeMonthlyTotal()) * 100;
              return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(e.key),
                  pw.Text(
                    "₦${e.value.toStringAsFixed(2)} (${pct.toStringAsFixed(1)}%)",
                  ),
                ],
              );
            }).toList(),
          ),

          pw.SizedBox(height: 20),

          pw.Table.fromTextArray(
            headers: ["Date", "Type", "Amount", "Status"],
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
            cellAlignment: pw.Alignment.centerLeft,
            data: filtered.map((tx) {
              return [
                DateFormat("dd MMM").format(DateTime.parse(tx["date"])),
                tx["type"],
                "₦${tx["amount"]}",
                tx["status"],
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/GiftPay_Statement.pdf");
    await file.writeAsBytes(await pdf.save());

    Share.shareXFiles([XFile(file.path)], text: "GiftPay Statement PDF");
  }

  Future<void> _exportCsv() async {
    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No transactions to export")),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln("date,type,amount,status,title");

    for (var tx in filtered) {
      buffer.writeln(
        "${tx["date"]},${tx["type"]},${tx["amount"]},${tx["status"]},\"${tx["title"]}\"",
      );
    }

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/GiftPay_Statement.csv");
    await file.writeAsString(buffer.toString());

    Share.shareXFiles([XFile(file.path)], text: "GiftPay Statement CSV");
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF05070A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error) {
      return Scaffold(
        backgroundColor: const Color(0xFF05070A),
        appBar: AppBar(title: const Text("Statement PDF")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Failed to load statement",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadTransactions,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF05070A),
        appBar: AppBar(title: const Text("Statement PDF")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "No transactions found",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadTransactions,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final categoryTotals = computeCategoryTotals();

    return Scaffold(
      backgroundColor: const Color(0xFF05070A),
      appBar: AppBar(title: const Text("Statement PDF")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // FILTERS
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    dropdownColor: const Color(0xFF0F1115),
                    value: filterType,
                    items: const [
                      DropdownMenuItem(value: "all", child: Text("All Types")),
                      DropdownMenuItem(value: "credit", child: Text("Credit")),
                      DropdownMenuItem(value: "debit", child: Text("Debit")),
                    ],
                    onChanged: (v) {
                      filterType = v!;
                      applyFilters();
                    },
                  ),
                ),
                Expanded(
                  child: DropdownButton<String>(
                    dropdownColor: const Color(0xFF0F1115),
                    value: filterStatus,
                    items: const [
                      DropdownMenuItem(value: "all", child: Text("All Status")),
                      DropdownMenuItem(
                        value: "success",
                        child: Text("Success"),
                      ),
                      DropdownMenuItem(value: "failed", child: Text("Failed")),
                      DropdownMenuItem(
                        value: "pending",
                        child: Text("Pending"),
                      ),
                    ],
                    onChanged: (v) {
                      filterStatus = v!;
                      applyFilters();
                    },
                  ),
                ),
                Expanded(
                  child: DropdownButton<String>(
                    dropdownColor: const Color(0xFF0F1115),
                    value: filterProvider,
                    items: const [
                      DropdownMenuItem(
                        value: "all",
                        child: Text("All Providers"),
                      ),
                      DropdownMenuItem(
                        value: "airtime",
                        child: Text("Airtime"),
                      ),
                      DropdownMenuItem(
                        value: "electricity",
                        child: Text("Electricity"),
                      ),
                      DropdownMenuItem(value: "data", child: Text("Data")),
                      DropdownMenuItem(value: "cable", child: Text("Cable")),
                      DropdownMenuItem(
                        value: "betting",
                        child: Text("Betting"),
                      ),
                    ],
                    onChanged: (v) {
                      filterProvider = v!;
                      applyFilters();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // MONTHLY INSIGHTS + CATEGORY BREAKDOWN UI
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1115),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Monthly Insights",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Total: ₦${computeMonthlyTotal().toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "Credit: ₦${computeTotalByType("credit").toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "Debit: ₦${computeTotalByType("debit").toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "Top category: ${computeTopCategory()}",
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Category Breakdown",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Column(
                    children: categoryTotals.entries.map((e) {
                      final pct = computeMonthlyTotal() == 0
                          ? 0
                          : (e.value / computeMonthlyTotal()) * 100;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.key,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            "₦${e.value.toStringAsFixed(2)} (${pct.toStringAsFixed(1)}%)",
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ACTIONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _generatePdf,
                    child: const Text("Download / Share PDF"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _exportCsv,
                    child: const Text("Export CSV"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
