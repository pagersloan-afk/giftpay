import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';

/// Checks whether the currently signed-in Firebase user is the authorized
/// GiftPay Food merchant. This is diagnostic logging only; it does not bypass
/// or weaken the server-side authorization check.
class FoodMerchantAccess {
  const FoodMerchantAccess._();

  static Future<bool> check() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('[GiftPay Food access] DENIED: no Firebase user is signed in.');
      return false;
    }

    debugPrint('[GiftPay Food access] Signed-in UID: ${user.uid}');

    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      debugPrint('[GiftPay Food access] FAILED: Firebase ID token is empty.');
      return false;
    }

    final uri = Uri.parse(ApiConfig.api('/api/food/merchant/access'));
    debugPrint('[GiftPay Food access] GET $uri');

    late final http.Response response;
    try {
      response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
    } catch (e, stackTrace) {
      debugPrint('[GiftPay Food access] HTTP REQUEST FAILED: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }

    // Do not log the Firebase token. The status and response body are useful
    // for diagnosis and should not contain credentials.
    debugPrint('[GiftPay Food access] HTTP status: ${response.statusCode}');
    debugPrint('[GiftPay Food access] Raw response body: ${response.body}');

    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Merchant access endpoint returned non-JSON data '
        '(HTTP ${response.statusCode}). Check the browser console and backend logs.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body is Map
          ? '${body['message'] ?? body['error'] ?? 'Request failed.'}'
          : 'Request failed.';
      throw Exception('Merchant access API HTTP ${response.statusCode}: $message');
    }

    if (body is! Map) {
      throw Exception('Unexpected merchant access response: expected a JSON object.');
    }

    final isMerchant = body['isMerchant'] == true;
    debugPrint(
      '[GiftPay Food access] Parsed isMerchant=${body['isMerchant']} '
      '(authorized=$isMerchant)',
    );
    return isMerchant;
  }
}
