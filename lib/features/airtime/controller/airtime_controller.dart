// lib/features/airtime/controller/airtime_controller.dart

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utilityhub/config/api.dart';

import '../../wallet/transfer/wigets/pin_entry_dialog.dart';

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
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        debugPrint(
          "[AIRTIME] Cannot fetch networks: no authenticated Firebase user.",
        );
        return;
      }

      final idToken = await currentUser.getIdToken();

      if (idToken == null || idToken.isEmpty) {
        debugPrint(
          "[AIRTIME] Cannot fetch networks: Firebase ID token is empty.",
        );
        return;
      }

      final uri = Uri.parse(ApiConfig.api("/api/airtime/networks"));

      debugPrint("[AIRTIME] Fetching networks: $uri");

      final response = await http
          .get(uri, headers: {"Authorization": "Bearer $idToken"})
          .timeout(const Duration(seconds: 20));

      debugPrint("[AIRTIME] Network response: ${response.statusCode}");

      debugPrint("[AIRTIME] Network response body: ${response.body}");

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          "[AIRTIME] Network request failed with HTTP ${response.statusCode}",
        );
        return;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        debugPrint("[AIRTIME] Invalid network response format.");
        return;
      }

      if (decoded["status"] != true) {
        debugPrint(
          "[AIRTIME] Backend returned unsuccessful network response: "
          "${decoded["message"] ?? "Unknown error"}",
        );
        return;
      }

      final rawNetworks = decoded["networks"];

      if (rawNetworks is! Map) {
        debugPrint("[AIRTIME] No valid networks object returned by backend.");
        return;
      }

      final parsed = rawNetworks.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );

      if (parsed.isEmpty) {
        debugPrint("[AIRTIME] Backend returned an empty network map.");
        return;
      }

      networkMap = Map<String, String>.from(parsed);

      if (!networkMap.values.contains(selectedNetworkCode)) {
        selectedNetworkCode = networkMap.values.first;
      }

      debugPrint("[AIRTIME] Networks loaded: $networkMap");

      debugPrint("[AIRTIME] Selected network: $selectedNetworkCode");
    } catch (error) {
      debugPrint("[AIRTIME] Network loading error: $error");
    }
  }

  // ============================================================
  // AUTOMATIC NETWORK DETECTION
  // ============================================================

  void autoDetectNetwork() {
    final phone = phoneCtrl.text.trim();

    if (phone.length < 4) {
      return;
    }

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
          // Ignore malformed entries.
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

    if (cleanedPhone.isEmpty) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      recentNumbers.removeWhere((item) => item.phone == cleanedPhone);

      recentNumbers.insert(
        0,
        RecentAirtimeNumber(phone: cleanedPhone, network: network),
      );

      if (recentNumbers.length > _maxRecentNumbers) {
        recentNumbers = recentNumbers.take(_maxRecentNumbers).toList();
      }

      final encoded = recentNumbers.map((item) {
        return jsonEncode({"phone": item.phone, "network": item.network});
      }).toList();

      await prefs.setStringList(_recentNumbersKey, encoded);
    } catch (_) {
      // Recent-number storage must never
      // break an airtime transaction.
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
  // SAFE MESSAGE
  // ============================================================

  void _showMessage(BuildContext context, String message) {
    if (!context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);

    if (messenger == null) {
      return;
    }

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // BASIC VALIDATION
  // ============================================================

  bool _validateBasic(BuildContext context) {
    final phone = phoneCtrl.text.trim();

    final amountText = amountCtrl.text.trim();

    if (phone.isEmpty || amountText.isEmpty) {
      _showMessage(context, "Fill all fields");

      return false;
    }

    final amount = int.tryParse(amountText);

    if (amount == null || amount < 50) {
      _showMessage(context, "Minimum is ₦50");

      return false;
    }

    return true;
  }

  bool validateForPurchase(BuildContext context) {
    if (!_validateBasic(context)) {
      return false;
    }

    if (selectedNetworkCode.isEmpty) {
      _showMessage(context, "Select a network first");

      return false;
    }

    return true;
  }

  // ============================================================
  // PROVIDER ERROR MESSAGE
  // ============================================================

  String _extractApiMessage(dynamic data, int statusCode) {
    if (data is Map) {
      final directMessage = data["message"];

      if (directMessage != null && directMessage.toString().trim().isNotEmpty) {
        return directMessage.toString().trim();
      }

      final responseMessage = data["responseMessage"];

      if (responseMessage != null &&
          responseMessage.toString().trim().isNotEmpty) {
        return responseMessage.toString().trim();
      }

      final provider = data["provider"];

      if (provider is Map) {
        final providerMessage =
            provider["responseMessage"] ?? provider["message"];

        if (providerMessage != null &&
            providerMessage.toString().trim().isNotEmpty) {
          return providerMessage.toString().trim();
        }
      }

      final error = data["error"];

      if (error != null && error.toString().trim().isNotEmpty) {
        return error.toString().trim();
      }
    }

    if (statusCode >= 500) {
      return "Server error processing airtime purchase";
    }

    return "Airtime purchase failed";
  }

  // ============================================================
  // WALLET PAYMENT
  // ============================================================

  Future<void> payWithWallet(
    BuildContext context, {
    required String transactionPin,
  }) async {
    if (loading) {
      return;
    }

    if (!_validateBasic(context)) {
      return;
    }

    if (selectedNetworkCode.isEmpty) {
      _showMessage(context, "Select a network first");

      return;
    }

    if (!RegExp(r"^\d{4}$").hasMatch(transactionPin)) {
      _showMessage(context, "A valid 4-digit transaction PIN is required.");

      return;
    }

    loading = true;

    final phone = phoneCtrl.text.trim();

    final amount = amountCtrl.text.trim();

    final uri = Uri.parse(ApiConfig.api("/api/airtime/wallet/pay-airtime"));

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        _showMessage(context, "Please sign in again");

        return;
      }

      final idToken = await currentUser.getIdToken();

      if (idToken == null || idToken.isEmpty) {
        _showMessage(context, "Please sign in again");

        return;
      }

      debugPrint("[AIRTIME] Starting wallet purchase for $phone");

      final response = await http
          .post(
            uri,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $idToken",
            },
            body: jsonEncode({
              "userId": currentUser.uid,
              "phone": phone,
              "network": selectedNetworkCode,
              "amount": amount,

              // Server-side PIN enforcement.
              "transactionPin": transactionPin,
            }),
          )
          .timeout(const Duration(seconds: 45));

      dynamic data;

      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = null;
      }

      debugPrint("[AIRTIME] Purchase response: ${response.statusCode}");

      if (data is Map) {
        debugPrint("[AIRTIME] Purchase status: ${data["status"]}");

        debugPrint("[AIRTIME] Purchase pending: ${data["pending"]}");
      }

      final status = data is Map && data["status"] == true;

      final pending = data is Map && data["pending"] == true;

      final reference = data is Map
          ? (data["reference"] ??
                    data["transactionReference"] ??
                    data["vendReference"])
                ?.toString()
                .trim()
          : null;

      final message = _extractApiMessage(data, response.statusCode);

      // --------------------------------------------------------
      // HTTP / BACKEND FAILURE
      // --------------------------------------------------------

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _showMessage(context, message);

        return;
      }

      // --------------------------------------------------------
      // IMMEDIATE SUCCESS
      // --------------------------------------------------------

      if (status && !pending) {
        await saveRecentNumber(
          phone: phone,
          network: _networkNameFromCode(selectedNetworkCode),
        );

        if (!context.mounted) {
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AirtimeSuccessScreen(
              phone: phone,
              amount: amount,
              message: message.isNotEmpty
                  ? message
                  : "Airtime purchase successful",
            ),
          ),
        );

        return;
      }

      // --------------------------------------------------------
      // PENDING
      // --------------------------------------------------------

      if (pending) {
        if (reference == null || reference.isEmpty) {
          _showMessage(
            context,
            "Transaction is processing, but no transaction reference was returned.",
          );

          return;
        }

        if (!context.mounted) {
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AirtimeProcessingScreen(
              reference: reference,
              phone: phone,
              amount: amount,
              onSuccess: () async {
                await saveRecentNumber(
                  phone: phone,
                  network: _networkNameFromCode(selectedNetworkCode),
                );
              },
            ),
          ),
        );

        return;
      }

      // --------------------------------------------------------
      // FAILURE
      // --------------------------------------------------------

      _showMessage(context, message);
    } catch (error) {
      debugPrint("[AIRTIME] Purchase error: $error");

      if (!context.mounted) {
        return;
      }

      String message = "Unable to process airtime purchase. Please try again.";

      final errorText = error.toString();

      if (errorText.isNotEmpty && !errorText.startsWith("Exception: null")) {
        message = errorText.replaceFirst("Exception: ", "");
      }

      _showMessage(context, message);
    } finally {
      loading = false;
    }
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
