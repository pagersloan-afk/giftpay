import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';
import 'package:utilityhub/features/bookkeeping/models/bookkeeping_entry.dart';

class BookkeepingApiService {
  Future<Map<String, String>> _headers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Please sign in to use Bookkeeping.');
    final token = await user.getIdToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  dynamic _decode(http.Response response) {
    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw Exception('The bookkeeping service returned an invalid response.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data is Map ? data['message']?.toString() : null;
      throw Exception(message ?? 'Bookkeeping request failed (${response.statusCode}).');
    }
    if (data is Map && data['status'] == false) {
      throw Exception(data['message']?.toString() ?? 'Bookkeeping request failed.');
    }
    return data;
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw Exception('Invalid bookkeeping data received.');
  }

  Future<Map<String, dynamic>> getDashboard({required String date}) async {
    final uri = Uri.parse(ApiConfig.api('/api/bookkeeping')).replace(
      queryParameters: {'date': date},
    );
    final response = await http.get(uri, headers: await _headers());
    final decoded = _map(_decode(response));
    return _map(decoded['data']);
  }

  Future<Map<String, dynamic>> getReport({
    required String from,
    required String to,
  }) async {
    final uri = Uri.parse(ApiConfig.api('/api/bookkeeping/reports')).replace(
      queryParameters: {'from': from, 'to': to},
    );
    final response = await http.get(uri, headers: await _headers());
    final decoded = _map(_decode(response));
    return _map(decoded['data']);
  }

  Future<void> setOpeningBalances({
    required int openingCashKobo,
    required int openingSavingsKobo,
  }) async {
    final response = await http.put(
      Uri.parse(ApiConfig.api('/api/bookkeeping/opening-balances')),
      headers: await _headers(),
      body: jsonEncode({
        'openingCashKobo': openingCashKobo,
        'openingSavingsKobo': openingSavingsKobo,
      }),
    );
    _decode(response);
  }

  Future<void> resetBookkeeping() async {
    final response = await http.post(
      Uri.parse(ApiConfig.api('/api/bookkeeping/reset')),
      headers: await _headers(),
    );
    _decode(response);
  }

  Future<void> addEntry(BookkeepingEntry entry) async {
    final response = await http.post(
      Uri.parse(ApiConfig.api('/api/bookkeeping/entries')),
      headers: await _headers(),
      body: jsonEncode(entry.toPayload()),
    );
    _decode(response);
  }

  Future<void> updateEntry(BookkeepingEntry entry) async {
    final response = await http.patch(
      Uri.parse(ApiConfig.api('/api/bookkeeping/entries/${Uri.encodeComponent(entry.id)}')),
      headers: await _headers(),
      body: jsonEncode(entry.toPayload()),
    );
    _decode(response);
  }

  Future<void> removeEntry(String id) async {
    final response = await http.delete(
      Uri.parse(ApiConfig.api('/api/bookkeeping/entries/${Uri.encodeComponent(id)}')),
      headers: await _headers(),
    );
    _decode(response);
  }

  Future<Map<String, dynamic>> getPlanning({required String date}) async {
    final uri = Uri.parse(ApiConfig.api('/api/bookkeeping/planning')).replace(
      queryParameters: {'date': date},
    );
    final response = await http.get(uri, headers: await _headers());
    final decoded = _map(_decode(response));
    return _map(decoded['data']);
  }

  Future<void> createBudget({
    required String name,
    required String category,
    required String period,
    required int limitKobo,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.api('/api/bookkeeping/budgets')),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'category': category,
        'period': period,
        'limitKobo': limitKobo,
      }),
    );
    _decode(response);
  }

  Future<void> updateBudget({
    required String id,
    required String name,
    required String category,
    required String period,
    required int limitKobo,
  }) async {
    final response = await http.patch(
      Uri.parse(ApiConfig.api('/api/bookkeeping/budgets/${Uri.encodeComponent(id)}')),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'category': category,
        'period': period,
        'limitKobo': limitKobo,
      }),
    );
    _decode(response);
  }

  Future<void> deleteBudget(String id) async {
    final response = await http.delete(
      Uri.parse(ApiConfig.api('/api/bookkeeping/budgets/${Uri.encodeComponent(id)}')),
      headers: await _headers(),
    );
    _decode(response);
  }

  Future<void> createSavingsGoal({
    required String name,
    required int targetKobo,
    String? targetDate,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.api('/api/bookkeeping/savings/goals')),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'targetKobo': targetKobo,
        if (targetDate != null && targetDate.isNotEmpty) 'targetDate': targetDate,
      }),
    );
    _decode(response);
  }

  Future<void> updateSavingsGoal({
    required String id,
    required String name,
    required int targetKobo,
    String? targetDate,
    required String status,
  }) async {
    final response = await http.patch(
      Uri.parse(ApiConfig.api('/api/bookkeeping/savings/goals/${Uri.encodeComponent(id)}')),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'targetKobo': targetKobo,
        if (targetDate != null && targetDate.isNotEmpty) 'targetDate': targetDate,
        'status': status,
      }),
    );
    _decode(response);
  }

  Future<void> deleteSavingsGoal(String id) async {
    final response = await http.delete(
      Uri.parse(ApiConfig.api('/api/bookkeeping/savings/goals/${Uri.encodeComponent(id)}')),
      headers: await _headers(),
    );
    _decode(response);
  }

  Future<void> createSavingsGoalMovement({
    required String movement,
    required String description,
    required String entryDate,
    required int amountKobo,
    required List<Map<String, dynamic>> allocations,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.api('/api/bookkeeping/savings/goal-movements')),
      headers: await _headers(),
      body: jsonEncode({
        'movement': movement,
        'description': description,
        'entryDate': entryDate,
        'amountKobo': amountKobo,
        'allocations': allocations,
      }),
    );
    _decode(response);
  }
}
