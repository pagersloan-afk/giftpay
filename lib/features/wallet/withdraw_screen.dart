import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // ⭐ Added for formatting
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utilityhub/config/api.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/core/widgets/success_dialog.dart'; // ⭐ Added

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final amountCtrl = TextEditingController();
  final bankCtrl = TextEditingController();
  final accountCtrl = TextEditingController();

  bool loading = false;

  Future<void> withdraw() async {
    if (amountCtrl.text.isEmpty ||
        bankCtrl.text.isEmpty ||
        accountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final amount = int.tryParse(amountCtrl.text.trim()) ?? 0;

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.api("/wallet/debit")),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "amount": amountCtrl.text.trim(),
          "title": "Withdrawal to ${bankCtrl.text} (${accountCtrl.text})",
        }),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        // ⭐ Show success dialog
        showSuccessDialog(
          context: context,
          title: "Withdrawal Successful",
          message:
              "₦${NumberFormat("#,##0").format(amount)} has been debited from your wallet.",
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Withdrawal failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Withdraw Funds")),
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
              const SizedBox(height: 16),

              TextField(
                controller: bankCtrl,
                decoration: const InputDecoration(
                  labelText: "Bank Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: accountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Account Number",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : withdraw,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit Withdrawal"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
