import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';

/// Server-side authorization remains authoritative. This class only requests
/// the current status and submits the user's application.
class FoodMerchantAccess {
  const FoodMerchantAccess._();

  static String applicationStatus = 'unknown';

  static Future<bool> check() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('[GiftPay Food access] DENIED: no Firebase user is signed in.');
      applicationStatus = 'not_applied';
      return false;
    }

    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw Exception('Unable to authenticate this account.');
    }

    final uri = Uri.parse(ApiConfig.api('/api/food/merchant/access'));
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Merchant access endpoint returned invalid JSON.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body is Map
          ? '${body['message'] ?? body['error'] ?? 'Request failed.'}'
          : 'Request failed.';
      throw Exception('Merchant access API HTTP ${response.statusCode}: $message');
    }
    if (body is! Map) {
      throw Exception('Unexpected merchant access response.');
    }

    applicationStatus = '${body['applicationStatus'] ?? (body['isMerchant'] == true ? 'approved' : 'not_applied')}';
    return body['isMerchant'] == true;
  }

  static Future<String> apply({
    required String legalOwnerName,
    required String restaurantName,
    required String businessType,
    required String registrationType,
    required String registrationNumber,
    required String phone,
    required String businessEmail,
    required String address,
    required String foodSafetyPermitNumber,
    required String description,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Please sign in first.');
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw Exception('Unable to authenticate this account.');
    }

    final uri = Uri.parse(ApiConfig.api('/api/food/merchant/apply'));
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'legalOwnerName': legalOwnerName.trim(),
        'restaurantName': restaurantName.trim(),
        'businessType': businessType,
        'registrationType': registrationType,
        'registrationNumber': registrationNumber.trim(),
        'phone': phone.trim(),
        'businessEmail': businessEmail.trim(),
        'address': address.trim(),
        'foodSafetyPermitNumber': foodSafetyPermitNumber.trim(),
        'description': description.trim(),
      }),
    );

    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Merchant application API returned invalid JSON.');
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body is! Map ||
        body['status'] != true) {
      throw Exception(
        body is Map
            ? '${body['message'] ?? 'Unable to submit application.'}'
            : 'Unable to submit application.',
      );
    }
    applicationStatus = '${body['applicationStatus'] ?? 'pending'}';
    return '${body['message'] ?? 'Application submitted for review.'}';
  }
}
