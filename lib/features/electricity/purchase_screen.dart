// lib/features/electricity/purchase_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'electricity_processing_screen.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';

class PurchaseElectricityScreen extends StatefulWidget {
  final String meterNumber;
  final String customerName;
  final String discoCode;
  final String meterType;

  const PurchaseElectricityScreen({
    super.key,
    required this.meterNumber,
    required this.customerName,
    required this.discoCode,
    required this.meterType,
  });

  @override
  State<PurchaseElectricityScreen> createState() =>
      _PurchaseElectricityScreenState();
}

class _PurchaseElectricityScreenState extends State<PurchaseElectricityScreen> {
  final _formKey = GlobalKey<FormState>();

  String amount = "";
  String phone = "";

  bool loading = false;

  // -------------------------------------------------------------
  // STEP 1 — WALLET PAY
  // -------------------------------------------------------------
  Future<String?> walletPay() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final url = Uri.parse(
        "http://localhost:4000/api/electricity/wallet/pay-electricity",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "meterNumber": widget.meterNumber,
          "discoCode": widget.discoCode,
          "amount": amount,
          "phone": phone,
          "meterType": widget.meterType,
        }),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == true && data["pending"] == true) {
        return data["requestId"];
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Wallet payment failed")),
      );
      return null;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Wallet payment error")));
      return null;
    }
  }

  // -------------------------------------------------------------
  // STEP 2 — VEND ELECTRICITY (TRUST CK RAW STATUS)
  // -------------------------------------------------------------
  Future<bool> vendElectricity(String requestId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final url = Uri.parse(
        "http://localhost:4000/api/electricity/vend-electricity",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "meterNumber": widget.meterNumber,
          "discoCode": widget.discoCode,
          "amount": amount,
          "phone": phone,
          "meterType": widget.meterType,
          "requestId": requestId,
        }),
      );

      final data = jsonDecode(response.body);
      final raw = data["raw"] ?? {};

      final status =
          raw["orderstatus"] ??
          raw["transactionstatus"] ??
          raw["status"] ??
          raw["statuscode"] ??
          "";

      if (status == "ORDER_RECEIVED" ||
          status == "ORDER_COMPLETED" ||
          status == "200" ||
          status == "100") {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // -------------------------------------------------------------
  // HANDLE SUBMIT
  // -------------------------------------------------------------
  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final requestId = await walletPay();
    if (requestId == null) {
      if (mounted) setState(() => loading = false);
      return;
    }

    final vendOk = await vendElectricity(requestId);

    if (!vendOk) {
      if (mounted) setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vending failed")));
      return;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ElectricityProcessingScreen(
          requestId: requestId,
          userId: FirebaseAuth.instance.currentUser!.uid,
          meterNumber: widget.meterNumber,
          amount: amount,
          customerName: widget.customerName,
        ),
      ),
    );

    setState(() => loading = false);
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Purchase Electricity")),
      body: AppResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CUSTOMER DETAILS CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.flash_on, size: 50, color: Colors.blue),
                      const SizedBox(height: 12),
                      Text(
                        widget.customerName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Meter: ${widget.meterNumber} (${widget.meterType == "01" ? "Prepaid" : "Postpaid"})",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Disco: ${widget.discoCode}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // AMOUNT
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Amount (₦)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => amount = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter amount" : null,
                ),

                const SizedBox(height: 16),

                // PHONE
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (v) => phone = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter phone number" : null,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : handleSubmit,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Pay with Wallet"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
