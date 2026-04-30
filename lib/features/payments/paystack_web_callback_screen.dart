import 'dart:html' as html;
import 'package:flutter/material.dart';

class PaystackWebCallbackScreen extends StatefulWidget {
  const PaystackWebCallbackScreen({super.key});

  @override
  State<PaystackWebCallbackScreen> createState() =>
      _PaystackWebCallbackScreenState();
}

class _PaystackWebCallbackScreenState extends State<PaystackWebCallbackScreen> {
  String message = "Processing payment...";

  @override
  void initState() {
    super.initState();
    _redirectToBackend();
  }

  void _redirectToBackend() {
    final uri = Uri.base;
    final reference = uri.queryParameters["reference"];

    if (reference == null) {
      setState(() => message = "No reference found.");
      return;
    }

    // ⭐ Redirect to backend callback
    html.window.location.href =
        "https://yourdomain.com/paystack/callback?reference=$reference";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Status")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}
