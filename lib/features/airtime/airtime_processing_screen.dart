import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';

import 'airtime_success_screen.dart';

class AirtimeProcessingScreen extends StatefulWidget {
  final String requestId;
  final String phone;
  final String amount;

  // Called ONLY when the transaction is confirmed successful.
  final Future<void> Function()? onSuccess;

  const AirtimeProcessingScreen({
    super.key,
    required this.requestId,
    required this.phone,
    required this.amount,
    this.onSuccess,
  });

  @override
  State<AirtimeProcessingScreen> createState() =>
      _AirtimeProcessingScreenState();
}

class _AirtimeProcessingScreenState extends State<AirtimeProcessingScreen> {
  Timer? timer;

  int attempts = 0;

  bool checking = false;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 5), (_) => checkStatus());
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  Future<void> checkStatus() async {
    if (checking) return;

    checking = true;
    attempts++;

    try {
      final uri = Uri.parse(ApiConfig.api("/api/airtime/requery"));

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"requestId": widget.requestId}),
      );

      final data = jsonDecode(response.body);

      // ========================================================
      // Extract status from all possible ClubKonnect formats.
      // ========================================================

      final rawStatus =
          data["orderstatus"] ??
          data["status"] ??
          data["statuscode"] ??
          data["data"]?["orderstatus"] ??
          data["data"]?["status"] ??
          data["data"]?["statuscode"] ??
          "";

      final status = rawStatus.toString().trim().toUpperCase();

      // ========================================================
      // Extract remark.
      // ========================================================

      final rawRemark =
          data["remark"] ??
          data["orderremark"] ??
          data["data"]?["remark"] ??
          data["data"]?["orderremark"] ??
          "Airtime purchase successful";

      final remark = rawRemark.toString();

      // ========================================================
      // SUCCESS
      // ========================================================

      if (status == "ORDER_COMPLETED" || status == "200") {
        timer?.cancel();

        // IMPORTANT:
        // The recent phone number is saved only here,
        // after the transaction has actually been confirmed.
        await widget.onSuccess?.call();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AirtimeSuccessScreen(
              phone: widget.phone,
              amount: widget.amount,
              message: remark,
            ),
          ),
        );

        return;
      }

      // ========================================================
      // FAILED
      // ========================================================

      if (status == "ORDER_FAILED" || status == "FAILED") {
        timer?.cancel();

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(remark)));

        Navigator.pop(context);

        return;
      }

      // ========================================================
      // TIMEOUT AFTER 12 ATTEMPTS
      // ========================================================

      if (attempts >= 12) {
        timer?.cancel();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Still processing… please check your transaction history shortly.",
            ),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      // Keep your original behavior:
      // ignore temporary requery errors and continue polling.
    } finally {
      checking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Processing Airtime")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),

            const SizedBox(height: 20),

            const Text(
              "Processing your airtime purchase…",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              "Phone: ${widget.phone}",
              style: TextStyle(color: Colors.grey.shade700),
            ),

            Text(
              "Amount: ₦${widget.amount}",
              style: TextStyle(color: Colors.grey.shade700),
            ),

            const SizedBox(height: 20),

            Text(
              "Attempt $attempts of 12",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
