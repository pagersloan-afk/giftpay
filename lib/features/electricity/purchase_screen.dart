// lib/features/electricity/purchase_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utilityhub/config/api.dart';

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
        ApiConfig.api("/api/electricity/wallet/pay-electricity"),
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
  Future<Map<String, dynamic>> vendElectricity(String requestId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final url = Uri.parse(ApiConfig.api("/api/electricity/vend-electricity"));

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
          "customerName": widget.customerName,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": false, "message": "Network error"};
    }
  }

  // -------------------------------------------------------------
  // HANDLE SUBMIT
  // -------------------------------------------------------------
  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    // STEP 1 — WALLET PAY
    final requestId = await walletPay();
    if (requestId == null) {
      setState(() => loading = false);
      return;
    }

    // STEP 2 — VEND
    final vend = await vendElectricity(requestId);

    // ⭐ CASE 1 — BACKEND REUSED TOKEN (NO NEED FOR PROCESSING SCREEN)
    if (vend["reused"] == true) {
      setState(() => loading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ElectricityProcessingScreen(
            requestId: requestId,
            userId: FirebaseAuth.instance.currentUser!.uid,
            meterNumber: widget.meterNumber,
            amount: amount,
            customerName: widget.customerName,
            reusedToken: vend["token"],
            reusedUnits: vend["units"],
          ),
        ),
      );
      return;
    }

    // ⭐ CASE 2 — COOLDOWN / PENDING
    if (vend["code"] == "COOLDOWN_PENDING" ||
        vend["code"] == "PENDING_PROVIDER" ||
        vend["code"] == "COOLDOWN_ACTIVE") {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vend["message"] ?? "Please wait a few minutes")),
      );
      return;
    }

    // ⭐ CASE 3 — NORMAL FAILURE
    if (vend["status"] == false) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vend["message"] ?? "Vending failed")),
      );
      return;
    }

    // ⭐ CASE 4 — SUCCESS → GO TO PROCESSING SCREEN
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
                // CUSTOMER DETAILS CARD — GIFT PAY DARK THEME
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.flash_on,
                          size: 40,
                          color: Colors.blue.shade300,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        widget.customerName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Meter: ${widget.meterNumber} (${widget.meterType == "01" ? "Prepaid" : "Postpaid"})",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Disco: ${widget.discoCode}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
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
