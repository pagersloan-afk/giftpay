import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';
import 'success_screen.dart';

class ElectricityProcessingScreen extends StatefulWidget {
  final String requestId;
  final String userId;
  final String meterNumber;
  final String amount;
  final String customerName;
  final String customerAddress;

  const ElectricityProcessingScreen({
    super.key,
    required this.requestId,
    required this.userId,
    required this.meterNumber,
    required this.amount,
    required this.customerName,
    this.customerAddress = "",
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
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkStatus());
    _checkStatus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (_checking) return;
    _checking = true;
    _attempts++;

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.api("/api/electricity/requery")),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "requestId": widget.requestId,
          "userId": widget.userId,
        }),
      );

      final data = jsonDecode(response.body);
      final status = (data["vendStatus"] ?? data["status"] ?? "")
          .toString()
          .toUpperCase();

      if (status == "SUCCESS") {
        _timer?.cancel();
        if (!mounted) return;
        final raw = data["raw"] ?? {};
        final body = raw is Map && raw["responseBody"] is Map
            ? raw["responseBody"]
            : raw;
        final token =
            (data["token"] ??
                    (body is Map
                        ? (body["metertoken"] ??
                              body["MeterToken"] ??
                              body["meterToken"] ??
                              body["token"] ??
                              body["Token"])
                        : null) ??
                    "")
                .toString()
                .trim();
        final units =
            (data["units"] ??
                    (body is Map
                        ? (body["units"] ??
                              body["Units"] ??
                              body["unit"] ??
                              body["Unit"] ??
                              body["unitvalue"] ??
                              body["UnitValue"])
                        : null) ??
                    "")
                .toString()
                .trim();
        if (token.isEmpty) {
          // Never open the success screen without the actual meter token.
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ElectricitySuccessScreen(
              token: token,
              requestId: widget.requestId,
              units: units,
              amount: widget.amount,
              customerName: widget.customerName,
              customerAddress:
                  (data["customerAddress"] ??
                          raw["customer_address"] ??
                          raw["customerAddress"] ??
                          widget.customerAddress)
                      .toString(),
              meterNumber: widget.meterNumber,
              timestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          ),
        );
        return;
      }

      if (status == "FAILED" || data["refunded"] == true) {
        _timer?.cancel();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ?? "Transaction failed. Refund processed.",
            ),
          ),
        );
        Navigator.pop(context);
        return;
      }

      if (_attempts == 120 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "This purchase is taking longer than usual. We are still checking for your meter token. Please keep this screen open.",
            ),
          ),
        );
      }
    } catch (_) {
      // Keep polling. The backend remains the authority for transaction status.
    } finally {
      _checking = false;
    }
  }

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
              const Text(
                "Processing your electricity purchase…",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                "Reference: ${widget.requestId}",
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              const Text(
                "Please wait while we confirms your purchase and returns your meter token.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
