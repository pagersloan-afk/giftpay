// lib/features/airtime/controller/airtime_controller.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utilityhub/config/api.dart';

import '../airtime_processing_screen.dart';
import '../airtime_success_screen.dart';
import '../theme/airtime_theme.dart';

class RecentAirtimeNumber {
  final String phone;
  final String network;

  const RecentAirtimeNumber({required this.phone, required this.network});
}

class AirtimeController {
  final TextEditingController phoneCtrl;
  final TextEditingController amountCtrl;

  bool loading = false;
  bool useWallet = true;

  String selectedNetworkCode = "";

  Map<String, String> networkMap = {};

  List<RecentAirtimeNumber> recentNumbers = [];

  static const String _recentNumbersKey = "giftpay_recent_airtime_numbers";

  static const int _maxRecentNumbers = 10;

  AirtimeController({required this.phoneCtrl, required this.amountCtrl});

  Color get themeColor =>
      AirtimeTheme.themeColorFor(networkMap, selectedNetworkCode);

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> initialize() async {
    await Future.wait([fetchNetworks(), loadRecentNumbers()]);
  }

  // ============================================================
  // NETWORKS
  // ============================================================

  Future<void> fetchNetworks() async {
    try {
      final uri = Uri.parse(ApiConfig.api("/api/airtime/networks"));

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

  // ============================================================
  // AUTOMATIC NETWORK DETECTION
  // ============================================================

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

    if (mtnPrefixes.contains(prefix)) {
      detected = "MTN";
    }

    if (gloPrefixes.contains(prefix)) {
      detected = "GLO";
    }

    if (airtelPrefixes.contains(prefix)) {
      detected = "Airtel";
    }

    if (ninePrefixes.contains(prefix)) {
      detected = "9mobile";
    }

    if (detected != null && networkMap.containsKey(detected)) {
      selectedNetworkCode = networkMap[detected]!;
    }
  }

  // ============================================================
  // RECENT AIRTIME NUMBERS
  // ============================================================

  Future<void> loadRecentNumbers() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final stored = prefs.getStringList(_recentNumbersKey);

      if (stored == null || stored.isEmpty) {
        recentNumbers = [];
        return;
      }

      final List<RecentAirtimeNumber> loaded = [];

      for (final item in stored) {
        try {
          final decoded = jsonDecode(item);

          if (decoded is Map) {
            final phone = decoded["phone"]?.toString().trim() ?? "";
            final network = decoded["network"]?.toString().trim() ?? "";

            if (phone.isNotEmpty) {
              loaded.add(RecentAirtimeNumber(phone: phone, network: network));
            }
          }
        } catch (_) {
          // Ignore malformed stored entries.
        }
      }

      recentNumbers = loaded.take(_maxRecentNumbers).toList();
    } catch (_) {
      recentNumbers = [];
    }
  }

  Future<void> saveRecentNumber({
    required String phone,
    required String network,
  }) async {
    final cleanedPhone = phone.trim();

    if (cleanedPhone.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove an existing copy first.
      recentNumbers.removeWhere((item) => item.phone == cleanedPhone);

      // Put the newly successful number at the top.
      recentNumbers.insert(
        0,
        RecentAirtimeNumber(phone: cleanedPhone, network: network),
      );

      // Keep maximum 10.
      if (recentNumbers.length > _maxRecentNumbers) {
        recentNumbers = recentNumbers.take(_maxRecentNumbers).toList();
      }

      final encoded = recentNumbers.map((item) {
        return jsonEncode({"phone": item.phone, "network": item.network});
      }).toList();

      await prefs.setStringList(_recentNumbersKey, encoded);
    } catch (_) {
      // Recent-number storage must never break an airtime transaction.
    }
  }

  Future<void> removeRecentNumber(String phone) async {
    final cleanedPhone = phone.trim();

    recentNumbers.removeWhere((item) => item.phone == cleanedPhone);

    try {
      final prefs = await SharedPreferences.getInstance();

      final encoded = recentNumbers.map((item) {
        return jsonEncode({"phone": item.phone, "network": item.network});
      }).toList();

      await prefs.setStringList(_recentNumbersKey, encoded);
    } catch (_) {}
  }

  // ============================================================
  // VALIDATION
  // ============================================================

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

  // ============================================================
  // WALLET PAYMENT
  // ============================================================

  Future<void> payWithWallet(BuildContext context) async {
    if (!_validateBasic(context)) return;

    if (selectedNetworkCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select a network first")));

      return;
    }

    loading = true;

    final phone = phoneCtrl.text.trim();
    final amount = amountCtrl.text.trim();

    final uri = Uri.parse(ApiConfig.api("/api/airtime/wallet/pay-airtime"));

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Please sign in again")));
        }

        return;
      }

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": currentUser.uid,
          "phone": phone,
          "network": selectedNetworkCode,
          "amount": amount,
        }),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == true && data["pending"] != true) {
        // ======================================================
        // IMPORTANT:
        // Save ONLY after backend reports successful transaction.
        // ======================================================

        await saveRecentNumber(
          phone: phone,
          network: _networkNameFromCode(selectedNetworkCode),
        );

        if (!context.mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AirtimeSuccessScreen(
              phone: phone,
              amount: amount,
              message: data["message"] ?? "Airtime purchase successful",
            ),
          ),
        );
      } else if (data["pending"] == true) {
        final requestId = data["requestId"]?.toString();

        if (requestId == null || requestId.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Transaction is processing, but no request ID was returned.",
                ),
              ),
            );
          }

          return;
        }

        if (!context.mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AirtimeProcessingScreen(
              requestId: requestId,
              phone: phone,
              amount: amount,

              // Save only if the processing screen later
              // confirms ORDER_COMPLETED.
              onSuccess: () async {
                await saveRecentNumber(
                  phone: phone,
                  network: _networkNameFromCode(selectedNetworkCode),
                );
              },
            ),
          ),
        );
      } else {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Airtime purchase failed")),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to process airtime purchase. Please try again.",
          ),
        ),
      );
    } finally {
      loading = false;
    }
  }

  // ============================================================
  // CARD PAYMENT
  // ============================================================

  Future<void> payWithCard(BuildContext context) async {
    if (!_validateBasic(context)) return;

    if (selectedNetworkCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select a network first")));

      return;
    }

    final amount = int.parse(amountCtrl.text.trim());

    bool paymentSuccess = false;

    await FlutterPaystackPlus.openPaystackPopup(
      context: context,

      // Keep your existing Paystack configuration.
      publicKey: "pk_test_40afdb486d9a12b37524295c00f169b9d355f0b3",

      secretKey: "",

      customerEmail: "user@example.com",

      amount: (amount * 100).toString(),

      reference: "airtime_${DateTime.now().millisecondsSinceEpoch}",

      currency: "NGN",

      onSuccess: () {
        paymentSuccess = true;
      },

      onClosed: () {
        if (!paymentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment failed or closed")),
          );
        }
      },
    );

    if (!paymentSuccess) return;

    // Preserve your existing card flow.
    await payWithWallet(context);
  }

  // ============================================================
  // NETWORK NAME FROM NETWORK CODE
  // ============================================================

  String _networkNameFromCode(String code) {
    for (final entry in networkMap.entries) {
      if (entry.value == code) {
        return entry.key;
      }
    }

    return "";
  }
}
