import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';
import 'success_dialog.dart';

class DataProcessingScreen extends StatefulWidget {
  final String requestId;
  final String phone;
  final String planName;
  final String amount;

  const DataProcessingScreen({
    super.key,
    required this.requestId,
    required this.phone,
    required this.planName,
    required this.amount,
  });

  @override
  State<DataProcessingScreen> createState() => _DataProcessingScreenState();
}

class _DataProcessingScreenState extends State<DataProcessingScreen> {
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
      final uri = Uri.parse(
        ApiConfig.api("/api/data/requery/${widget.requestId}"),
      );

      final response = await http.get(uri);
      final body = jsonDecode(response.body);

      final data = body["data"] ?? {};
      final status =
          data["orderstatus"] ?? data["status"] ?? data["statuscode"] ?? "";
      final remark =
          data["remark"] ?? data["orderremark"] ?? "Data purchase successful";

      // ⭐ SUCCESS
      if (status == "ORDER_COMPLETED" || status == "200") {
        timer?.cancel();
        if (!mounted) return;

        // ⭐ FIRST close the processing screen
        Navigator.pop(context);

        // ⭐ THEN show the success dialog on DataScreen
        Future.microtask(() {
          showDataSuccessDialog(
            context: context,
            phone: widget.phone,
            planName: widget.planName,
            amount: widget.amount,
            message: remark,
          );
        });

        return;
      }

      // ⭐ FAILED
      if (status == "ORDER_FAILED" || status == "FAILED") {
        timer?.cancel();
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(remark)));

        Navigator.pop(context);
        return;
      }

      // ⭐ TIMEOUT
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
    } catch (_) {
      // ignore
    } finally {
      checking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Processing Data Purchase")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text("Processing your data purchase…"),
            const SizedBox(height: 8),
            Text("Phone: ${widget.phone}"),
            Text("Plan: ${widget.planName}"),
            Text("Amount: ₦${widget.amount}"),
            const SizedBox(height: 20),
            Text("Attempt $attempts of 12"),
          ],
        ),
      ),
    );
  }
}
