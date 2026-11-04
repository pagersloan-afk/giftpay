import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';
import 'package:utilityhub/features/wallet/models/virtual_account.dart';

class VirtualAccountService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, String>> _headers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Please sign in again to continue.');
    final token = await user.getIdToken();
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  Future<Map<String, dynamic>> getConfig() async {
    final response = await http.get(
      Uri.parse(ApiConfig.api('/api/virtual-account/config')),
      headers: await _headers(),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300 || body['status'] != true) {
      throw Exception(body['message'] ?? 'Unable to load virtual-account settings.');
    }
    return body;
  }

  Future<List<Map<String, String>>> getNigerianBanks() async {
    final response = await http.get(
      Uri.parse(ApiConfig.api('/api/virtual-account/banks')),
      headers: await _headers(),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300 || body['status'] != true) {
      throw Exception(body['message'] ?? 'Unable to load banks.');
    }
    return (body['data'] as List? ?? []).map((item) => {
      'name': (item['name'] ?? '').toString(),
      'code': (item['code'] ?? '').toString(),
    }).where((item) => item['name']!.isNotEmpty && item['code']!.isNotEmpty).toList();
  }

  Future<Map<String, dynamic>> preparePaystackAccount({
    required String bvn,
    required String accountNumber,
    required String bankCode,
    required bool consent,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.api('/api/virtual-account/prepare-paystack')),
      headers: await _headers(),
      body: jsonEncode({'bvn': bvn, 'accountNumber': accountNumber, 'bankCode': bankCode, 'consent': consent}),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300 || body['status'] != true) {
      throw Exception(body['message'] ?? 'Bank verification could not be completed.');
    }
    return body;
  }

  Future<Map<String, dynamic>> getVirtualAccountStatus() async {
    final response = await http.get(
      Uri.parse(ApiConfig.api('/api/virtual-account/status')),
      headers: await _headers(),
    );
    final body = _decode(response);
    if (response.statusCode >= 500 || body['status'] == false && response.statusCode != 409) {
      throw Exception(body['message'] ?? 'Unable to retrieve account status.');
    }
    return body;
  }

  Future<VirtualAccount?> getVirtualAccount(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    final data = doc.data();
    if (data == null || data['virtualAccount'] is! Map) return null;
    final account = Map<String, dynamic>.from(data['virtualAccount']);
    if ((account['accountNumber'] ?? '').toString().isEmpty) return null;
    return VirtualAccount.fromMap(account);
  }

  Future<VirtualAccount?> fetchOrCreateFromBackend({
    required String userId,
    required String name,
    required String email,
    required String phone,
  }) async {
    // The backend selects Monnify or Paystack using VIRTUAL_ACCOUNT_PROVIDER.
    final existing = await getVirtualAccount(userId);
    if (existing != null) return existing;
    final response = await http.post(
      Uri.parse(ApiConfig.api('/api/virtual-account/create')),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'email': email, 'phone': phone}),
    );
    final body = _decode(response);
    if (body['status'] == true && body['data'] is Map) {
      return VirtualAccount.fromMap(Map<String, dynamic>.from(body['data']));
    }
    if (body['statusCode'] == 'pending') return null;
    throw Exception(body['message'] ?? 'Unable to create your dedicated account.');
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (error) {
      debugPrint('Virtual-account response parse error: $error');
      return <String, dynamic>{};
    }
  }
}
