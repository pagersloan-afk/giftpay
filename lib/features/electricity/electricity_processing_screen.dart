// lib/features/electricity/electricity_processing_screen.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'success_screen.dart';

class ElectricityProcessingScreen extends StatefulWidget {
  final String requestId;
  final String userId;
  final String meterNumber;
  final String amount;
  final String customerName;

  const ElectricityProcessingScreen({
    super.key,
    required this.requestId,
    required this.userId,
    required this.meterNumber,
    required this.amount,
    required this.customerName,
  });

  @override
  State<ElectricityProcessingScreen> createState() =>
      _ElectricityProcessingScreenState();
}

class _ElectricityProcessingScreenState
    extends State<ElectricityProcessingScreen> {
  Timer? _timer;
  bool _checking = false;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // -------------------------------------------------------------
  // START POLLING BACKEND EVERY 5 SECONDS
  // -------------------------------------------------------------
  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkStatus();
    });
  }

  // -------------------------------------------------------------
  // CALL BACKEND /requery
  // -------------------------------------------------------------
  Future<void> _checkStatus() async {
    if (_checking) return;
    _checking = true;

    _attempts++;

    try {
      final url = Uri.parse("http://localhost:4000/api/electricity/requery");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "requestId": widget.requestId,
          "userId": widget.userId,
        }),
      );

      final data = jsonDecode(response.body);
      final raw = data["raw"] ?? {};

      // ⭐ CK returns many possible fields
      String status =
          raw["orderstatus"] ??
          raw["transactionstatus"] ??
          raw["status"] ??
          raw["statuscode"] ??
          "";

      // ⭐ SPECIAL CASE: TXN_HISTORY wrapper
      if (raw["status"] == "TXN_HISTORY" && raw["transactionstatus"] != null) {
        status = raw["transactionstatus"];
      }

      print("🔍 PROCESSING STATUS: $status");

      // ⭐ SUCCESS (ORDER_COMPLETED or token already present)
      if (status == "ORDER_COMPLETED" ||
          status == "200" ||
          raw["metertoken"] != null) {
        _timer?.cancel();

        final token = raw["metertoken"] ?? raw["token"] ?? "";
        final units = raw["units"]?.toString() ?? "";

        final formattedToken = _formatToken(token);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ElectricitySuccessScreen(
              token: formattedToken,
              units: units,
              amount: widget.amount,
              customerName: widget.customerName,
              meterNumber: widget.meterNumber,
            ),
          ),
        );
        return;
      }

      // ⭐ ORDER RECEIVED → still processing
      if (status == "ORDER_RECEIVED" || status == "100") {
        // keep polling
        print("⏳ Still processing...");
      }

      // ⭐ FAILED → REFUNDED
      if (status == "ORDER_FAILED" || status == "FAILED") {
        _timer?.cancel();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transaction failed. Refund processed."),
          ),
        );

        Navigator.pop(context);
        return;
      }

      // ⭐ TIMEOUT
      if (_attempts >= 20) {
        _timer?.cancel();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Still processing… check your transaction history."),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      print("❌ PROCESSING ERROR: $e");
    } finally {
      _checking = false;
    }
  }

  // -------------------------------------------------------------
  // TOKEN FORMATTER
  // -------------------------------------------------------------
  String _formatToken(String raw) {
    raw = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return raw.replaceAllMapped(RegExp(r".{4}"), (m) => "${m.group(0)}-");
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Processing Payment")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                "Processing your electricity purchase…",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Request ID: ${widget.requestId}",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              const Text(
                "Please wait while we confirm your token.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
