import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ⭐ Web-safe HTML API
import 'package:universal_html/html.dart' as html;

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
    // ⭐ Prevent Android/iOS crash
    if (!kIsWeb) {
      setState(() => message = "This page is only for web payments.");
      return;
    }

    final uri = Uri.base;
    final reference = uri.queryParameters["reference"];

    if (reference == null) {
      setState(() => message = "No reference found.");
      return;
    }

    // ⭐ Safe web redirect
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
