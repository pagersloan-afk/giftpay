import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

// ⭐ Web-safe HTML API
import 'package:universal_html/html.dart' as html;
import 'package:utilityhub/config/api.dart';

import 'package:utilityhub/core/widgets/app_responsive_layout.dart';

class FundWalletScreen extends StatefulWidget {
  const FundWalletScreen({super.key});

  @override
  State<FundWalletScreen> createState() => _FundWalletScreenState();
}

class _FundWalletScreenState extends State<FundWalletScreen> {
  final amountCtrl = TextEditingController();
  bool loading = false;

  Future<void> startPayment() async {
    final rawAmount = amountCtrl.text.trim();

    if (rawAmount.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter an amount")));
      return;
    }

    if (int.tryParse(rawAmount) == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a valid number")));
      return;
    }

    final amount = int.parse(rawAmount);
    final amountInKobo = (amount * 100).toString();
    final userId = FirebaseAuth.instance.currentUser!.uid;

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.api("/paystack/initialize")),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": "gift@example.com",
          "amount": amountInKobo,
          "userId": userId,
        }),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        final url = data["authorization_url"];

        // ⭐ WEB ONLY — open Paystack checkout
        if (kIsWeb) {
          html.window.open(url, "_blank");
        }

        // ⭐ MOBILE — use url_launcher or native Paystack SDK (future)
        // For now, just show message
        if (!kIsWeb) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Paystack web checkout only works on Web for now."),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${data['message']}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Payment error: $e")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fund Wallet")),
      body: AppResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount (NGN)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : startPayment,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Pay with Paystack"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
