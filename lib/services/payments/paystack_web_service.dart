import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ⭐ Web-safe HTML API
import 'package:universal_html/html.dart' as html;

class PaystackWebService {
  final String secretKey =
      "sk_test_143ff10a0b4eff5d62545a9886b22ab328b95216"; // TEMPORARY FOR TESTING

  Future<void> startPayment({
    required String email,
    required int amount, // in kobo
  }) async {
    // ⭐ Prevent Android/iOS crash
    if (!kIsWeb) {
      throw Exception("PaystackWebService can only be used on Web.");
    }

    final url = Uri.parse("https://api.paystack.co/transaction/initialize");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $secretKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "amount": amount,
        "callback_url": "http://localhost:5000/#/payment-complete",
      }),
    );

    final data = jsonDecode(response.body);

    if (data["status"] == true) {
      final authUrl = data["data"]["authorization_url"];

      // ⭐ Safe web redirect
      html.window.open(authUrl, "_blank");
    } else {
      throw Exception("Paystack init failed: ${data["message"]}");
    }
  }
}
