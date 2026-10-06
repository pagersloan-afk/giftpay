// lib/features/airtime/airtime_processing_screen.dart

import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';

import 'airtime_success_screen.dart';

class AirtimeProcessingScreen extends StatefulWidget {
  final String reference;
  final String phone;
  final String amount;

  // Called ONLY after the backend confirms a successful
  // Monnify transaction.
  final Future<void> Function()? onSuccess;

  const AirtimeProcessingScreen({
    super.key,
    required this.reference,
    required this.phone,
    required this.amount,
    this.onSuccess,
  });

  @override
  State<AirtimeProcessingScreen> createState() =>
      _AirtimeProcessingScreenState();
}

class _AirtimeProcessingScreenState extends State<AirtimeProcessingScreen> {
  Timer? timer;

  int attempts = 0;

  bool checking = false;

  static const int maxAttempts = 12;

  @override
  void initState() {
    super.initState();

    /*
     * Check immediately instead of making the customer
     * wait five seconds for the first status check.
     */
    checkStatus();

    timer = Timer.periodic(const Duration(seconds: 5), (_) => checkStatus());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkStatus() async {
    if (checking) return;

    if (!mounted) return;

    checking = true;
    attempts++;

    try {
      // ------------------------------------------------------------
      // GET CURRENT FIREBASE USER
      // ------------------------------------------------------------

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return;
      }

      // ------------------------------------------------------------
      // GET FIREBASE ID TOKEN
      //
      // The Monnify bills requery route is protected by the
      // backend auth middleware, so the Firebase token must be
      // sent with the request.
      // ------------------------------------------------------------

      final idToken = await currentUser.getIdToken();

      if (idToken == null || idToken.isEmpty) {
        return;
      }

      // ------------------------------------------------------------
      // MONNIFY REQUERY ENDPOINT
      // ------------------------------------------------------------

      final uri = Uri.parse(
        ApiConfig.api("/api/monnify/bills/requery"),
      ).replace(queryParameters: {"reference": widget.reference});

      // ------------------------------------------------------------
      // AUTHENTICATED REQUERY REQUEST
      // ------------------------------------------------------------

      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $idToken",
          "Content-Type": "application/json",
        },
      );

      Map<String, dynamic> data;

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        } else {
          data = {};
        }
      } catch (_) {
        data = {};
      }

      /*
       * Our GiftPay backend should normalize Monnify's
       * response to:
       *
       * {
       *   status: true,
       *   transactionStatus: "SUCCESS",
       *   message: "...",
       *   transaction: {...}
       * }
       *
       * But this screen also understands the raw Monnify
       * responseBody.vendStatus so it remains compatible
       * if the backend passes that through.
       */

      final responseBody = data["responseBody"] is Map
          ? Map<String, dynamic>.from(data["responseBody"])
          : <String, dynamic>{};

      final transaction = data["transaction"] is Map
          ? Map<String, dynamic>.from(data["transaction"])
          : <String, dynamic>{};

      final rawStatus =
          data["transactionStatus"] ??
          data["vendStatus"] ??
          responseBody["vendStatus"] ??
          transaction["vendStatus"] ??
          transaction["status"] ??
          data["statusCode"] ??
          "";

      final status = rawStatus.toString().trim().toUpperCase();

      final rawMessage =
          data["message"] ??
          data["responseMessage"] ??
          responseBody["description"] ??
          responseBody["responseMessage"] ??
          transaction["description"] ??
          "Airtime transaction is being processed.";

      final message = rawMessage.toString();

      // ------------------------------------------------------------
      // SUCCESS
      // ------------------------------------------------------------

      if (_isSuccessfulStatus(status)) {
        timer?.cancel();

        // Save recent number ONLY after confirmed success.
        await widget.onSuccess?.call();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AirtimeSuccessScreen(
              phone: widget.phone,
              amount: widget.amount,
              message: message.isNotEmpty
                  ? message
                  : "Airtime purchase successful",
            ),
          ),
        );

        return;
      }

      // ------------------------------------------------------------
      // FAILED
      // ------------------------------------------------------------

      if (_isFailedStatus(status)) {
        timer?.cancel();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.isNotEmpty ? message : "Airtime purchase failed.",
            ),
          ),
        );

        Navigator.pop(context);

        return;
      }

      // ------------------------------------------------------------
      // REVERSED
      // ------------------------------------------------------------

      if (_isReversedStatus(status)) {
        timer?.cancel();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.isNotEmpty
                  ? message
                  : "Airtime transaction was reversed.",
            ),
          ),
        );

        Navigator.pop(context);

        return;
      }

      // ------------------------------------------------------------
      // EXPIRED
      // ------------------------------------------------------------

      if (_isExpiredStatus(status)) {
        timer?.cancel();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.isNotEmpty ? message : "Airtime transaction expired.",
            ),
          ),
        );

        Navigator.pop(context);

        return;
      }

      // ------------------------------------------------------------
      // STILL PROCESSING
      //
      // Do NOT treat an empty/unknown status as failure.
      //
      // A dropped/temporary response must not cause the
      // customer to be told that the transaction failed.
      // ------------------------------------------------------------

      if (attempts >= maxAttempts) {
        timer?.cancel();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Your airtime transaction is still processing. "
              "Please check your transaction history shortly.",
            ),
          ),
        );

        Navigator.pop(context);

        return;
      }
    } catch (_) {
      /*
       * A temporary network/requery error does NOT mean
       * the Monnify transaction failed.
       *
       * Continue polling until maxAttempts is reached.
       */

      if (attempts >= maxAttempts) {
        timer?.cancel();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "We could not confirm the transaction yet. "
              "Please check your transaction history shortly.",
            ),
          ),
        );

        Navigator.pop(context);
      }
    } finally {
      checking = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  // ------------------------------------------------------------
  // MONNIFY STATUS HELPERS
  // ------------------------------------------------------------

  bool _isSuccessfulStatus(String status) {
    return status == "SUCCESS" || status == "COMPLETED";
  }

  bool _isFailedStatus(String status) {
    return status == "FAILED";
  }

  bool _isReversedStatus(String status) {
    return status == "REVERSED";
  }

  bool _isExpiredStatus(String status) {
    return status == "EXPIRED";
  }

  bool _isProcessingStatus(String status) {
    return status == "PENDING" ||
        status == "AWAITING_PROCESSING" ||
        status == "IN_PROGRESS" ||
        status == "PENDING_AUTHORIZATION";
  }

  @override
  Widget build(BuildContext context) {
    final processingStatus = attempts > 0
        ? "Checking transaction status..."
        : "Processing your airtime purchase...";

    return Scaffold(
      appBar: AppBar(title: const Text("Processing Airtime")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),

              const SizedBox(height: 24),

              const Text(
                "Processing your airtime purchase…",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              Text(
                processingStatus,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 24),

              Text(
                "Phone: ${widget.phone}",
                style: TextStyle(color: Colors.grey.shade700),
              ),

              const SizedBox(height: 6),

              Text(
                "Amount: ₦${widget.amount}",
                style: TextStyle(color: Colors.grey.shade700),
              ),

              const SizedBox(height: 6),

              Text(
                "Reference: ${widget.reference}",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),

              const SizedBox(height: 20),

              Text(
                "Checking $attempts of $maxAttempts",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
