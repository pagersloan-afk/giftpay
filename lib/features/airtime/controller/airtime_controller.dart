// lib/features/airtime/controller/airtime_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../airtime_processing_screen.dart';
import '../airtime_success_screen.dart';
import '../theme/airtime_theme.dart';

class AirtimeController {
  final TextEditingController phoneCtrl;
  final TextEditingController amountCtrl;

  bool loading = false;
  bool useWallet = true;

  String selectedNetworkCode = "";
  Map<String, String> networkMap = {};

  AirtimeController({required this.phoneCtrl, required this.amountCtrl});

  Color get themeColor =>
      AirtimeTheme.themeColorFor(networkMap, selectedNetworkCode);

  Future<void> fetchNetworks() async {
    try {
      final uri = Uri.parse("http://localhost:4000/api/airtime/networks");
      final response = await http.get(uri);

      final data = jsonDecode(response.body);

      if (data["status"] == true && data["networks"] != null) {
        final map = Map<String, dynamic>.from(data["networks"]);
        final parsed = map.map((k, v) => MapEntry(k.toString(), v.toString()));

        networkMap = parsed;
        if (networkMap.isNotEmpty) {
          selectedNetworkCode = networkMap.values.first;
        }
      }
    } catch (_) {}
  }

  void autoDetectNetwork() {
    final phone = phoneCtrl.text.trim();
    if (phone.length < 4) return;

    final prefix = phone.substring(0, 4);

    String? detected;

    const mtnPrefixes = [
      "0803",
      "0806",
      "0703",
      "0706",
      "0813",
      "0816",
      "0903",
      "0906",
      "0913",
      "0916",
    ];
    const gloPrefixes = [
      "0805",
      "0807",
      "0705",
      "0815",
      "0811",
      "0905",
      "0915",
    ];
    const airtelPrefixes = [
      "0802",
      "0808",
      "0708",
      "0812",
      "0902",
      "0907",
      "0901",
      "0912",
    ];
    const ninePrefixes = ["0809", "0817", "0818", "0909", "0908"];

    if (mtnPrefixes.contains(prefix)) detected = "MTN";
    if (gloPrefixes.contains(prefix)) detected = "GLO";
    if (airtelPrefixes.contains(prefix)) detected = "Airtel";
    if (ninePrefixes.contains(prefix)) detected = "9mobile";

    if (detected != null && networkMap.containsKey(detected)) {
      selectedNetworkCode = networkMap[detected]!;
    }
  }

  bool _validateBasic(BuildContext context) {
    if (phoneCtrl.text.isEmpty || amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return false;
    }

    final amount = int.tryParse(amountCtrl.text.trim());
    if (amount == null || amount < 50) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Minimum is ₦50")));
      return false;
    }

    return true;
  }

  Future<void> payWithWallet(BuildContext context) async {
    if (!_validateBasic(context)) return;

    if (selectedNetworkCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select a network first")));
      return;
    }

    loading = true;

    final uri = Uri.parse("http://localhost:4000/wallet/pay-airtime");

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": FirebaseAuth.instance.currentUser!.uid,
        "phone": phoneCtrl.text.trim(),
        "network": selectedNetworkCode,
        "amount": amountCtrl.text.trim(),
      }),
    );

    final data = jsonDecode(response.body);

    loading = false;

    if (data["status"] == true && data["pending"] != true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AirtimeSuccessScreen(
            phone: phoneCtrl.text.trim(),
            amount: amountCtrl.text.trim(),
            message: data["message"] ?? "Airtime purchase successful",
          ),
        ),
      );
    } else if (data["pending"] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AirtimeProcessingScreen(
            requestId: data["requestId"],
            phone: phoneCtrl.text.trim(),
            amount: amountCtrl.text.trim(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Airtime purchase failed")),
      );
    }
  }

  Future<void> payWithCard(BuildContext context) async {
    if (!_validateBasic(context)) return;

    final amount = int.parse(amountCtrl.text.trim());
    bool paymentSuccess = false;

    await FlutterPaystackPlus.openPaystackPopup(
      context: context,
      publicKey: "pk_test_40afdb486d9a12b37524295c00f169b9d355f0b3",
      secretKey: "",
      customerEmail: "user@example.com",
      amount: (amount * 100).toString(),
      reference: "airtime_${DateTime.now().millisecondsSinceEpoch}",
      currency: "NGN",
      onSuccess: () => paymentSuccess = true,
      onClosed: () {
        if (!paymentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment failed or closed")),
          );
        }
      },
    );

    if (!paymentSuccess) return;

    await payWithWallet(context);
  }
}
