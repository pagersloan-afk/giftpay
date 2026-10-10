import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utilityhub/config/api.dart';
import 'electricity_processing_screen.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PurchaseElectricityScreen extends StatefulWidget {
  final String meterNumber;
  final String customerName;
  final String discoCode;
  final String meterType;
  final String productCode;
  final String validationReference;

  const PurchaseElectricityScreen({
    super.key,
    required this.meterNumber,
    required this.customerName,
    required this.discoCode,
    required this.meterType,
    required this.productCode,
    this.validationReference = "",
  });

  @override
  State<PurchaseElectricityScreen> createState() => _PurchaseElectricityScreenState();
}

class _PurchaseElectricityScreenState extends State<PurchaseElectricityScreen> {
  final _formKey = GlobalKey<FormState>();
  String amount = "";
  String phone = "";
  bool loading = false;

  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final response = await http.post(
        Uri.parse(ApiConfig.api("/api/electricity/wallet/pay-electricity")),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "meterNumber": widget.meterNumber,
          "billerCode": widget.discoCode,
          "amount": amount,
          "phone": phone,
          "meterType": widget.meterType,
          "productCode": widget.productCode,
          if (widget.validationReference.isNotEmpty)
            "validationReference": widget.validationReference,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (data["status"] == true) {
        final requestId = data["requestId"] ?? data["reference"];
        if (requestId == null || requestId.toString().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment succeeded but no reference was returned.")),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ElectricityProcessingScreen(
              requestId: requestId.toString(),
              userId: userId,
              meterNumber: widget.meterNumber,
              amount: amount,
              customerName: widget.customerName,
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Electricity payment failed")),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Electricity payment error")),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.customerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 6),
                      Text("Meter: ${widget.meterNumber}", style: const TextStyle(fontSize: 14, color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text("Provider: ${widget.discoCode}", style: const TextStyle(fontSize: 14, color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text("Product: ${widget.productCode}", style: const TextStyle(fontSize: 12, color: Colors.white54)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Amount (₦)", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => amount = v,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Enter amount";
                    final amt = double.tryParse(v) ?? 0;
                    if (amt < 200) return "Minimum purchase is ₦200";
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                  onChanged: (v) => phone = v,
                  validator: (v) => v == null || v.isEmpty ? "Enter phone number" : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : handleSubmit,
                    child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Pay with Wallet"),
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
