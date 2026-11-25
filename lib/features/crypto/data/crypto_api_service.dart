import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';

class CryptoApiService {
  static Future<Map<String, String>> _headers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Please sign in to use GiftPay Crypto.');
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw Exception('Your session has expired. Please sign in again.');
    }
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  static Future<dynamic> _get(String path) async {
    final response = await http.get(
      Uri.parse(ApiConfig.apiRoute('/crypto$path')),
      headers: await _headers(),
    );
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Invalid response from GiftPay Crypto.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300 ||
        body is! Map || body['status'] != true) {
      final message = body is Map
          ? (body['message'] ?? 'Crypto request failed.').toString()
          : 'Crypto request failed.';
      throw Exception(message);
    }
    return body['data'];
  }

  static Future<dynamic> getMyCustomerProfile() => _get('/customer/me');

  static Future<dynamic> createMyCustomerProfile(Map<String, dynamic> profile) async {
    final response = await http.post(
      Uri.parse(ApiConfig.apiRoute('/crypto/customer/me')),
      headers: await _headers(),
      body: jsonEncode(profile),
    );
    dynamic body;
    try { body = jsonDecode(response.body); } catch (_) {
      throw Exception('Invalid response from GiftPay Crypto.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300 ||
        body is! Map || body['status'] != true) {
      throw Exception(body is Map ? (body['message'] ?? 'Crypto profile creation failed.').toString() : 'Crypto profile creation failed.');
    }
    return body['data'];
  }

  static Future<dynamic> getCurrencies() => _get('/currencies');
  static Future<dynamic> getPairs() => _get('/pairs');
}
