import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';
import 'package:utilityhub/features/wallet/models/virtual_account.dart';

class VirtualAccountService {
  final _db = FirebaseFirestore.instance;

  Future<VirtualAccount?> getVirtualAccount(String userId) async {
    final doc = await _db.collection("users").doc(userId).get();
    final data = doc.data();
    if (data == null || data["virtualAccount"] == null) return null;
    return VirtualAccount.fromMap(data["virtualAccount"]);
  }

  Future<VirtualAccount?> fetchOrCreateFromBackend({
    required String userId,
    required String name,
    required String email,
    required String phone,
  }) async {
    // ⭐ STEP 1 — Check Firestore first
    final existing = await getVirtualAccount(userId);
    if (existing != null) {
      debugPrint("VA already exists — returning Firestore VA");
      return existing;
    }

    // ⭐ STEP 2 — Call backend only once
    final uri = Uri.parse(ApiConfig.api("/api/monnify/create"));

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "name": name,
        "email": email,
        "phone": phone,
      }),
    );

    if (res.statusCode != 200) {
      debugPrint("Monnify create failed: ${res.statusCode} ${res.body}");
      return null;
    }

    try {
      final data = jsonDecode(res.body);
      if (data["status"] == true && data["data"] != null) {
        return VirtualAccount.fromMap(data["data"]);
      }
      debugPrint("Monnify create returned error: $data");
      return null;
    } catch (e) {
      debugPrint("Monnify create JSON parse error: $e\nBody: ${res.body}");
      return null;
    }
  }
}
